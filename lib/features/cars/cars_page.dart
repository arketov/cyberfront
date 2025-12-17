// lib/features/cars/cars_page.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class CarsPage extends BasePage {
  const CarsPage({super.key});

  @override
  AppSection get section => AppSection.cars;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('ГАРАЖ'),
      const TickerItem('ТАЧКИ', accent: true),
      _choice(r, const [
        TickerItem('СЕТАПЫ'),
        TickerItem('ТЮНИНГ'),
        TickerItem('ШИНЫ'),
        TickerItem('МОЩНОСТЬ'),
        TickerItem('ВЕС'),
      ]),
      _choice(r, const [
        TickerItem('RWD', accent: true),
        TickerItem('AWD', accent: true),
        TickerItem('FWD', accent: true),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return const [
      Center(child: Text('МАШИНЫ')),
    ];
  }
}
