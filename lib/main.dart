// main.dart
import 'package:aayo/firebase_options.dart';
import 'package:aayo/providers/home_screens_providers/add_post_provider.dart';
import 'package:aayo/providers/home_screens_providers/chat_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(NotificationService.firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
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



      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aayo App',
        home: SplashScreen(), // Always show splash first
      ),
    );
  }
}
