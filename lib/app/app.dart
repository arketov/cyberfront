// lib/app/app.dart

import 'package:flutter/material.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';
import 'package:cyberdriver/core/navigation/app_route_observer.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    _setOptimalDisplayMode();
  }

  Future<void> _setOptimalDisplayMode() async {
    try {
      final supported = await FlutterDisplayMode.supported;
      final active = await FlutterDisplayMode.active;

      final sameResolution =
      supported.where((m) => m.width == active.width && m.height == active.height).toList()
        ..sort((a, b) => b.refreshRate.compareTo(a.refreshRate));

      final mostOptimal = sameResolution.isNotEmpty ? sameResolution.first : active;
      await FlutterDisplayMode.setPreferredMode(mostOptimal);
    } catch (e) {
      debugPrint('[DisplayMode] Failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CyberDriver',
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      navigatorKey: AppRouter.navigatorKey,
      initialRoute: '/hello',
      onGenerateRoute: AppRouter.onGenerateRoute,
      navigatorObservers: [appRouteObserver], // <-- важно
      //showPerformanceOverlay: true,
    );
  }
}
