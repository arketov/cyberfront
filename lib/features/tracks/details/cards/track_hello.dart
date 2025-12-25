// lib/features/hello/cards/hello_hero_card.dart
import 'package:cyberdriver/core/ui/card_base.dart';
import 'package:cyberdriver/core/ui/kicker.dart';
import 'package:cyberdriver/core/ui/track_meta_pills.dart';
import 'package:cyberdriver/generated/assets.dart';
import 'package:flutter/material.dart';



class HelloTrackCard extends CardBase {
  const HelloTrackCard({super.key});

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final secondaryBtnStyle = OutlinedButton.styleFrom(
      backgroundColor: Colors.black.withValues(alpha: .33),
      // затемнение/прозрачность
      foregroundColor: Colors.white.withValues(alpha: .88),
      side: BorderSide(color: Colors.grey.withValues(alpha: .25)),
      overlayColor: Colors.white.withValues(alpha: .06),
      // эффект нажатия/ховера
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w900),
    );

    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 100),
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
                  mainAxisSize: hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    const Kicker('[TRACK INFO]'),
                    const SizedBox(height: 8),
                    Text(
                      'Track Name',
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
                      children: [
                        MetaPill(label: 'FR', value: 'France'),
                        MetaPill(label: 'City', value: 'Le Castellet'),
                        MetaPill(label: 'Length', value: '5.8 km'),
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
    );
  }
}
