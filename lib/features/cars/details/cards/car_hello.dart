// lib/features/cars/details/cards/car_hello.dart
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:flutter/material.dart';

class HelloCarCard extends CardBase {
  const HelloCarCard({
    super.key,
    required this.name,
    required this.brand,
    required this.carClass,
    required this.pwratio,
  });

  final String name;
  final String brand;
  final String? carClass;
  final String? pwratio;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: .99),
                      Colors.black.withValues(alpha: .50),
                      Colors.black.withValues(alpha: .20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: contentPadding,
              child: LayoutBuilder(
                builder: (context, c) {
                  final isNarrow = c.maxWidth < 520;
                  final hasBoundedHeight = c.hasBoundedHeight;

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      const Kicker('[ЭТО МАШИНА]'),
                      const SizedBox(height: 8),
                      Text(
                        name,
                        style: TextStyle(
                          height: .92,
                          fontSize: isNarrow ? 40 : 54,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (hasBoundedHeight) const Spacer(),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          if (brand.trim().isNotEmpty)
                            MetaPill(label: 'Бренд', value: brand.trim()),
                          if (carClass != null && carClass!.trim().isNotEmpty)
                            MetaPill(label: 'Класс', value: carClass!.trim()),
                          if (pwratio != null && pwratio!.trim().isNotEmpty)
                            MetaPill(label: 'P/W', value: pwratio!.trim()),
                        ],
                      ),
                    ],
                  );

                  if (!hasBoundedHeight) {
                    return content;
                  }

                  return SizedBox(
                    height: c.maxHeight,
                    child: content,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
