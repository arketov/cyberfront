// lib/features/tracks/details_track.dart
import 'dart:math';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/features/tracks/data/tracks_api.dart';
import 'package:cyberdriver/features/tracks/details/cards/track_hello.dart';
import 'package:cyberdriver/features/tracks/details/cards/track_props.dart';
import 'package:cyberdriver/features/tracks/details/cards/track_records.dart';
import 'package:cyberdriver/features/tracks/details/cards/track_run.dart';
import 'package:cyberdriver/shared/models/track_dto.dart';
import 'package:flutter/material.dart';

class TrackDetailsPage extends BasePage {
  TickerItem choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];
  const TrackDetailsPage({super.key, required this.trackId, this.dto});

  final int trackId;
  final TrackDto? dto;

  @override
  AppSection get section => AppSection.tracks;

  @override
  bool get showTicker => true;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      choice(r, const [
        TickerItem('ПРОСТО_ЕДЕМ'),
        TickerItem('БЕЗ_ПОНТОВ'),
        TickerItem('РАЗМИНКА'),
        TickerItem('ПИТ_ЛЕЙН'),
        TickerItem('НА_КРУГЕ'),
        TickerItem('В_ТЕМПЕ'),
        TickerItem('НЕ_СПЕШИ'),
        TickerItem('ДЕРЖИ_РИТМ'),
        TickerItem('СВОЙ_ТЕМП'),
        TickerItem('ТУТ_ТЫЛЬТ'),
      ]),
      choice(r, const [
        TickerItem('ЧИСТАЯ_ЛИНИЯ'),
        TickerItem('БЕЗ_ОШИБОК'),
        TickerItem('СБРОС_ГАЗА'),
        TickerItem('ПОЗДНИЙ_АПЕКС'),
        TickerItem('РАННИЙ_АПЕКС'),
        TickerItem('ВЫХОД_НА_ПРЯМУЮ'),
        TickerItem('ТОЧКА_ТОРМОЖЕНИЯ'),
        TickerItem('НЕ_ПЕРЕТОРМОЗИ'),
        TickerItem('НЕ_СНОСИ'),
        TickerItem('ДЕРЖИ_ДУГУ'),
      ]),
      choice(r, const [
        TickerItem('АПЕХ'),
        TickerItem('ТРАЕКТОРИЯ'),
        TickerItem('МОКРЫЕ_НОСКИ'),
      ]),
      choice(r, const [
        TickerItem('ТРЕК', accent: true),
        TickerItem('ТРАССА', accent: true),
        TickerItem('КИБЕРТРЕК', accent: true),
      ]),
      choice(r, const [
        TickerItem('ОБХОД_СПРАВА'),
        TickerItem('ДРАФТ'),
        TickerItem('АДРЕНАЛАЙН'),
      ]),
      choice(r, const [
        TickerItem('ПРОСТО_ВАЙБ'),
        TickerItem('ЗЛОЙ_ЗАЦЕП'),
        TickerItem('СЦЕПА_НЕТ'),
        TickerItem('ПОЕХАЛИ_ПО_НОВОЙ'),
        TickerItem('ПЛОТНЫЙ_КРУГ'),
        TickerItem('ЕЩЁ_КРУЖОК'),
        TickerItem('НЕ_ЛОМАЙСЯ'),
        TickerItem('БЕЗ_ДЫМА'),
        TickerItem('БЕЗ_ДРИФТА'),
        TickerItem('НЕ_ТРОГАЙ_ПЕДАЛЬ'),
      ]),
      choice(r, const [
        TickerItem('СПОКОЙНО'),
        TickerItem('НА_ЛАЙТЕ'),
        TickerItem('ЧУТЬ_ПОЗЖЕ'),
        TickerItem('ЧУТЬ_РАНЬШЕ'),
        TickerItem('ДЕРЖИ_СПОКОЙНО'),
        TickerItem('ВЫРОВНЯЙ_РУЛЬ'),
        TickerItem('НЕ_ПСИХУЙ'),
        TickerItem('НЕ_ГОРИ'),
        TickerItem('ДЫШИ'),
        TickerItem('ВСЁ_НОРМ'),
      ]),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) => [
    _TrackDetailsBody(trackId: trackId, initialDto: dto),
  ];
}

class _TrackDetailsBody extends StatefulWidget {
  const _TrackDetailsBody({required this.trackId, required this.initialDto});

  final int trackId;
  final TrackDto? initialDto;

  @override
  State<_TrackDetailsBody> createState() => _TrackDetailsBodyState();
}

class _TrackDetailsBodyState extends State<_TrackDetailsBody> {
  late final TracksApi _api;
  Future<TrackDto>? _future;

  @override
  void initState() {
    super.initState();
    _api = TracksApi(createApiClient(AppConfig.dev));
    _prime();
  }

  @override
  void didUpdateWidget(covariant _TrackDetailsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId || oldWidget.initialDto != widget.initialDto) {
      setState(_prime);
    }
  }

  void _prime() {
    if (widget.initialDto == null) {
      _future = _api.getTrack(widget.trackId);
    } else {
      _future = null;
    }
  }

  void _reload() {
    setState(() {
      _future = _api.getTrack(widget.trackId);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.initialDto != null) {
      final dto = widget.initialDto!;
      return _TrackDetailsCards(dto: dto);
    }

    final future = _future;
    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<TrackDto>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: CyberDotsLoader(width: 120, height: 44),
            ),
          );
        }

        if (snap.hasError || !snap.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load track',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _reload,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final dto = snap.data!;
        return _TrackDetailsCards(dto: dto);
      },
    );
  }
}

class _TrackDetailsCards extends StatelessWidget {
  const _TrackDetailsCards({required this.dto});

  final TrackDto dto;

  String _safeText(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? '-' : v;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          HelloTrackCard(
            name: dto.name,
            countryCode: dto.country,
            city: dto.city,
            lengthKm: dto.lengthKm,
          ),
          const SizedBox(height: 12),
          PropTrackCard(
            width: _safeText(dto.width),
            pitboxes: _safeText(dto.pitboxes),
            year: (dto.year == null || dto.year == 0) ? '—' : dto.year.toString(),
            run: _safeText(dto.run),
            tags: dto.tags,
            descr: dto.description,
          ),
          const SizedBox(height: 12,),
          TrackRunCard(trackId: dto.id),
          const SizedBox(height: 12),
          RecordsTrackCard(trackId: dto.id,)
        ]
    );
  }
}

