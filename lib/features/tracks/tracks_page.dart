// lib/features/tracks/tracks_page.dart

import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';

class TracksPage extends BasePage {
  const TracksPage({super.key});

  @override
  AppSection get section => AppSection.tracks;

  @override
  Widget buildBody(BuildContext context) {
    return const Center(child: Text('Список трасс тут'));
  }
}
