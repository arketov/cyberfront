//lib/features/hello/cards/hello_stats_card.dart
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/cards/card_base.dart';

class HelloStatsCard extends CardBase {
  const HelloStatsCard({super.key});

  @override
  bool get backgroundGradientEnabled => false;

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFFA9A9A9);

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget stat(String value, String label) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[СТАТИСТИКА]', color: Colors.black54,),
        const SizedBox(height: 12),
        Row(
          children: [
            stat('4', 'КОКПИТА'),
            const SizedBox(width: 7),
            stat('69+', 'ТРАСС'),
            const SizedBox(width: 0),
            stat('1666', ' АВТО'),
            const SizedBox(width: 7),
            stat('27+', 'ДОРОГ'),
          ],
        ),
      ],
    );
  }
}
