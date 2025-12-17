// lib/features/records/records_page.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class RecordsPage extends BasePage {
  const RecordsPage({super.key});

  @override
  AppSection get section => AppSection.records;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('РЕКОРДЫ', accent: true),
      const TickerItem('ТОП',),
      _choice(r, const [
        TickerItem('ЛУЧШИЙ КРУГ'),
        TickerItem('СЕКТОРА'),
        TickerItem('СПЛИТЫ'),
        TickerItem('ПБ'),
        TickerItem('ФАСТЛАП'),
      ]),
      _choice(r, const [
        TickerItem('1%', accent: true),
        TickerItem('TOP 10', accent: true),
        TickerItem('WR', accent: true),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return const [
      Center(child: Text('РЕКОРДЫ')),
    ];
  }
}
