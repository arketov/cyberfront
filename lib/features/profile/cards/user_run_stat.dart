import 'dart:io';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';

const Duration _cacheDuration = Duration(days: 1);
const double _thumbWidth = 65;
const double _thumbHeight = 36;

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
                child: Container(
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
                                  TextSpan(text: '1284 ', style: statValueStyle),
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
                                  TextSpan(text: '16', style: statValueStyle),
                                  TextSpan(text: 'ч', style: unitStyle),
                                  TextSpan(text: ' 28', style: statValueStyle),
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
                                  TextSpan(text: '78.5 ', style: statValueStyle),
                                  TextSpan(text: r'км\ч', style: unitStyle),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );

              final rightColumn = SizedBox(
                width: rightWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _thumbWidth,
                            height: _thumbHeight,
                            child: FutureBuilder<File>(
                              future: MediaCacheService.instance.getImageFile(
                                id: '90962a4aae41bc6821cf4279871443e940dc726f2b80f317846a255d5cb17ed2.jpg',
                                cacheDuration: _cacheDuration,
                                config: AppConfig.dev,
                              ),
                              builder: (context, snapshot) {
                                final file = snapshot.data;
                                if (file == null) {
                                  return const SizedBox.shrink();
                                }
                                return FittedBox(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  child: Image.file(file),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BMW 1M',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '0.0 КМ • 00:00.000',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: _thumbWidth,
                            height: _thumbHeight,
                            child: FutureBuilder<File>(
                              future: MediaCacheService.instance.getImageFile(
                                id: 'efff7492fbed8a0e7a078e472cad8bae3639af2683797bd18f5f0407a0cef886.png',
                                cacheDuration: _cacheDuration,
                                config: AppConfig.dev,
                              ),
                              builder: (context, snapshot) {
                                final file = snapshot.data;
                                if (file == null) {
                                  return const SizedBox.shrink();
                                }
                                return FittedBox(
                                  fit: BoxFit.contain,
                                  alignment: Alignment.center,
                                  child: Image.file(file),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nordschleife',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.95),
                                    height: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '0.0 КМ • 00:00.000',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.6),
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
