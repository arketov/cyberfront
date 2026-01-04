import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/fade_divider.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/sub_card.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:flutter/material.dart';

class PropCarCard extends CardBase {
  const PropCarCard({
    super.key,
    required this.carClass,
    required this.weight,
    required this.topspeed,
    required this.acceleration,
    required this.pwratio,
    required this.power,
    required this.torque,
    required this.range,
    required this.descr,
    List<String>? tags,
  }) : tags = tags ?? const [];

  final String carClass;
  final String power;
  final String torque;
  final String weight;
  final String topspeed;
  final String acceleration;
  final String pwratio;
  final String range;
  final String? descr;
  final List<String> tags;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
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

                  final cleanDescr = _cleanHtml(descr);
                  final hasDescr = cleanDescr != null && cleanDescr.trim().isNotEmpty;
                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                        hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      const Kicker('[ЭТО ПАРАМЕТРЫ]'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: itemSpacing,
                        runSpacing: itemSpacing,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'КЛАСС',
                              value: carClass,
                              tone: SubCardTone.blue,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'ВЕС',
                              value: weight,
                              tone: SubCardTone.blue,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'V-MAX',
                              value: topspeed,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: '0-100',
                              value: acceleration,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'P/W',
                              value: pwratio,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'МОЩНОСТЬ',
                              value: power,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'МОМЕНТ',
                              value: torque,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: SubCard(
                              title: 'ЗАПАС ХОДА',
                              value: range,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FadeDivider(),
                      const SizedBox(height: 10),
                      if (hasDescr)
                        SizedBox(
                          width: double.infinity,
                          child: MetaPill(
                            value: cleanDescr!.trim(),
                            padding: const EdgeInsets.all(15),
                            radius: 20,
                            valueFontWeight: FontWeight.w400,
                            contentAlignment: Alignment.centerLeft,
                            wrapAlignment: WrapAlignment.start,
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (tags.isNotEmpty)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var i = 0; i < tags.length; i++)
                              MetaPill(
                                value: tags[i].startsWith('#')
                                    ? tags[i]
                                    : '#${tags[i]}',
                                tone: i == 0
                                    ? MetaPillTone.pink
                                    : (i == 1
                                        ? MetaPillTone.blue
                                        : MetaPillTone.dark),
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

  String? _cleanHtml(String? value) {
    if (value == null) return null;
    var text = value;
    text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    text = text.replaceAll('&quot;', '"');
    text = text.replaceAll('&amp;', '&');
    text = text.replaceAll('&lt;', '<');
    text = text.replaceAll('&gt;', '>');
    text = text.replaceAll('&nbsp;', ' ');
    return text.trim();
  }
}
