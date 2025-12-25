import 'package:cyberdriver/core/ui/card_base.dart';
import 'package:cyberdriver/core/ui/kicker.dart';
import 'package:cyberdriver/core/ui/sub_card.dart';
import 'package:flutter/material.dart';

class PropTrackCard extends CardBase {
  const PropTrackCard({
    super.key,
    required this.width,
    required this.pitboxes,
    required this.year,
    required this.run,
  });

  final String width;
  final String pitboxes;
  final String year;
  final String run;

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
                  const itemSpacing = 10.0;
                  final columns = c.maxWidth < 200 ? 1 : (isNarrow ? 2 : 4);
                  final itemWidth =
                      (c.maxWidth - (itemSpacing * (columns - 1))) / columns;

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: hasBoundedHeight
                        ? MainAxisSize.max
                        : MainAxisSize.min,
                    children: [
                      const Kicker('[ЭТО ПАРАМЕТРЫ]'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: itemSpacing,
                        runSpacing: itemSpacing,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(title: 'ШИРИНА', value: width,),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'ПИТБОКСЫ',
                              value: pitboxes,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(title: 'ГОД', value: year),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'НАПРАВЛЕНИЕ',
                              value: run,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );

                  if (!hasBoundedHeight) {
                    return content;
                  }

                  return SizedBox(height: c.maxHeight, child: content);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
