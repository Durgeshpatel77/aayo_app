import 'dart:io';

import 'package:aayo/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../screens/home_screens/notification_screen.dart';

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
    final messaging = FirebaseMessaging.instance;

    // ✅ Request permissions
    await messaging.requestPermission();

    // ✅ Ensure token is available
    String? token;
    int retryCount = 0;
    do {
      token = await messaging.getToken();
      if (token != null) break;
      retryCount++;
      await Future.delayed(const Duration(seconds: 1));
    } while (retryCount < 5);

    if (token != null) {
      print('📡 FCM Token: $token');
      // TODO: Send token to your backend if needed
    } else {
      print('❌ Failed to fetch FCM token after 5 retries.');
    }

    // ✅ Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Foreground message received: ${message.data}');
      _showFlutterNotification(message);

      // Update UI if needed
      latestMessage.value = message.notification?.body ?? '';
      Future.delayed(const Duration(seconds: 3), () {
        latestMessage.value = null;
      });
    });

    // ✅ Notification opened when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Notification opened from background!');
      tappedMessage = message.notification?.body ?? message.data['message'] ?? null;
    });

    // ✅ Handle app opened from terminated state
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      print('🟡 App launched via notification.');
      tappedMessage = initialMessage.notification?.body ?? initialMessage.data['message'] ?? null;
    }

    // ✅ Setup local notification plugin
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
        debugPrint("🔔 Notification tapped with payload: $payload");

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => const Notificationscreen(),
          ),
        );
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

    const baseUrl = 'http://82.29.167.118:8000/';
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
