// lib/features/profile/profile_page.dart

import 'dart:math';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';
import 'package:marquee/marquee.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class ProfilePage extends BasePage {
  const ProfilePage({super.key});

  @override
  AppSection get section => AppSection.profile;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('ПРОФИЛЬ'),
      const TickerItem('КИБЕРВОДИЛА', accent: true),
      _choice(r, const [
        TickerItem('СТАТЫ'),
        TickerItem('ДОСТИЖЕНИЯ'),
        TickerItem('ЛИГА'),
        TickerItem('СЕЗОН'),
        TickerItem('РЕЙТИНГ'),
      ]),
      _choice(r, const [
        TickerItem('ПИН', accent: true),
        TickerItem('ПАС', accent: true),
        TickerItem('2FA', accent: true),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) {
    return [
      const Center(child: Text('ПРОФИЛЬ')),

    ];
  }
}
