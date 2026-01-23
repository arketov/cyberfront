import 'package:flutter/material.dart';

import 'package:cyberdriver/shared/formatters/run_stats_format.dart';

class RunStatsBlock extends StatelessWidget {
  const RunStatsBlock({
    super.key,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.avgSpeedKmh,
  });

  final int distanceMeters;
  final int durationMinutes;
  final double avgSpeedKmh;

  @override
  Widget build(BuildContext context) {
    final statLabelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.7,
      color: Colors.white.withValues(alpha: 0.55),
    );
    final statValueStyle = Theme.of(context).textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.4,
      color: Colors.white.withValues(alpha: 0.92),
    );
    final unitStyle = statValueStyle?.copyWith(
      color: Colors.white.withValues(alpha: 0.72),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('ДИСТАНЦИЯ', style: statLabelStyle),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: RunStatsFormat.distanceKmValue(distanceMeters),
                        style: statValueStyle,
                      ),
                      TextSpan(text: ' ', style: statValueStyle),
                      TextSpan(text: 'км', style: unitStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('ВРЕМЯ', style: statLabelStyle),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: RunStatsFormat.durationHours(durationMinutes),
                        style: statValueStyle,
                      ),
                      TextSpan(text: 'ч', style: unitStyle),
                      TextSpan(text: ' ', style: statValueStyle),
                      TextSpan(
                        text: RunStatsFormat.durationMinutes(durationMinutes),
                        style: statValueStyle,
                      ),
                      TextSpan(text: 'м', style: unitStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 100,
                child: Text('СРЕДНЯЯ', style: statLabelStyle),
              ),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: avgSpeedKmh.toStringAsFixed(1), style: statValueStyle),
                      TextSpan(text: ' ', style: statValueStyle),
                      TextSpan(text: r'км\ч', style: unitStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Formatting helpers moved to RunStatsFormat.
}
