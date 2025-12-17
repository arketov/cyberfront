//lib/features/hello/cards/hello_grid_section.dart
import 'package:cyberdriver/features/hello/cards/hello_price_card.dart';
import 'package:flutter/material.dart';

import 'hello_about_card.dart';
import 'hello_top_records_card.dart';
import 'hello_promo_card.dart';

class HelloGridSection extends StatelessWidget {
  const HelloGridSection({super.key});

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
              SizedBox(height: 12),
              HelloTopRecordsCard(),
              SizedBox(height: 12),
              HelloPromoCard(),
              SizedBox(height: 12),
              HelloPriceCard(),
            ],
          );
        }

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: HelloAboutCard()),
              SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    HelloTopRecordsCard(),
                    SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: const [
                          Expanded(child: HelloPriceCard()),
                          SizedBox(width: 12),
                          Expanded(child: HelloPromoCard()),
                        ],
                      ),
                    ),
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
