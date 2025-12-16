// lib/app/app_router.dart
import 'package:flutter/material.dart';
import 'no_transition_page_route.dart';

import '../features/hello/hello_page.dart';
import '../features/tracks/tracks_page.dart';
import '../features/cars/cars_page.dart';
import '../features/records/records_page.dart';
import '../features/profile/profile_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/tracks':
        return NoTransitionPageRoute(builder: (_) => const TracksPage(), settings: settings);
      case '/cars':
        return NoTransitionPageRoute(builder: (_) => const CarsPage(), settings: settings);
      case '/records':
        return NoTransitionPageRoute(builder: (_) => const RecordsPage(), settings: settings);
      case '/profile':
        return NoTransitionPageRoute(builder: (_) => const ProfilePage(), settings: settings);
      case '/hello':
      default:
        return NoTransitionPageRoute(builder: (_) => const HelloPage(), settings: settings);
    }
  }
}
