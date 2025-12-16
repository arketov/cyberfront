// lib/features/profile/profile_page.dart

import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  @override
  AppSection get section => AppSection.profile;

  @override
  Widget buildBody(BuildContext context) {
    return const Center(child: Text('Рекорды'));
  }
}
