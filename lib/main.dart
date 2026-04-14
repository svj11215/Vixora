/// Entry point for the Vixora apartment visitor management application.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vixora/core/constants/app_constants.dart';
import 'package:vixora/core/theme/app_theme.dart';
import 'package:vixora/firebase_options.dart';
import 'package:vixora/providers/auth_provider.dart' as app;
import 'package:vixora/providers/profile_provider.dart';
import 'package:vixora/providers/visitor_request_provider.dart';
import 'package:vixora/screens/auth/login_screen.dart';
import 'package:vixora/screens/guard/guard_home_screen.dart';
import 'package:vixora/screens/resident/resident_home_screen.dart';
import 'package:vixora/screens/splash_screen.dart';
import 'package:vixora/services/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Suppress animate_do debug logs in release mode
  if (kReleaseMode) {
    debugPrint = (String? message, {int? wrapWidth}) {};
  }

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const VixoraApp());
}

/// Root application widget with MultiProvider and Material 3 theme.
class VixoraApp extends StatelessWidget {
  const VixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => app.AuthProvider()),
        ChangeNotifierProvider(create: (_) => VisitorRequestProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.dark,
        initialRoute: AppConstants.routeSplash,
        routes: {
          AppConstants.routeSplash: (_) => const SplashScreen(),
          AppConstants.routeLogin: (_) => const LoginScreen(),
          AppConstants.routeGuardHome: (_) => const GuardHomeScreen(),
          AppConstants.routeResidentHome: (_) => const ResidentHomeScreen(),
        },
      ),
    );
  }
}
