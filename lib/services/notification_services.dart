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

  static final ValueNotifier<String?> latestMessage = ValueNotifier(null);
  static String? tappedMessage;

  /// 🟡 Background message handler — must be a top-level or static function
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await _initializeLocalNotification();
    await _showFlutterNotification(message);
  }

  /// ✅ Initialize Firebase Messaging and notification handlers
  static Future<void> initialize() async {
    // Request permissions (especially for Android 13+ and iOS)
    final settings = await _firebaseMessaging.requestPermission();
    print('🔐 Notification permission: ${settings.authorizationStatus}');

    // Fetch token
    String? token = await _firebaseMessaging.getToken();
    print('📡 FCM Token: $token');

    // Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Foreground FCM message: ${message.data}');
      _showFlutterNotification(message);

      latestMessage.value = message.notification?.body ?? '';
      Future.delayed(const Duration(seconds: 3), () {
        latestMessage.value = null;
      });
    });

    // Background opened
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📲 Opened from background notification');
      tappedMessage = message.notification?.body ?? message.data['message'];
      navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const Notificationscreen()));
    });

    // Terminated opened
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('🟡 Opened from terminated state');
      tappedMessage = initialMessage.notification?.body ?? initialMessage.data['message'];
    }

    await _initializeLocalNotification();
  }

  /// ✅ Initialize the local notification plugin
  static Future<void> _initializeLocalNotification() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('logo');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("🔔 Notification tapped: ${response.payload}");
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => const Notificationscreen()));
      },
    );

    print('✅ Local notification plugin initialized');
  }

  /// ✅ Show notification with optional image (BigPictureStyle)
  static Future<void> _showFlutterNotification(RemoteMessage message) async {
    final data = message.data;
    final notification = message.notification;

    final String? title = data['title'] ?? notification?.title;
    String? body;

    if (data['type'] == 'follow' && data['userName'] != null) {
      body = "${data['userName']} started following you!";
    } else {
      body = data['body'] ?? notification?.body;
    }

    print('🔔 Showing notification: $title - $body');

    const String baseUrl = 'http://82.29.167.118:8000/';
    final String? rawPostImage = data['postImage'];
    final String? rawUserAvatar = data['userAvatar'];

    String? imageUrl;
    if (rawPostImage != null && rawPostImage.isNotEmpty) {
      imageUrl = rawPostImage.startsWith('http') ? rawPostImage : '$baseUrl$rawPostImage';
    } else if (rawUserAvatar != null && rawUserAvatar.isNotEmpty) {
      imageUrl = rawUserAvatar.startsWith('http') ? rawUserAvatar : '$baseUrl$rawUserAvatar';
    }

    BigPictureStyleInformation? styleInfo;
    if (imageUrl != null) {
      try {
        final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        final String bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture');

        styleInfo = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        print('❌ Failed to load image for notification: $e');
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
      print('✅ Notification displayed!');
    } else {
      print('⚠️ Missing title or body. Notification not shown.');
    }
  }

  /// 🛠️ Download an image to local storage for big picture
  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = '${dir.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}
