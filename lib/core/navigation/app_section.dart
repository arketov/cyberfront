// lib/core/navigation/app_section.dart
import 'package:flutter/material.dart';

enum AppSection {
  hello,
  news,
  tracks,
  cars,
  records,
  profile,
  admin, // опционально
}

extension AppSectionX on AppSection {
  String get label => switch (this) {
    AppSection.hello => 'ПРИВЕТ',
    AppSection.news => 'НОВОСТИ',
    AppSection.tracks => 'ТРАССЫ',
    AppSection.cars => 'МАШИНЫ',
    AppSection.records => 'РЕКОРДЫ',
    AppSection.profile => 'ПРОФИЛЬ',
    AppSection.admin => 'КИБЕРАДМИН',
  };

  IconData get icon => switch (this) {
    AppSection.hello => Icons.waving_hand_rounded,
    AppSection.news => Icons.newspaper_rounded,
    AppSection.tracks => Icons.route_rounded,
    AppSection.cars => Icons.directions_car_rounded,
    AppSection.records => Icons.emoji_events_rounded,
    AppSection.profile => Icons.person_rounded,
    AppSection.admin => Icons.admin_panel_settings_rounded,
  };

  String get route => switch (this) {
    AppSection.hello => '/hello',
    AppSection.news => '/news',
    AppSection.tracks => '/tracks',
    AppSection.cars => '/cars',
    AppSection.records => '/records',
    AppSection.profile => '/profile',
    AppSection.admin => '/admin',
  };

  bool get primary => switch (this) {
    AppSection.news => false,
    AppSection.admin => false,
    _ => true,
  };

  static List<AppSection> get primarySections =>
      AppSection.values.where((s) => s.primary).toList(growable: false);

  static List<AppSection> get desktopExtraSections =>
      const [AppSection.news, AppSection.admin];
}
