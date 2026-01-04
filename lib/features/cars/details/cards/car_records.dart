// lib/features/cars/details/cards/car_records.dart
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/duration_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/group_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/personal_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/track_meta_pills.dart';
import 'package:flutter/material.dart';

class RecordsCarCard extends CardBase {
  const RecordsCarCard({
    super.key,
    required this.carId,
  });

  final int carId;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    return _RecordsCarContent(carId: carId);
  }
}

enum _RecordsTab { group, duration, personal }

class _RecordsCarContent extends StatefulWidget {
  const _RecordsCarContent({required this.carId});

  final int carId;

  @override
  State<_RecordsCarContent> createState() => _RecordsCarContentState();
}

class _RecordsCarContentState extends State<_RecordsCarContent> {
  _RecordsTab _tab = _RecordsTab.group;

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);

    Widget buildList() {
      switch (_tab) {
        case _RecordsTab.group:
          return GroupRecordList(carId: widget.carId, limit: 10);
        case _RecordsTab.duration:
          return DurationRecordList(carId: widget.carId, limit: 10);
        case _RecordsTab.personal:
          return PersonalRecordList(carId: widget.carId, limit: 10);
      }
    }

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
                          MetaPill(
                            value: 'Групповые',
                            tone: _tab == _RecordsTab.group
                                ? MetaPillTone.pink
                                : MetaPillTone.dark,
                            clickable: true,
                            onTap: () => setState(() {
                              _tab = _RecordsTab.group;
                            }),
                          ),
                          MetaPill(
                            value: 'Выносливость',
                            tone: _tab == _RecordsTab.duration
                                ? MetaPillTone.pink
                                : MetaPillTone.dark,
                            clickable: true,
                            onTap: () => setState(() {
                              _tab = _RecordsTab.duration;
                            }),
                          ),
                          MetaPill(
                            value: 'Личные',
                            tone: _tab == _RecordsTab.personal
                                ? MetaPillTone.pink
                                : MetaPillTone.dark,
                            clickable: true,
                            onTap: () => setState(() {
                              _tab = _RecordsTab.personal;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      buildList(),
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
