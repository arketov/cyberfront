//lib/features/hello/cards/hello_promo_card.dart
import 'package:flutter/material.dart';
import 'hello_card_base.dart';
import 'hello_kicker.dart';

class HelloPromoCard extends HelloCardBase {
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
        const HelloKicker('[ЕСТЬ МОМЕНТИКИ]', color: Colors.white70),
        const SizedBox(height: 10),
        const Text(
          'МИНИМУМ\nВРЕМЕНИ',
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
