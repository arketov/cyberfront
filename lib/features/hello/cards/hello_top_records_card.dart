//lib/features/hello/cards/hello_top_records_card.dart
import 'package:flutter/material.dart';
import 'hello_card_base.dart';
import 'hello_kicker.dart';

class HelloTopRecordsCard extends HelloCardBase {
  const HelloTopRecordsCard({super.key});



  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HelloKicker('[ТОП РЕКОРДЫ]', color: cs.onSurface.withOpacity(.55)),
        const SizedBox(height: 10),
        Text(
          'ТОП\nСЕГОДНЯ',
          style: TextStyle(
            height: .92,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.6,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 12),
        _Row(
          index: 1,
          name: 'Денис',
          car: 'Porsche 911 · Nürburgring',
          time: '5:13',
        ),
        const SizedBox(height: 10),
        _Row(
          index: 2,
          name: 'Иван',
          car: 'Nissan GT-R · Azure',
          time: '5:51',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.index,
    required this.name,
    required this.car,
    required this.time,
  });

  final int index;
  final String name;
  final String car;
  final String time;


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.onSurface.withOpacity(.06),
            border: Border.all(color: cs.onSurface.withOpacity(.10)),
          ),
          child: Text(
            '$index',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: cs.onSurface.withOpacity(.85),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                car,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withOpacity(.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: cs.onSurface.withOpacity(.85),
          ),
        ),
      ],
    );
  }
}
