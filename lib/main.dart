import 'package:aayo/firebase_options.dart';
import 'package:aayo/providers/approve_events_provider/event_registration_provider.dart';
import 'package:aayo/providers/approve_events_provider/guest_page_provider.dart';
import 'package:aayo/providers/home_screens_providers/add_post_provider.dart';
import 'package:aayo/providers/home_screens_providers/chat_provider.dart';
import 'package:aayo/providers/notifications/notification_provider.dart';
import 'package:aayo/providers/onording_login_screens_providers/favorite_category_provider.dart';
import 'package:aayo/providers/onording_login_screens_providers/google_signin_provider.dart';
import 'package:aayo/providers/onording_login_screens_providers/onboarding_provider.dart';
import 'package:aayo/providers/setting_screens_providers/event_provider.dart';
import 'package:aayo/providers/home_screens_providers/home_provider.dart';
import 'package:aayo/providers/setting_screens_providers/venue_provider.dart';
import 'package:aayo/providers/setting_screens_providers/write_to_us_provider.dart';
import 'package:aayo/providers/onording_login_screens_providers/user_profile_provider.dart';
import 'package:aayo/screens/login_and_onbording_screens/splash_screen.dart';
import 'package:aayo/services/notification_services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ✅ Notification plugins
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

/// ✅ Global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// ✅ Global notification plugin instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔧 Initializing Firebase...');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🔧 Registering background message handler...');
  FirebaseMessaging.onBackgroundMessage(NotificationService.firebaseMessagingBackgroundHandler);

  print('🔧 Initializing NotificationService...');
  await NotificationService.initialize();

  print('🔧 Initializing flutterLocalNotifications...');
  await _initializeLocalNotifications();

  print('🚀 Running app...');
  runApp(const MyApp());
}

/// ✅ Local Notifications Initialization
Future<void> _initializeLocalNotifications() async {
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initSettings =
  InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      final filePath = response.payload;
      if (filePath != null && filePath.isNotEmpty) {
        await OpenFile.open(filePath);
      }
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()..fetchAll()),
        ChangeNotifierProvider(create: (_) => ImageSelectionProvider()),
        ChangeNotifierProvider(create: (_) => FetchEditUserProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteCategoryProvider()),
        ChangeNotifierProvider(create: (_) => EventCreationProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => WriteToUsProvider()),
        ChangeNotifierProvider(create: (_) => VenueProvider()),
        ChangeNotifierProvider(create: (_) => AddPostProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => EventRegistrationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aayo App',
        navigatorKey: navigatorKey,
        home: SplashScreen(),
      ),
    );
  }
}
