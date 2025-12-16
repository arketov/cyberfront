// lib/core/ui/base_page.dart

import 'package:flutter/widgets.dart';
import '../navigation/app_section.dart';
import 'app_scaffold.dart';

abstract class BasePage extends StatelessWidget {
  const BasePage({super.key});

  AppSection get section;
  String get title => section.label;

  /// Контент конкретной страницы
  Widget buildBody(BuildContext context);

  /// Экшены справа в AppBar (если надо)
  List<Widget> buildActions(BuildContext context) => const [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      current: section,
      title: title,
      actions: buildActions(context),
      child: buildBody(context),
    );
  }
}
