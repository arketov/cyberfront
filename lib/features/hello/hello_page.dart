// lib/features/hello/hello_page.dart

import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';

class HelloPage extends BasePage {
  const HelloPage({super.key});

  @override
  AppSection get section => AppSection.hello;

  @override
  Widget buildBody(BuildContext context) {
    final p = Theme.of(context).extension<AppPalette>()!;
    return Column(
        children: [

          InfiniteTickerBar(
            height: 44,
            fontSize: 14,
            pixelsPerSecond: 55,
            separatorGap: 18,
            normalColor: p.muted,
            accentColor: p.pink,
            separatorColor: p.muted2,
            borderColor: p.line,
            items: const [
              TickerItem('КИБЕРВОДИЛЫ', accent: true, style: TextStyle(fontWeight: FontWeight.w900)),
              TickerItem('АВТОСИМУЛЯТОР ДЛЯ ЦЕНИТЕЛЕЙ', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          Center(child: Text('Дарова заебал')),

    ]);
  }
}