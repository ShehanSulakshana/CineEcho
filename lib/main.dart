import 'package:cine_echo/screens/onboard_screen.dart';
import 'package:cine_echo/screens/home_screen.dart';
import 'package:cine_echo/providers/auth_provider.dart' as auth_provider;
import 'package:cine_echo/providers/tmdb_provider.dart';
import 'package:cine_echo/providers/navigation_provider.dart';
import 'package:cine_echo/providers/connectivity_provider.dart';
import 'package:cine_echo/widgets/network_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './themes/themedata.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RestartWidget(child: MyApp()));
}

class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
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
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
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
                  return const _HomeScreenWithConnectivity();
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

class _HomeScreenWithConnectivity extends StatefulWidget {
  const _HomeScreenWithConnectivity();

  @override
  State<_HomeScreenWithConnectivity> createState() =>
      _HomeScreenWithConnectivityState();
}

class _HomeScreenWithConnectivityState
    extends State<_HomeScreenWithConnectivity> {
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        final hasNetworkIssue =
            !connectivityProvider.isConnected ||
            connectivityProvider.hasNetworkError;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hasNetworkIssue && mounted) {
            _showNetworkDialog(context, connectivityProvider);
          }
        });

        return HomeScreen();
      },
    );
  }

  void _showNetworkDialog(
    BuildContext context,
    ConnectivityProvider connectivityProvider,
  ) {
    if (!mounted || _isDialogShowing) return;

    _isDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return NetworkDialog(
          onReload: () {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }

            connectivityProvider.clearError();

            RestartWidget.restartApp(context);
          },
        );
      },
    ).then((_) {
      _isDialogShowing = false;
    });
  }
}
