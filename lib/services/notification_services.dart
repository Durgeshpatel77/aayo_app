import 'dart:io';

import 'package:aayo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Notifies UI about the latest foreground message body.
  /// Value is cleared automatically after 3 seconds.
  static final ValueNotifier<String?> latestMessage = ValueNotifier(null);

  /// Stores the last tapped notification message for background/terminated state.
  static String? tappedMessage;

  /// Background message handler - must be a top-level or static function.
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  /// Initialize Firebase, request permissions, set up listeners.
  static Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Request permission for iOS
    await _firebaseMessaging.requestPermission();

    // Get FCM token (optional)
    try {
      final token = await _firebaseMessaging.getToken();
      print('✅ FCM Token: $token');
    } catch (e) {
      print('❌ Failed to fetch FCM token: $e');
    }

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Foreground message received: ${message.data}');
      _showFlutterNotification(message);

      // Notify UI with message while app is in foreground
      latestMessage.value = message.notification?.body ?? '';

      // Clear message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        latestMessage.value = null;
      });
    });

    // Background/terminated notification tap listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');

      tappedMessage = message.notification?.body ?? message.data['message'] ?? null;
      // You can notify UI or handle opening drawer in your main widget listening for this change
    });

    // Check if app was opened from terminated state via notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      tappedMessage = initialMessage.notification?.body ?? initialMessage.data['message'] ?? null;
    }

    await _initializeLocalNotification();
  }

  /// Initialize local notification plugin
  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('logo'); // Your app icon in drawable folder

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint("Notification tapped with payload: $payload");
      },
    );
  }

  /// Show notification using flutter_local_notifications
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    print("📨 DEBUG: message.notification?.body = ${message.notification?.body}");
    print("📨 DEBUG: message.data = ${message.data}");

    String? title = message.data['title'] ?? message.notification?.title;

    // 👇 use userName from data first, fallback to notification.body
    String? body = (message.data['type'] == 'follow' && message.data['userName'] != null)
        ? "${message.data['userName']} started following you!"
        : message.data['body'] ?? message.notification?.body;

    print('🔔 Preparing notification: $title — $body');

    const baseUrl = 'http://srv861272.hstgr.cloud:8000/';
    String? rawPostImage = message.data['postImage'];
    String? rawUserAvatar = message.data['userAvatar'];

    String? imageUrl;
    if (rawPostImage != null && rawPostImage.isNotEmpty) {
      imageUrl = rawPostImage.startsWith('http') ? rawPostImage : '$baseUrl$rawPostImage';
    } else if (rawUserAvatar != null && rawUserAvatar.isNotEmpty) {
      imageUrl = rawUserAvatar.startsWith('http') ? rawUserAvatar : '$baseUrl$rawUserAvatar';
    }

    BigPictureStyleInformation? styleInfo;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        final bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');
        styleInfo = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        print("❌ Failed to load image for notification: $e");
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'Used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: styleInfo,
      icon: 'logo',
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    if (title != null && body != null) {
      await flutterLocalNotificationsPlugin.show(
        title.hashCode,
        title,
        body,
        notificationDetails,
      );
      print('✅ Notification shown!');
    } else {
      print('⚠️ Notification title or body was null. Nothing shown.');
    }
  }

  /// Download and save a file locally for notification images
  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
