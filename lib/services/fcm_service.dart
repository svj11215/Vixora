/// Firebase Cloud Messaging service using FCM HTTP v1 API with manual JWT OAuth2.
///
/// This service handles sending push notifications to residents when a new visitor
/// request is created. Uses JWT signing with the service account private key to
/// obtain OAuth2 Bearer tokens — more reliable on Android than googleapis_auth.
library;

import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/screens/resident/request_detail_screen.dart';
import 'package:vixora/services/firestore_service.dart';

/// Sends Firebase Cloud Messaging notifications via FCM HTTP v1 API.
/// Uses manual JWT-based OAuth2 authentication with service account credentials.
class FcmService {
  static const String _projectId = 'vixora-dc924';
  static const String _fcmApiUrl =
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';
  static const String _tokenUrl = 'https://oauth2.googleapis.com/token';
  static const String _scope =
      'https://www.googleapis.com/auth/firebase.messaging';

  /// Loads the service account JSON from assets.
  Future<Map<String, dynamic>> _loadServiceAccount() async {
    final jsonStr = await rootBundle.loadString('assets/service_account.json');
    return jsonDecode(jsonStr);
  }

  /// Generates a JWT signed with the service account private key,
  /// then exchanges it for an OAuth2 access token.
  Future<String> _getAccessToken() async {
    final sa = await _loadServiceAccount();

    final now = DateTime.now();
    final jwt = JWT({
      'iss': sa['client_email'],
      'scope': _scope,
      'aud': _tokenUrl,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': (now.millisecondsSinceEpoch ~/ 1000) + 3600,
    });

    // Sign JWT with RSA private key
    final privateKey = RSAPrivateKey(sa['private_key']);
    final token = jwt.sign(privateKey, algorithm: JWTAlgorithm.RS256);

    // Exchange JWT for access token
    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion': token,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get access token: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['access_token'];
  }

  /// Sends a push notification to the resident's device.
  ///
  /// Parameters:
  ///   [fcmToken] - Device FCM token from Firestore
  ///   [visitorName] - Guest's name (for notification body)
  ///   [purpose] - Visit purpose (for notification body)
  ///   [requestId] - Firestore document ID (for navigation on tap)
  Future<void> sendNotification({
    required String fcmToken,
    required String visitorName,
    required String purpose,
    required String requestId,
  }) async {
    try {
      // Get OAuth2 access token
      final accessToken = await _getAccessToken();

      // Build FCM message
      final message = {
        'message': {
          'token': fcmToken,
          'notification': {
            'title': 'New Visitor at Gate 🔔',
            'body': '$visitorName is here for $purpose',
          },
          'data': {'requestId': requestId},
          'android': {
            'priority': 'HIGH',
            'notification': {'channel_id': 'vixora_visitors'},
          },
        },
      };

      // Send to FCM
      final response = await http.post(
        Uri.parse(_fcmApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully to $visitorName');
      } else {
        print('❌ FCM error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ FCM exception: $e');
    }
  }
}

/// Top-level background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Minimal handler: message is received but no heavy processing needed
  // Firebase will handle showing the notification automatically when app is in background
}

/// Service for managing FCM token registration and notification handlers.
/// Handles foreground, background, and cold-start notification scenarios.
class FCMTokenService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirestoreService _firestoreService = FirestoreService();

  /// Initializes FCM: requests permission, gets token, stores in Firestore.
  Future<void> initializeFCM(String uid) async {
    // Request notification permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Get current token and store it
    final token = await _messaging.getToken();
    if (token != null) {
      await _firestoreService.updateFcmToken(uid, token);
    }

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _firestoreService.updateFcmToken(uid, newToken);
    });

    // Setup handlers
    setupForegroundHandler();
    setupTerminatedHandler();
    setupInteractedMessage();
  }

  /// Initializes flutter_local_notifications plugin with Android channel.
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap — navigation is handled by FCM's onMessageOpenedApp
      },
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDesc,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);
  }

  /// Sets up the foreground message handler to display local notifications.
  void setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      final android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              AppConstants.notificationChannelId,
              AppConstants.notificationChannelName,
              channelDescription: AppConstants.notificationChannelDesc,
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  /// Checks if the app was opened from a terminated state via notification.
  Future<RemoteMessage?> setupTerminatedHandler() async {
    final initialMessage = await _messaging.getInitialMessage();
    return initialMessage;
  }

  /// Listens for notification taps when the app is in the background.
  void setupInteractedMessage() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigation is handled by caller via context
    });
  }

  /// Sets up all notification handlers including foreground, background, and terminated state.
  /// Should be called after the app is fully initialized and the user is logged in.
  Future<void> setupNotificationHandlers(BuildContext context) async {
    // 1. Foreground messages — show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });

    // 2. App in background — user tapped notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _navigateToRequest(context, message.data['requestId']);
    });

    // 3. App was terminated — user tapped notification
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToRequest(context, initialMessage.data['requestId']);
      });
    }
  }

  /// Displays a local notification for a foreground message.
  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            AppConstants.notificationChannelId,
            AppConstants.notificationChannelName,
            channelDescription: AppConstants.notificationChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }
  }

  /// Navigates to the RequestDetailScreen for the given request ID.
  void _navigateToRequest(BuildContext context, String? requestId) {
    if (requestId == null || requestId.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RequestDetailScreen(requestId: requestId),
      ),
    );
  }
}
