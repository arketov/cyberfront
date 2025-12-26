//lib/features/hello/cards/hello_top_records_card.dart
import 'package:cyberdriver/core/ui/widgets/duration_record_list.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/group_record_list.dart';
import 'package:flutter/material.dart';
import '../../../core/ui/cards/card_base.dart';

class HelloTopRecordsCard extends CardBase {
  const HelloTopRecordsCard({super.key});

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Kicker('[ТОП РЕКОРДЫ]', color: cs.onSurface.withOpacity(.55)),
        const SizedBox(height: 10),
        Text(
          'ГРУППОВЫЕ РЕКОРДЫ',
          style: TextStyle(
            height: .92,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 12),

        const GroupRecordList(limit: 3),
      ],
    );
  }
}
