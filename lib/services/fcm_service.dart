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
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/screens/resident/request_detail_screen.dart';
import 'package:vixora/services/firestore_service.dart';
import 'package:vixora/firebase_options.dart';

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
  // Initialize Firebase if needed (minimal handler)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 Background FCM message: ${message.notification?.title}');
  print('🔔 Background data: ${message.data}');
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
    try {
      // STEP 1: Request permission FIRST before anything else
      NotificationSettings settings = await FirebaseMessaging.instance
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
            announcement: false,
            carPlay: false,
            criticalAlert: false,
          );

      print('📱 FCM Permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ FCM notifications denied by user');
        return;
      }

      // STEP 2: Set foreground notification presentation options
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      // STEP 3: Get FCM token
      String? token = await FirebaseMessaging.instance.getToken();
      print('🔑 FCM Token: $token');

      if (token != null) {
        // STEP 4: Save token to Firestore
        await _firestoreService.updateFcmToken(uid, token);
        print('✅ FCM token saved to Firestore for uid: $uid');
      }

      // STEP 5: Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        print('🔄 FCM token refreshed: $newToken');
        await _firestoreService.updateFcmToken(uid, newToken);
      });

      // STEP 6: Setup local notifications channel
      await _setupLocalNotifications();

      // STEP 7: Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('📩 Foreground FCM received: ${message.notification?.title}');
        _showLocalNotification(message);
      });

      print('✅ FCM initialized successfully');
    } catch (e) {
      print('❌ FCM init error: $e');
    }
  }

  /// Initializes flutter_local_notifications plugin with Android channel.
  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // ↑ uses your app launcher icon

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap from local notification
        final payload = response.payload;
        if (payload != null) {
          print('🔔 Local notification tapped, requestId: $payload');
          // Navigation handled by FCM handlers in home screen
        }
      },
    );

    // Create the notification channel — MUST match channel_id in FCM payload
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'vixora_visitors', // id — must match FCM channel_id
      'Visitor Requests', // name
      description: 'Notifications for new visitor requests',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print('✅ Notification channel created: vixora_visitors');
  }

  /// Displays a local notification for a foreground message.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final requestId = message.data['requestId'] ?? '';

    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'vixora_visitors', // MUST match channel id above
          'Visitor Requests',
          channelDescription: 'Notifications for new visitor requests',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        ),
      ),
      payload: requestId, // pass requestId for navigation on tap
    );
  }
}
