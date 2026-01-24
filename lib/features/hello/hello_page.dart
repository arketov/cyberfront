import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';

import 'cards/hello_hero_card.dart';
import 'cards/hello_grid_section.dart';
import 'cards/hello_news_card.dart';
import 'cards/hello_stats_card.dart';

TickerItem choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class HelloPage extends BasePage {
  const HelloPage({super.key});

  @override
  AppSection get section => AppSection.hello;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      TickerItem('Просто текст'),
      TickerItem('Просто текст'),
      choice(r, const [
        TickerItem('КИБЕР ДЕНИС'),
        TickerItem('МУЖИКИ'),
        TickerItem('СТОЯЧИЕ НОСКИ'),
      ]),
      const TickerItem('КИБЕРВОДИЛЫ', accent: true),
      choice(r, const [
        TickerItem('ГОНКИ'),
        TickerItem('ТРАССЫ'),
        TickerItem('АДРЕНАЛАЙН'),
      ]),
      TickerItem('Просто текст'),
      TickerItem('Просто текст'),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return const [
      HelloHeroCard(),
      HelloNewsCard(),
      HelloGridSection(),
      HelloStatsCard(),
    ];
  }
}

