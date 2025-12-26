//lib/features/hello/cards/hello_promo_card.dart
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/cards/card_base.dart';


class HelloPromoCard extends CardBase {
  const HelloPromoCard({super.key});

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFF1557FF);

  @override
  bool get backgroundGradientEnabled => false;

  @override
  BoxBorder? border(BuildContext context) => null;

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЕСТЬ МОМЕНТИКИ]', color: Colors.white70),
        const SizedBox(height: 10),
        const  Text(
          'МИНИМУМ ВРЕМЕНИ',
          style: TextStyle(
            height: .92,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),

        Text(
          'ДВА ЧАСА',
          style: TextStyle(
            height: 1.25,
            fontSize: 13.2,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(.85),
          ),
        ),
      ],
    );
  }
}
