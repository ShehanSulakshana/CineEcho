import 'package:cine_echo/screens/onboard_screen.dart';
import 'package:cine_echo/screens/home_screen.dart';
import 'package:cine_echo/providers/auth_provider.dart' as auth_provider;
import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/providers/navigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './themes/themedata.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class NoStretchBehavior extends MaterialScrollBehavior {
  const NoStretchBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => auth_provider.AuthenticationProvider(),
        ),
        ChangeNotifierProvider(create: (_) => TmdbProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CineEcho',
        theme: AppTheme.defaultTheme,
        home: Consumer<auth_provider.AuthenticationProvider>(
          builder: (context, authProvider, _) {
            return StreamBuilder(
              stream: authProvider.authStateChanges,
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (asyncSnapshot.data != null) {
                  return HomeScreen();
                } else {
                  return const OnboardScreen();
                }
              },
            );
          },
        ),
      ),
    );
  }
}
