import 'dart:math' as math;

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/features/records/data/records_api.dart';
import 'package:cyberdriver/shared/models/record_group_dto.dart';
import 'package:flutter/material.dart';

class GroupRecordList extends StatefulWidget {
  const GroupRecordList({
    super.key,
    this.trackId,
    this.limit,
  });

  final int? trackId;
  final int? limit;

  @override
  State<GroupRecordList> createState() => _GroupRecordListState();
}

class _GroupRecordListState extends State<GroupRecordList> {
  static const double _wideBp = 250;

  late final RecordsApi _api;

  /// Кэшируем Future по trackId+limit, чтобы не дергать API на каждый rebuild.
  final Map<_RecordsKey, Future<List<RecordGroupDto>>> _futureByKey = {};

  @override
  void initState() {
    super.initState();
    final client = createApiClient(AppConfig.dev);
    _api = RecordsApi(client);
  }

  Future<List<RecordGroupDto>> _getFuture(int limit, int? trackId) {
    final key = _RecordsKey(limit, trackId);
    return _futureByKey.putIfAbsent(
      key,
      () => _api.getTopGroups(limit: limit, trackId: trackId),
    );
  }

  void _retry(int limit, int? trackId) {
    final key = _RecordsKey(limit, trackId);
    setState(() {
      _futureByKey.remove(key);
      _futureByKey[key] = _api.getTopGroups(limit: limit, trackId: trackId);
    });
  }

  @override
  void didUpdateWidget(covariant GroupRecordList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.limit != widget.limit || oldWidget.trackId != widget.trackId) {
      _futureByKey.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _wideBp;
        final int visibleCount = isWide ? 3 : 5;
        final int limit = widget.limit ?? visibleCount;
        final int? trackId = widget.trackId;

        return FutureBuilder<List<RecordGroupDto>>(
          future: _getFuture(limit, trackId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: CyberDotsLoader(width: 120, height: 44),
                ),
              );
            }

            if (snap.hasError) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Не удалось загрузить топ рекордов',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(.75),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _retry(limit, trackId),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            final items = snap.data ?? const <RecordGroupDto>[];
            if (items.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Пока нет рекордов',
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }

            final shown = items.take(limit).toList(growable: false);

            return Column(
              children: [
                for (var i = 0; i < shown.length; i++) ...[
                  GroupRecordRow(
                    recordId: shown[i].id,
                    trackName: shown[i].track.name,
                    country: shown[i].track.country,
                    lapTimeSeconds: shown[i].lapTime,
                    minMassPowerRatio: shown[i].minMassPowerRatio,
                    participantsCount: shown[i].participants.length,
                  ),
                  if (i != shown.length - 1) const SizedBox(height: 10),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _RecordsKey {
  const _RecordsKey(this.limit, this.trackId);

  final int limit;
  final int? trackId;

  @override
  bool operator ==(Object other) {
    return other is _RecordsKey &&
        other.limit == limit &&
        other.trackId == trackId;
  }

  @override
  int get hashCode => Object.hash(limit, trackId);
}

class GroupRecordRow extends StatelessWidget {
  const GroupRecordRow({
    super.key,
    required this.recordId,
    required this.trackName,
    required this.country,
    required this.lapTimeSeconds,
    required this.minMassPowerRatio,
    required this.participantsCount,
    this.height,
    this.padding = const EdgeInsets.all(12),
    this.radius = 15,
    this.accent = false,
    this.formatLapTime,
    this.formatRatio,
    this.formatParticipants,
    this.onTap,
  });

  final int recordId;
  final String trackName;
  final String country;

  /// Ожидается В СЕКУНДАХ. Если API даёт миллисекунды — передавай dto.lapTime / 1000.0
  final double lapTimeSeconds;

  final double minMassPowerRatio;
  final int participantsCount;

  /// Высота строки (не обязательна). Если null — по контенту, но минимум всё равно есть.
  final double? height;

  final EdgeInsetsGeometry padding;
  final double radius;

  /// Для выделения (например топ-1).
  final bool accent;

  /// Если хочешь свой формат времени/ratio/участников — передай форматтер.
  final VoidCallback? onTap;

  final String Function(double seconds)? formatLapTime;
  final String Function(double ratio)? formatRatio;
  final String Function(int count)? formatParticipants;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final lapText = (formatLapTime ?? _defaultLapTime)(lapTimeSeconds);
    final ratioText = (formatRatio ?? _defaultRatio)(minMassPowerRatio);
    final _ = (formatParticipants ?? _defaultParticipants)(participantsCount);

    void open() {
      if (onTap != null) return onTap!();
      Navigator.of(context).pushNamed('/record/group/$recordId');
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: open,
        child: LayoutBuilder(
          builder: (context, c) {
            final h = height ??
                (c.maxHeight.isFinite && c.maxHeight > 0 ? c.maxHeight : 56.0);
            final w = c.maxWidth.isFinite ? c.maxWidth : 320.0;
            final k = (w / h).clamp(4.0, 10.0);

            return Container(
              constraints: BoxConstraints(minHeight: height ?? 56),
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: cs.surface.withOpacity(0.10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.55),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  begin: Alignment(-1, -k),
                  end: Alignment(1, k),
                  colors: [
                    (accent ? const Color(0xFFFF2BD6) : Colors.white)
                        .withOpacity(0.10),
                    Colors.white.withOpacity(0.03),
                    Colors.black.withOpacity(0.18),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
              child: Padding(
                padding: padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: 0.2,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            country,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface.withOpacity(.55),
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          lapText,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface.withOpacity(.92),
                            letterSpacing: 0.2,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ratioText,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withOpacity(.60),
                            height: 1.0,
                          ),
                        ),
                        // если надо вернуть:
                        // const SizedBox(height: 4),
                        // Text(pplText, style: ...)
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static String _defaultLapTime(double seconds) {
    if (seconds.isNaN || seconds.isInfinite || seconds < 0) return '—';

    final totalMs = (seconds * 1000).round();
    final totalSec = totalMs ~/ 1000;

    final s = totalSec % 60;
    final totalMin = totalSec ~/ 60;
    final m = totalMin % 60;
    final h = totalMin ~/ 60;

    String two(int v) => v.toString().padLeft(2, '0');

    if (h > 0) {
      return '${h}:${two(m)}:${two(s)}';
    }
    return '${two(m)}:${two(s)}';
  }

  static String _defaultRatio(double r) {
    if (r.isNaN || r.isInfinite || r <= 0) return 'ЛИГА: ';
    return 'ЛИГА: ${r.toStringAsFixed(2)}';
  }

  static String _defaultParticipants(int n) {
    if (n <= 0) return 'участников: —';
    return 'участников: $n';
  }
}
