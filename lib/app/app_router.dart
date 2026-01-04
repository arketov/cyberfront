// lib/app/app_router.dart
import 'package:flutter/material.dart';
import 'no_transition_page_route.dart';

import '../features/hello/hello_page.dart';
import '../features/tracks/details/details_track.dart';
import '../features/tracks/tracks_page.dart';
import '../features/cars/cars_page.dart';
import '../features/cars/details/details_car.dart';
import '../features/records/records_page.dart';
import '../features/profile/profile_page.dart';
import '../shared/models/track_dto.dart';
import '../shared/models/car_dto.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? '';
    if (name.startsWith('/tracks/')) {
      final idStr = name.substring('/tracks/'.length);
      final id = int.tryParse(idStr);
      if (id != null) {
        final dto = settings.arguments is TrackDto ? settings.arguments as TrackDto : null;
        return NoTransitionPageRoute(
          builder: (_) => TrackDetailsPage(trackId: id, dto: dto),
          settings: settings,
        );
      }
    }
    if (name.startsWith('/cars/')) {
      final idStr = name.substring('/cars/'.length);
      final id = int.tryParse(idStr);
      if (id != null) {
        final dto = settings.arguments is CarDto ? settings.arguments as CarDto : null;
        return NoTransitionPageRoute(
          builder: (_) => CarDetailsPage(carId: id, dto: dto),
          settings: settings,
        );
      }
    }
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
