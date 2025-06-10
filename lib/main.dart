// main.dart
import 'package:aayo/firebase_options.dart';
import 'package:aayo/providers/chat_provider.dart';
import 'package:aayo/providers/event_provider.dart';
import 'package:aayo/providers/home_provider.dart';
import 'package:aayo/providers/favorite_category_provider.dart';
import 'package:aayo/providers/google_signin_provider.dart';
import 'package:aayo/providers/onboarding_provider.dart';
import 'package:aayo/providers/user_profile_provider.dart';
import 'package:aayo/providers/write_to_us_provider.dart';
import 'package:aayo/screens/splash_screen.dart';
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
        ChangeNotifierProvider(create: (_) => homeProvider()),
        ChangeNotifierProvider(create: (_) => ImageSelectionProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteCategoryProvider()),
        ChangeNotifierProvider(create: (_) => EventPostProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => WriteToUsProvider()),

      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aayo App',
        home: SplashScreen(), // Always show splash first
      ),
    );
  }
}
