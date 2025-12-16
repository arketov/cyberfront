// lib/features/cars/cars_page.dart

import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';

class CarsPage extends BasePage {
  const CarsPage({super.key});

  @override
  AppSection get section => AppSection.cars;

  @override
  Widget buildBody(BuildContext context) {
    return const Center(child: Text('Рекорды'));
  }
}
