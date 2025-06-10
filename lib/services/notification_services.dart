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
    final token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && android != null) {
      String? imageUrl = notification.android?.imageUrl ?? message.data['image'];

      NotificationDetails notificationDetails;

      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String largeIconPath = await _downloadAndSaveFile(imageUrl, 'largeIcon');
        final bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(largeIconPath),
          largeIcon: FilePathAndroidBitmap(largeIconPath),
          contentTitle: notification.title,
          summaryText: notification.body,
        );

        final androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'logo', // <-- custom icon in drawable folder
          styleInformation: bigPictureStyleInformation,
        );

        notificationDetails = NotificationDetails(android: androidDetails);
      } else {
        final androidDetails = AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Used for important notifications',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'logo', // <-- custom icon
        );

        notificationDetails = NotificationDetails(android: androidDetails);
      }

      await flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: message.data['route'] ?? '',
      );
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
