/// Firebase Cloud Messaging + Local Notifications service.
///
/// Uses FREE Firestore snapshot listeners + flutter_local_notifications
/// instead of Cloud Functions. No billing required.
library;

import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/firebase_options.dart';
import 'package:vixora/services/firestore_service.dart';

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🔔 Background FCM message: ${message.notification?.title}');
}

/// Service for managing FCM token registration, notification handlers,
/// and Firestore-based local notification triggers.
class FCMTokenService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  /// Track previously seen request IDs to detect new pending requests.
  final Set<String> _seenRequestIds = {};
  StreamSubscription? _residentRequestSubscription;

  /// Initializes FCM: requests permission, gets token, stores in Firestore.
  Future<void> initializeFCM(String uid) async {
    try {
      // STEP 1: Request permission FIRST before anything else
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      debugPrint('📱 FCM Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('❌ FCM notifications denied by user');
        return;
      }

      // STEP 2: Set foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // STEP 3: Get FCM token
      String? token = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $token');

      if (token != null) {
        // STEP 4: Save token to Firestore
        await _firestoreService.updateFcmToken(uid, token);
        debugPrint('✅ FCM token saved to Firestore for uid: $uid');
      }

      // STEP 5: Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) async {
        debugPrint('🔄 FCM token refreshed: $newToken');
        await _firestoreService.updateFcmToken(uid, newToken);
      });

      // STEP 6: Setup local notifications channel
      await _setupLocalNotifications();

      // STEP 7: Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint(
            '📩 Foreground FCM received: ${message.notification?.title}');
        _showLocalNotificationFromRemote(message);
      });

      debugPrint('✅ FCM initialized successfully');
    } catch (e) {
      debugPrint('❌ FCM init error: $e');
    }
  }

  /// Starts listening for new pending visitor requests for a resident.
  /// Triggers local notification when a new pending request is detected.
  void startResidentRequestListener(String residentUid) {
    // Cancel any previous subscription
    _residentRequestSubscription?.cancel();
    _seenRequestIds.clear();

    _residentRequestSubscription = FirebaseFirestore.instance
        .collection(AppConstants.visitorRequestsCollection)
        .where(AppConstants.fieldResidentId, isEqualTo: residentUid)
        .where(AppConstants.fieldStatus,
            isEqualTo: AppConstants.statusPending)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final docId = change.doc.id;
          if (!_seenRequestIds.contains(docId)) {
            _seenRequestIds.add(docId);
            // Skip the initial load (first snapshot populates existing docs)
            if (_seenRequestIds.length > 1 ||
                snapshot.docChanges.length == 1) {
              final data = change.doc.data();
              if (data != null) {
                final visitorName =
                    data[AppConstants.fieldVisitorName] ?? 'Visitor';
                final purpose =
                    data[AppConstants.fieldPurpose] ?? 'Visit';
                showLocalNotification(
                  'New Visitor Request',
                  '$visitorName is at the gate — Purpose: $purpose',
                );
              }
            }
          }
        }
      }
    });
  }

  /// Stops the resident request listener.
  void stopResidentRequestListener() {
    _residentRequestSubscription?.cancel();
    _residentRequestSubscription = null;
    _seenRequestIds.clear();
  }

  /// Initializes flutter_local_notifications plugin with Android channel.
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null) {
          debugPrint('🔔 Local notification tapped, requestId: $payload');
        }
      },
    );

    // Create the notification channel — MUST match channel_id in manifest
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'visitor_channel', // id — matches manifest default_notification_channel_id
      'Visitor Requests', // name
      description: 'Notifications for new visitor requests',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('✅ Notification channel created: visitor_channel');
  }

  /// Displays a local notification with custom title and body.
  Future<void> showLocalNotification(String title, String body) async {
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'visitor_channel', // MUST match channel id above
          'Visitor Requests',
          channelDescription: 'Notifications for new visitor requests',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  /// Displays a local notification for a foreground FCM message.
  Future<void> _showLocalNotificationFromRemote(RemoteMessage message) async {
    final notification = message.notification;
    final requestId = message.data['requestId'] ?? '';

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'visitor_channel',
          'Visitor Requests',
          channelDescription: 'Notifications for new visitor requests',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: requestId,
    );
  }

  /// Dispose all subscriptions.
  void dispose() {
    _residentRequestSubscription?.cancel();
  }
}
