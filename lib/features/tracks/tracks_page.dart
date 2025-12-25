// lib/features/tracks/tracks_page.dart
library tracks_page;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/kicker.dart';
import 'package:cyberdriver/features/tracks/data/tracks_api.dart';
import 'package:cyberdriver/shared/countries_ru.dart';
import 'package:cyberdriver/shared/models/track_dto.dart';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/card_base.dart';
part 'cards/controls.dart';
part 'cards/track_card.dart';


TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

@immutable
class _TracksQuery {
  const _TracksQuery({this.search = '', this.countryCode});
  final String search;
  final String? countryCode; // ISO alpha-2 (DE, IT...)

  _TracksQuery copyWith({String? search, String? countryCode, bool clearCountry = false}) {
    return _TracksQuery(
      search: search ?? this.search,
      countryCode: clearCountry ? null : (countryCode ?? this.countryCode),
    );
  }
}

final ValueNotifier<_TracksQuery> _q = ValueNotifier<_TracksQuery>(const _TracksQuery());

class TracksPage extends BasePage {
  const TracksPage({super.key});

  @override
  AppSection get section => AppSection.tracks;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('ТРАССЫ', accent: true),
      _choice(r, const [
        TickerItem('EAU ROUGE-RAIDILLON',),
        TickerItem('130R',),
        TickerItem('MULSANNE STRAIGHT ',),
        TickerItem('MAGGOTS/BECKETTS/CHAPEL',),
      ]),
      const TickerItem('ТРАССЫ', accent: true),
      _choice(r, const [
        TickerItem('BATHURST MOUNT PANORAMA'),
        TickerItem('BRANDS HATCH'),
        TickerItem('DONINGTON PARK'),
        TickerItem('PAUL RICARD'),
        TickerItem('MUGELLO'),
        TickerItem('ZANDVOORT'),
      ]),
      const TickerItem('ТРАССЫ', accent: true),
      _choice(r, const [
        TickerItem('LAGUNA SECA',),
        TickerItem('BRANDS HATCH',),
        TickerItem('Nürburgring',),
        TickerItem('TARGA FLORIO',),
        TickerItem('SPA',),
      ]),
      const TickerItem('ТРАССЫ', accent: true),
      _choice(r, const [
        TickerItem('GT',),
        TickerItem('DRIFT',),
        TickerItem('RALLY',),
        TickerItem('F1',),
      ]),
      const TickerItem('ТРАССЫ', accent: true),
    ];
  }

  /// фикс сверху
  @override
  List<Widget> buildTopBlocks(BuildContext context) => const [
    _TracksControlsBlock(),
  ];

  /// список
  @override
  List<Widget> buildBlocks(BuildContext context) => const [
    _TracksListBlock(),
  ];
}



/// Выпадающий список (popup), НЕ bottom-sheet.
class _CountryPopupField extends StatelessWidget {
  const _CountryPopupField({
    required this.value,
    required this.onChanged,
    required this.decoration,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final label = value == null ? 'Все страны' : countryNameRu(value!);

    return PopupMenuButton<String>(
      tooltip: '',
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 220),
      position: PopupMenuPosition.under,
      onSelected: (v) => onChanged(v.isEmpty ? null : v),
      itemBuilder: (context) {
        final items = <PopupMenuEntry<String>>[
          CheckedPopupMenuItem<String>(
            value: '',
            checked: value == null,
            child: const Text('Все страны'),
          ),
          const PopupMenuDivider(),
        ];

        for (final c in countriesRuSorted()) {
          items.add(
            CheckedPopupMenuItem<String>(
              value: c.code,
              checked: value?.toUpperCase() == c.code,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.nameRu),
                  const SizedBox(height: 2),
                  Text(
                    c.code,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withOpacity(0.55),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return items;
      },
      child: AbsorbPointer(
        child: TextField(
          readOnly: true,
          decoration: decoration.copyWith(
            hintText: label,
            suffixIcon: const Icon(Icons.expand_more),
          ),
        ),
      ),
    );
  }
}

/// -------------------- LIST --------------------

class _TrackItem {
  const _TrackItem({
    required this.dto,
    required this.id, // INT, но на UI НЕ показываем
    required this.name,
    required this.countryCode,
    required this.lengthKm,
    required this.mapImageId,
  });

  final int id;
  final TrackDto dto;
  final String name;
  final String countryCode;
  final double lengthKm;
  final String mapImageId;
}

/// Статический список (как ты просил).
class _TracksListBlock extends StatefulWidget {
  const _TracksListBlock();

  @override
  State<_TracksListBlock> createState() => _TracksListBlockState();
}

class _TracksListBlockState extends State<_TracksListBlock> {
  static const double _itemExtent = 86.0;
  late final TracksApi _api;

  final List<_TrackItem> _items = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 0;
  int _maxPage = 1;
  String _activeKey = '';
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    final client = createApiClient(AppConfig.dev);
    _api = TracksApi(client);
    _activeKey = _queryKey(_q.value);
    _q.addListener(_onQueryChanged);
    _loadNextPage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachScrollPosition();
  }

  @override
  void dispose() {
    _scrollPosition?.removeListener(_handleScrollPosition);
    _q.removeListener(_onQueryChanged);
    super.dispose();
  }

  void _attachScrollPosition() {
    final scrollable = Scrollable.of(context);
    final position = scrollable?.position;
    if (position == _scrollPosition) return;
    _scrollPosition?.removeListener(_handleScrollPosition);
    _scrollPosition = position;
    _scrollPosition?.addListener(_handleScrollPosition);
  }

  void _handleScrollPosition() {
    final position = _scrollPosition;
    if (position == null) return;
    if (position.maxScrollExtent <= 0) return;
    final threshold = position.maxScrollExtent - (_itemExtent * 4);
    if (position.pixels >= threshold) {
      _loadNextPage();
    }
  }

  String _queryKey(_TracksQuery q) {
    final s = q.search.trim();
    final cc = q.countryCode?.trim().toUpperCase() ?? '';
    return 's=$s|cc=$cc';
  }

  void _onQueryChanged() {
    final key = _queryKey(_q.value);
    if (key == _activeKey) return;
    _activeKey = key;
    _resetAndLoad();
  }

  void _resetAndLoad() {
    setState(() {
      _items.clear();
      _error = null;
      _currentPage = 0;
      _maxPage = 1;
    });
    _loadNextPage();
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingInitial || _isLoadingMore) return;
    if (_currentPage >= _maxPage && _currentPage != 0) return;

    final isInitial = _items.isEmpty;
    setState(() {
      _error = null;
      if (isInitial) {
        _isLoadingInitial = true;
      } else {
        _isLoadingMore = true;
      }
    });

    final nextPage = _currentPage == 0 ? 1 : _currentPage + 1;
    final q = _q.value;
    final search = q.search.trim();
    final countryCode = q.countryCode?.trim().toUpperCase();

    try {
      final res = await _api.getTracks(
        page: nextPage,
        search: search.isEmpty ? null : search,
        countryCode: (countryCode == null || countryCode.isEmpty) ? null : countryCode,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = res.currentPage;
        _maxPage = res.maxPage;
        _items.addAll(_mapItems(res.data));
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load tracks';
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    }
  }

  List<_TrackItem> _mapItems(List<TrackDto> tracks) {
    return tracks
        .map(
          (t) => _TrackItem(
            dto: t,
            id: t.id,
            name: t.name,
            countryCode: t.country,
            lengthKm: t.lengthKm,
            mapImageId: t.imageHash,
          ),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_isLoadingInitial && _items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 18),
        child: Center(
          child: CyberDotsLoader(width: 120, height: 44),
        ),
      );
    }

    if (_error != null && _items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _error!,
              style: TextStyle(
                color: cs.onSurface.withOpacity(.75),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadNextPage,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No tracks found',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
      );
    }

    return Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            _TrackCard(item: _items[i]),
            if (i != _items.length - 1) const SizedBox(height: 10),
          ],
          if (_isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: CyberDotsLoader(width: 120, height: 44),
              ),
            ),
          if (_error != null && _items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextButton(
                onPressed: _loadNextPage,
                child: const Text('Retry'),
              ),
            ),
        ],
      );
  }
}

