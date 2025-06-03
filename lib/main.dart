import 'package:aayo/providers/onboarding_provider.dart';
import 'package:aayo/providers/user_profile_provider.dart';
import 'package:aayo/screens/home_screen.dart';
import 'package:aayo/screens/loginandregister.dart';
import 'package:aayo/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => ImageSelectionProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider())
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Aayo App',
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show loading indicator while checking auth state
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              // User is logged in
              return const HomeScreen();
            } else {
              // User is NOT logged in
              return const SplashScreen();
            }
          },
        ),
      ),
    );
  }
}
