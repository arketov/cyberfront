import 'dart:io';

import 'package:flutter/material.dart';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/stat_donut.dart';
import 'package:cyberdriver/core/ui/widgets/sub_card.dart';
import 'package:cyberdriver/shared/models/user_dto.dart';
import 'package:cyberdriver/shared/models/user_stats_dto.dart';
import 'package:cyberdriver/shared/stats_descripton.dart';

const double _avatarSize = 64.0;
const Duration _cacheDuration = Duration(days: 1);

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    super.key,
    required this.user,
    this.statsLoader,
  });

  final UserDto? user;
  final Future<UserStatsDto> Function()? statsLoader;

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  bool _expanded = false;
  bool _loading = false;
  UserStatsDto? _stats;
  String? _statsError;

  void _toggleExpanded() {
    final next = !_expanded;
    setState(() => _expanded = next);
    if (next) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    if (_loading || _stats != null) return;
    final loader = widget.statsLoader;
    if (loader == null) return;
    setState(() {
      _loading = true;
      _statsError = null;
    });

    try {
      final stats = await loader();
      if (!mounted) return;
      setState(() => _stats = stats);
    } catch (e) {
      if (!mounted) return;
      setState(() => _statsError = 'Ошибка статистики: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ProfileCardShell(
      onTapCallback: _toggleExpanded,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.user == null) {
      return const Text('Нет данных пользователя');
    }

    final textTheme = Theme.of(context).textTheme;

    final titleStyle = textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w900,
    );

    final metaLabelStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
      color: Colors.white.withValues(alpha: 0.60),
    );

    final metaValueStyle = textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: 0.9,
      color: Colors.white.withValues(alpha: 0.68),
    );

    final user = widget.user!;
    final displayName = user.name.isEmpty ? user.login : user.name;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЭТО ТЫ]', color: Colors.white70),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileAvatar(
              imageHash: user.imageHash,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(displayName, style: titleStyle),
                  const SizedBox(height: 4),
                  _MetaLine(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    span: TextSpan(
                      children: [
                        _kv(
                          'LOGIN',
                          user.login,
                          metaLabelStyle,
                          metaValueStyle,
                        ),
                        _dot(metaLabelStyle),
                        _kv(
                          'EMAIL',
                          user.email,
                          metaLabelStyle,
                          metaValueStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  _MetaLine(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    span: TextSpan(
                      children: [
                        _kv('REGISTERED', '', metaLabelStyle, metaValueStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const _StatGrid(
          items: [
            // _StatItem('aga', 'ugu', SubCardTone.pink),
          ],
        ),
        if (_expanded) ...[
          const SizedBox(height: 14),
          _buildStatsBlock(context),
        ],
      ],
    );
  }

  Widget _buildStatsBlock(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_statsError != null) {
      return Text(
        _statsError!,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.redAccent),
      );
    }
    final stats = _stats;
    if (stats == null) {
      return Text(
        'Нет статистики',
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
      );
    }

    final donutWidgets = <Widget>[
      StatDonut(
        label: 'КИБЕРНУТОСТЬ',
        value: stats.carefuness.round(),
        tooltipText: StatsDescriptions.carefuness,
      ),
      StatDonut(
        label: 'ГЛАДКИЕ РУЧКИ',
        value: stats.smoofhands.round(),
        tooltipText: StatsDescriptions.smoofhands,
      ),
      StatDonut(
        label: 'ГЛАДКИЕ НОЖКИ',
        value: stats.smooffeet.round(),
        tooltipText: StatsDescriptions.smooffeet,
      ),
      StatDonut(
        label: 'ЧЁТКИЙ ТОРМОЗ',
        value: stats.braketheshold.round(),
        tooltipText: StatsDescriptions.braketheshold,
      ),
      StatDonut(
        label: 'ПОВОРОТНЫЙ ТОРМОЗ',
        value: stats.trailbrake.round(),
        tooltipText: StatsDescriptions.trailbrake,
      ),
      StatDonut(
        label: 'ЧЁТКИЙ ГАЗ',
        value: stats.throttlecontrol.round(),
        tooltipText: StatsDescriptions.throttlecontrol,
      ),
      StatDonut(
        label: 'ПОВОРОТНЫЙ МАСТЕР',
        value: stats.cornerbalance.round(),
        tooltipText: StatsDescriptions.cornerbalance,
      ),
      StatDonut(
        label: 'ЧИСТОТА ТРЕКА',
        value: stats.tracklimit.round(),
        tooltipText: StatsDescriptions.tracklimit,
      ),
      StatDonut(
        label: 'КОНТРАВАРИЙКА',
        value: stats.recovery.round(),
        tooltipText: StatsDescriptions.recovery,
      ),
      StatDonut(
        label: 'СИМПАТИЯ К ШИНАМ',
        value: stats.tyresympathy.round(),
        tooltipText: StatsDescriptions.tyresympathy,
      ),
      StatDonut(
        label: 'СТИЛЬ ПАРЕБРИК',
        value: stats.kerbstyle.round(),
        tooltipText: StatsDescriptions.kerbstyle,
      ),
      StatDonut(
        label: 'СТАБИЛЬНОСТЬ',
        value: stats.consistency.round(),
        tooltipText: StatsDescriptions.consistency,
      ),
      StatDonut(
        label: 'АБС',
        value: stats.absenabled.round(),
        tooltipText: StatsDescriptions.absenabled,
      ),
      StatDonut(
        label: 'ТРЕКШН',
        value: stats.tcenabled.round(),
        tooltipText: StatsDescriptions.tcenabled,
      ),
      StatDonut(
        label: 'АВТОМАТ',
        value: stats.autoshift.round(),
        tooltipText: StatsDescriptions.autoshift,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StretchWrap(
          minItemWidth: 90,
          spacing: 14,
          runSpacing: 12,
          itemCount: donutWidgets.length,
          itemBuilder: (itemWidth, index) {
            return SizedBox(
              width: itemWidth,
              child: donutWidgets[index],
            );
          },
        ),
      ],
    );
  }
}


class _ProfileCardShell extends CardBase {
  const _ProfileCardShell({
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

class _StatItem {
  const _StatItem(this.title, this.value, this.tone);

  final String title;
  final String value;
  final SubCardTone tone;
}

class _StretchWrap extends StatelessWidget {
  const _StretchWrap({
    required this.minItemWidth,
    required this.spacing,
    required this.runSpacing,
    required this.itemCount,
    required this.itemBuilder,
  });

  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final int itemCount;
  final Widget Function(double itemWidth, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final raw = (maxWidth + spacing) / (minItemWidth + spacing);
        final columns = raw.floor().clamp(1, itemCount);
        final itemWidth =
            (maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (var i = 0; i < itemCount; i++)
              SizedBox(
                width: itemWidth,
                child: itemBuilder(itemWidth, i),
              ),
          ],
        );
      },
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.items});

  final List<_StatItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTwoColumn = constraints.maxWidth >= 360;
        if (!isTwoColumn) {
          return Column(
            children: [
              for (final item in items) ...[
                SubCard(title: item.title, value: item.value, tone: item.tone),
                if (item != items.last) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < items.length; i += 2) {
          final left = items[i];
          final right = i + 1 < items.length ? items[i + 1] : null;
          rows.add(
            Row(
              children: [
                Expanded(
                  child: SubCard(
                    title: left.title,
                    value: left.value,
                    tone: left.tone,
                  ),
                ),
                if (right != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: SubCard(
                      title: right.title,
                      value: right.value,
                      tone: right.tone,
                    ),
                  ),
                ],
              ],
            ),
          );
          if (i + 2 < items.length) {
            rows.add(const SizedBox(height: 12));
          }
        }

        return Column(children: rows);
      },
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.span, this.maxLines, this.overflow});

  final InlineSpan span;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      span,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }
}

TextSpan _kv(
  String label,
  String value,
  TextStyle? labelStyle,
  TextStyle? valueStyle,
) {
  return TextSpan(
    children: [
      TextSpan(text: '$label: ', style: labelStyle),
      TextSpan(text: value.isEmpty ? '—' : value, style: valueStyle),
    ],
  );
}

TextSpan _dot(TextStyle? style) => TextSpan(text: ' • ', style: style);

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.imageHash,
  });

  final String imageHash;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: const Icon(Icons.person, size: 28),
    );

    if (imageHash.isEmpty) {
      return placeholder;
    }

    return FutureBuilder<File>(
      future: MediaCacheService.instance.getImageFile(
        id: imageHash,
        cacheDuration: _cacheDuration,
        config: AppConfig.dev,
      ),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return placeholder;
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.file(
            file,
            width: _avatarSize,
            height: _avatarSize,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
