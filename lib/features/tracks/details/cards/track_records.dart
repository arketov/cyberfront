// lib/features/hello/cards/hello_hero_card.dart
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/duration_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/group_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/personal_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:cyberdriver/shared/countries_ru.dart';
import 'package:flutter/material.dart';



class RecordsTrackCard extends CardBase {
  const RecordsTrackCard({
    super.key,
    required this.trackId
  });

  final int trackId;

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

                  final content = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize:
                    hasBoundedHeight ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      const Kicker('[ЭТО РЕКОРДЫ]'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          MetaPill(value: "Групповые", tone: MetaPillTone.pink),
                          MetaPill(value: "Выносливость"),
                          MetaPill(value: "Личные"),
                        ],
                      ),
                      const SizedBox(height: 10),

                      GroupRecordList(trackId: trackId, limit: 10),
                      DurationRecordList(trackId: trackId, limit: 10),
                      PersonalRecordList(trackId: trackId, limit: 10,),
                      if (hasBoundedHeight) const Spacer(),

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
