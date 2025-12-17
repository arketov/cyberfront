//lib/features/hello/cards/hello_price_card.dart
import 'package:flutter/material.dart';
import 'hello_card_base.dart';
import 'hello_kicker.dart';

class HelloPriceCard extends HelloCardBase {
  const HelloPriceCard({super.key});

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
        const HelloKicker('[ЭТО БАЗА]', color: Colors.white70),
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
        Text(
          'вдвоем        500 ₽/час x2\nвтроем        400 ₽/час х3\nвчетвером  300 ₽/час х4',
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
