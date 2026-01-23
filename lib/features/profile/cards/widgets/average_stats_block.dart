import 'package:flutter/material.dart';

import 'package:cyberdriver/shared/formatters/run_stats_format.dart';

class AverageStatsBlock extends StatelessWidget {
  const AverageStatsBlock({
    super.key,
    required this.carMeters,
    required this.carDuration,
    required this.trackMeters,
    required this.trackDuration,
  });

  final int carMeters;
  final int carDuration;
  final int trackMeters;
  final int trackDuration;

  @override
  Widget build(BuildContext context) {
    final sectionLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.7,
      color: Colors.white.withValues(alpha: 0.6),
    );
    final itemLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.6),
    );
    final itemValueStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: Colors.white.withValues(alpha: 0.92),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('СРЕДНИЕ', style: sectionLabelStyle),
          const SizedBox(height: 10),
          _AverageRow(
            label: 'НА МАШИНЕ',
            value: _formatSummary(carMeters, carDuration),
            labelStyle: itemLabelStyle,
            valueStyle: itemValueStyle,
          ),
          const SizedBox(height: 10),
          _AverageRow(
            label: 'НА ТРАССЕ',
            value: _formatSummary(trackMeters, trackDuration),
            labelStyle: itemLabelStyle,
            valueStyle: itemValueStyle,
          ),
        ],
      ),
    );
  }

  static String _formatSummary(int meters, int minutes) {
    return '${RunStatsFormat.distanceKmLabel(meters)} • '
        '${RunStatsFormat.durationLong(minutes)}';
  }
}

class _AverageRow extends StatelessWidget {
  const _AverageRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
