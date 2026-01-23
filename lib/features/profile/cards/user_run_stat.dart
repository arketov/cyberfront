import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/features/profile/cards/widgets/favorite_run_card.dart';
import 'package:cyberdriver/features/profile/cards/widgets/run_stats_block.dart';
import 'package:flutter/material.dart';

class UserRunStat extends StatefulWidget {
  const UserRunStat({super.key});

  @override
  State<UserRunStat> createState() => _UserRunStatState();
}

class _UserRunStatState extends State<UserRunStat> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() => _expanded = !_expanded);
  }

  @override
  Widget build(BuildContext context) {
    return _UserRunStatCardShell(
      onTapCallback: _toggleExpanded,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final expandHintStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
      color: Colors.white.withValues(alpha: 0.55),
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Kicker('[ЭТО АГРЕГАЦИЯ]', color: Colors.white70),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final useSingleColumn = constraints.maxWidth < 600;
              final spacing = useSingleColumn ? 10.0 : 12.0;
              final blockAWidth = useSingleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) * 0.4;
              final rightWidth = useSingleColumn
                  ? constraints.maxWidth
                  : (constraints.maxWidth - spacing) * 0.6;

              final blockA = SizedBox(
                width: blockAWidth,
                child: const RunStatsBlock(
                  distanceMeters: 1284000,
                  durationMinutes: 988,
                  avgSpeedKmh: 78.5,
                ),
              );

              final rightColumn = SizedBox(
                width: rightWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FavoriteRunCard(
                      distance: 0,
                      duration: 0,
                      imageHash:
                          '90962a4aae41bc6821cf4279871443e940dc726f2b80f317846a255d5cb17ed2.jpg',
                      title: 'BMW 1M',
                      label: 'Любимая машина',
                    ),
                    const SizedBox(height: 10),
                    FavoriteRunCard(
                      distance: 0,
                      duration: 0,
                      imageHash:
                          'efff7492fbed8a0e7a078e472cad8bae3639af2683797bd18f5f0407a0cef886.png',
                      title: 'Nordschleife',
                      label: 'Любимый трек',
                      fadeRadius: 1.2,
                      fadeStops: const [0.0, 0.7, 1.0],
                    ),
                  ],
                ),
              );

              if (useSingleColumn) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    blockA,
                    SizedBox(height: spacing),
                    rightColumn,
                  ],
                );
              }

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    blockA,
                    SizedBox(width: spacing),
                    rightColumn,
                  ],
                ),
              );
            },
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Text('expanded placeholder'),
          ],
          SizedBox(height: _expanded ? 12 : 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  _expanded ? 'Свернуть' : 'Подробнее',
                  style: expandHintStyle,
                ),
                const SizedBox(width: 6),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRunStatCardShell extends CardBase {
  const _UserRunStatCardShell({
    required this.child,
    required this.onTapCallback,
  });

  final Widget child;
  final VoidCallback onTapCallback;

  @override
  VoidCallback? onTap(BuildContext context) => onTapCallback;

  @override
  Widget buildContent(BuildContext context) => child;
}
