// lib/features/records/records_page.dart

import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';

class RecordsPage extends BasePage {
  const RecordsPage({super.key});

  @override
  AppSection get section => AppSection.records;

  @override
  Widget buildBody(BuildContext context) {
    return const Center(child: Text('Рекорды'));
  }
}
