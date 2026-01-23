import 'package:flutter/material.dart';

import 'package:cyberdriver/core/ui/widgets/gradient_progress_bar.dart';

class CoverageStatsBlock extends StatelessWidget {
  const CoverageStatsBlock({
    super.key,
    required this.carCount,
    required this.carTotal,
    required this.trackCount,
    required this.trackTotal,
  });

  final int carCount;
  final int carTotal;
  final int trackCount;
  final int trackTotal;

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
    final progressMetaStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.7),
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
          Text('ОХВАТ', style: sectionLabelStyle),
          const SizedBox(height: 10),
          _CoverageRow(
            label: 'МАШИНЫ',
            count: carCount,
            total: carTotal,
            labelStyle: itemLabelStyle,
            metaStyle: progressMetaStyle,
          ),
          const SizedBox(height: 10),
          _CoverageRow(
            label: 'ТРАССЫ',
            count: trackCount,
            total: trackTotal,
            labelStyle: itemLabelStyle,
            metaStyle: progressMetaStyle,
          ),
        ],
      ),
    );
  }
}

class _CoverageRow extends StatelessWidget {
  const _CoverageRow({
    required this.label,
    required this.count,
    required this.total,
    required this.labelStyle,
    required this.metaStyle,
  });

  final String label;
  final int count;
  final int total;
  final TextStyle? labelStyle;
  final TextStyle? metaStyle;

  @override
  Widget build(BuildContext context) {
    final progress = total <= 0 ? 0.0 : (count / total) * 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 78, child: Text(label, style: labelStyle)),
            const Spacer(),
            Text('$count/$total', style: metaStyle),
          ],
        ),
        const SizedBox(height: 6),
        GradientProgressBar(
          value: progress,
          height: 6,
          width: double.infinity,
        ),
      ],
    );
  }
}
