//lib/features/hello/cards/hello_grid_section.dart
import 'package:cyberdriver/core/ui/equal_height_row.dart';
import 'package:cyberdriver/features/hello/cards/hello_price_card.dart';
import 'package:flutter/material.dart';

import 'hello_about_card.dart';
import 'hello_top_records_card.dart';
import 'hello_promo_card.dart';

class HelloGridSection extends StatelessWidget {
  const HelloGridSection({super.key});
  static const _gap = 12.0;
  static const _smallH = 148.0; // жёстко одинаковая высота Price/Promo

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 560;

        if (isNarrow) {
          return const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HelloAboutCard(),
              SizedBox(height: _gap),
              HelloTopRecordsCard(),
              SizedBox(height: _gap),
              HelloPromoCard(),
              SizedBox(height: _gap),
              HelloPriceCard(),
            ],
          );
        }

        return EqualHeightRow(
          gap: _gap,
          leftFlex: 4,
          rightFlex: 4,
          left: const HelloAboutCard(), // теперь он будет растягиваться вниз
          right: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HelloTopRecordsCard(),
              const SizedBox(height: _gap),
              SizedBox(
                height: _smallH,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: const [
                    Expanded(child: HelloPriceCard()),
                    SizedBox(width: _gap),
                    Expanded(child: HelloPromoCard()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}