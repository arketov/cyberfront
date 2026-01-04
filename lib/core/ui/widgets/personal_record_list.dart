import 'dart:math' as math;

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/features/records/data/records_api.dart';
import 'package:cyberdriver/shared/models/record_personal_dto.dart';
import 'package:flutter/material.dart';

class PersonalRecordList extends StatefulWidget {
  const PersonalRecordList({
    super.key,
    this.trackId,
    this.carId,
    this.limit,
  });

  final int? trackId;
  final int? carId;
  final int? limit;

  @override
  State<PersonalRecordList> createState() => _PersonalRecordListState();
}

class _PersonalRecordListState extends State<PersonalRecordList> {
  static const double _wideBp = 250;

  late final RecordsApi _api;

  /// Кэшируем Future по trackId/carId+limit, чтобы не дергать API на каждый rebuild.
  final Map<_RecordsKey, Future<List<RecordPersonalDto>>> _futureByKey = {};

  @override
  void initState() {
    super.initState();
    final client = createApiClient(AppConfig.dev);
    _api = RecordsApi(client);
  }

  Future<List<RecordPersonalDto>> _getFuture(int limit, int? trackId, int? carId) {
    final key = _RecordsKey(limit, trackId, carId);
    return _futureByKey.putIfAbsent(
      key,
      () => _api.getTopPersonal(limit: limit, trackId: trackId, carId: carId),
    );
  }

  void _retry(int limit, int? trackId, int? carId) {
    final key = _RecordsKey(limit, trackId, carId);
    setState(() {
      _futureByKey.remove(key);
      _futureByKey[key] = _api.getTopPersonal(limit: limit, trackId: trackId, carId: carId);
    });
  }

  @override
  void didUpdateWidget(covariant PersonalRecordList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.limit != widget.limit ||
        oldWidget.trackId != widget.trackId ||
        oldWidget.carId != widget.carId) {
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
        final int? carId = widget.carId;

        return FutureBuilder<List<RecordPersonalDto>>(
          future: _getFuture(limit, trackId, carId),
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
                      onPressed: () => _retry(limit, trackId, carId),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            final items = snap.data ?? const <RecordPersonalDto>[];
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
                  PersonalRecordRow(
                    recordId: shown[i].id,
                    trackName: shown[i].track.name,
                    userName: shown[i].user.name,
                    lapTimeSeconds: shown[i].lapTime,
                    carName: '${shown[i].car.brand} ${shown[i].car.model}',
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
  const _RecordsKey(this.limit, this.trackId, this.carId);

  final int limit;
  final int? trackId;
  final int? carId;

  @override
  bool operator ==(Object other) {
    return other is _RecordsKey &&
        other.limit == limit &&
        other.trackId == trackId &&
        other.carId == carId;
  }

  @override
  int get hashCode => Object.hash(limit, trackId, carId);
}

class PersonalRecordRow extends StatelessWidget {
  const PersonalRecordRow({
    super.key,
    required this.recordId,
    required this.trackName,
    required this.userName,
    required this.lapTimeSeconds,
    required this.carName,
    this.height,
    this.padding = const EdgeInsets.all(12),
    this.radius = 15,
    this.accent = false,
    this.formatLapTime,
    this.formatCar,
    this.onTap,
  });

  final int recordId;
  final String trackName;
  final String userName;

  /// Ожидается В СЕКУНДАХ. Если API даёт миллисекунды — передавай dto.lapTime / 1000.0
  final double lapTimeSeconds;

  final String carName;

  /// Высота строки (не обязательна). Если null — по контенту, но минимум всё равно есть.
  final double? height;

  final EdgeInsetsGeometry padding;
  final double radius;

  /// Для выделения (например топ-1).
  final bool accent;

  /// Если хочешь свой формат времени/машины — передай форматтер.
  final VoidCallback? onTap;

  final String Function(double seconds)? formatLapTime;
  final String Function(String carName)? formatCar;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final lapText = (formatLapTime ?? _defaultLapTime)(lapTimeSeconds);
    final carText = (formatCar ?? _defaultCar)(carName);

    void open() {
      if (onTap != null) return onTap!();
      Navigator.of(context).pushNamed('/record/personal/$recordId');
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
                            userName,
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
                          carText,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface.withOpacity(.60),
                            height: 1.0,
                          ),
                        ),
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

  static String _defaultCar(String carName) {
    if (carName.trim().isEmpty) return 'Авто: —';
    return 'Авто: $carName';
  }
}
