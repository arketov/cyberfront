//lib/features/hello/cards/hello_price_card.dart
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/cards/card_base.dart';


class HelloPriceCard extends CardBase {
  const HelloPriceCard({super.key});

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFF1557FF);

  @override
  bool get backgroundGradientEnabled => false;

  @override
  BoxBorder? border(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    final lineStyle = TextStyle(
      height: 1.25,
      fontSize: 13.2,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: .85),
    );

    Widget line(String left, String right) {
      return Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: lineStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                right,
                style: lineStyle,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЭТО БАЗА]', color: Colors.white70),
        const SizedBox(height: 10),
        const Text(
          '600 ₽/час',
          style: TextStyle(
            height: .92,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        line('вдвоём', '500 ₽/час ×2'),
        line('втроём', '400 ₽/час ×3'),
        line('вчетвером', '300 ₽/час ×4'),
      ],
    );
  }
}
