// lib/features/tracks/tracks_page.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class TracksPage extends BasePage {
  const TracksPage({super.key});

  @override
  AppSection get section => AppSection.tracks;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('ТРАССЫ'),
      const TickerItem('КАРТА', accent: true),
      _choice(r, const [
        TickerItem('СУХО'),
        TickerItem('МОКРО'),
        TickerItem('НОЧЬ'),
        TickerItem('ТРАФИК'),
        TickerItem('ДЛИНА'),
      ]),
      _choice(r, const [
        TickerItem('GT', accent: true),
        TickerItem('DRIFT', accent: true),
        TickerItem('RALLY', accent: true),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return const [
      Center(child: Text('Список трасс тут')),
    ];
  }
}
