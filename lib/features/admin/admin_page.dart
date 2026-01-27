// lib/features/admin/admin_page.dart
import 'dart:math';
import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/features/admin/cards/admin_active_sessions_card.dart';
import 'package:cyberdriver/features/admin/cards/admin_news_form_card.dart';
import 'package:cyberdriver/features/admin/cards/admin_reg_tokens_card.dart';
import 'package:flutter/material.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class AdminPage extends BasePage {
  const AdminPage({super.key});

  @override
  AppSection get section => AppSection.admin;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('КИБЕРЛУВР',),
      const TickerItem('КИБЕРДЕНИС',),
      const TickerItem('АДМИН', accent: true),
      _choice(r, const [
        TickerItem('СЕССИИ'),
        TickerItem('НОВОСТИ'),
        TickerItem('ПОЛЬЗОВАТЕЛИ'),
        TickerItem('МОДЕРАЦИЯ'),
      ]),
      const TickerItem('АДМИН', accent: true),
      const TickerItem('КИБЕРДЕНИСИС',),
      const TickerItem('КИБЕРБОГ',),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) => [
        const _AdminPlaceholderCard(),
        AdminNewsFormCard(),
        AdminRegTokensCard(),
        AdminActiveSessionsCard(),
      ];
}

class _AdminPlaceholderCard extends CardBase {
  const _AdminPlaceholderCard();

  @override
  Widget buildContent(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.75),
          fontWeight: FontWeight.w700,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[КИБЕРАДМИН]', color: Colors.white70),
        const SizedBox(height: 10),
        Text('Привет, Денис. Я Админ панель. Хоть я и не красивая, но я пытаюсь быть функциональной', style: textStyle),
      ],
    );
  }
}
