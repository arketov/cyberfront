// lib/features/cars/cars_page.dart
library cars_page;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/utils/logger.dart';
import 'package:cyberdriver/features/cars/data/cars_api.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
part 'cards/controls.dart';
part 'cards/car_card.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

@immutable
class _CarsQuery {
  const _CarsQuery({this.search = '', this.brand, this.carClass});
  final String search;
  final String? brand;
  final String? carClass;

  _CarsQuery copyWith({
    String? search,
    String? brand,
    String? carClass,
    bool clearBrand = false,
    bool clearClass = false,
  }) {
    return _CarsQuery(
      search: search ?? this.search,
      brand: clearBrand ? null : (brand ?? this.brand),
      carClass: clearClass ? null : (carClass ?? this.carClass),
    );
  }
}

final ValueNotifier<_CarsQuery> _q = ValueNotifier<_CarsQuery>(const _CarsQuery());

class CarsPage extends BasePage {
  const CarsPage({super.key});

  @override
  AppSection get section => AppSection.cars;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('МАШИНЫ', accent: true),
      _choice(r, const [
        TickerItem('SUPRA'),
        TickerItem('GT-R'),
        TickerItem('911'),
        TickerItem('M3'),
        TickerItem('RS6'),
        TickerItem('WRX STI'),
        TickerItem('CIVIC TYPE R'),
      ]),

      const TickerItem('МАШИНЫ', accent: true),
      _choice(r, const [
        TickerItem('TUNING'),
        TickerItem('SETUP'),
        TickerItem('AERO'),
        TickerItem('BRAKES'),
        TickerItem('TYRES'),
        TickerItem('GEARING'),
        TickerItem('SUSPENSION'),
      ]),

      const TickerItem('МАШИНЫ', accent: true),

      _choice(r, const [
        TickerItem('LAUNCH'),
        TickerItem('DRIFT'),
        TickerItem('TIME ATTACK'),
        TickerItem('ENDURANCE'),
        TickerItem('HOTLAP'),
      ]),
      const TickerItem('МАШИНЫ', accent: true),
      _choice(r, const [
        TickerItem('TURBO'),
        TickerItem('NA'),
        TickerItem('V8'),
        TickerItem('V12'),
        TickerItem('ROTARY'),
        TickerItem('HYBRID'),
        TickerItem('ELECTRIC'),
      ]),
      const TickerItem('МАШИНЫ', accent: true),
    ];
  }

  /// фикс сверху
  @override
  List<Widget> buildTopBlocks(BuildContext context) => const [
    _CarsControlsBlock(),
  ];

  /// список
  @override
  List<Widget> buildBlocks(BuildContext context) => const [
    _CarsListBlock(),
  ];
}

/// Выпадающий список (popup), НЕ bottom-sheet.
class _BrandPopupField extends StatelessWidget {
  const _BrandPopupField({
    required this.value,
    required this.onChanged,
    required this.decoration,
    required this.items,
    required this.isLoading,
    required this.errorMessage,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final InputDecoration decoration;
  final List<String> items;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final label = value == null ? 'Все бренды' : value!;

    return PopupMenuButton<String>(
      tooltip: '',
      constraints: const BoxConstraints(maxHeight: 420, minWidth: 220),
      position: PopupMenuPosition.under,
      onSelected: (v) => onChanged(v.isEmpty ? null : v),
      itemBuilder: (context) {
        final entries = <PopupMenuEntry<String>>[
          CheckedPopupMenuItem<String>(
            value: '',
            checked: value == null,
            child: const Text('Все бренды'),
          ),
          const PopupMenuDivider(),
        ];

        if (isLoading) {
          entries.add(
            const PopupMenuItem<String>(
              value: '',
              enabled: false,
              child: Text('Загрузка...'),
            ),
          );
          return entries;
        }

        if (errorMessage != null) {
          entries.add(
            PopupMenuItem<String>(
              value: '',
              enabled: false,
              child: Text(errorMessage!),
            ),
          );
          return entries;
        }

        for (final b in items) {
          entries.add(
            CheckedPopupMenuItem<String>(
              value: b,
              checked: value == b,
              child: Text(b),
            ),
          );
        }
        return entries;
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

class _CarItem {
  const _CarItem({
    required this.dto,
    required this.id, // INT, но на UI НЕ показываем
    required this.name,
    required this.power,
    required this.torque,
    required this.massPowerRatio,
    required this.transmission,
    required this.carClass,
    required this.pwratio,
    required this.imageId,
  });

  final int id;
  final CarDto dto;
  final String name;
  final String power;
  final String torque;
  final String massPowerRatio;
  final String transmission;
  final String carClass;
  final String pwratio;
  final String imageId;
}

/// Список с подгрузкой как у трасс.
class _CarsListBlock extends StatefulWidget {
  const _CarsListBlock();

  @override
  State<_CarsListBlock> createState() => _CarsListBlockState();
}

class _CarsListBlockState extends State<_CarsListBlock> {
  static const double _itemExtent = 96.0;
  late final CarsApi _api;

  final List<_CarItem> _items = [];
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
    _api = CarsApi(client);
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

  String _queryKey(_CarsQuery q) {
    final s = q.search.trim();
    final brand = q.brand?.trim() ?? '';
    final cls = q.carClass?.trim() ?? '';
    return 's=$s|b=$brand|c=$cls';
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
    final brand = q.brand?.trim();
    final carClass = q.carClass?.trim();

    try {
      final res = await _api.getCars(
        page: nextPage,
        search: search.isEmpty ? null : search,
        brand: (brand == null || brand.isEmpty) ? null : brand,
        carClass: (carClass == null || carClass.isEmpty) ? null : carClass,
      );

      if (!mounted) return;
      setState(() {
        _currentPage = res.currentPage;
        _maxPage = res.maxPage;
        _items.addAll(_mapItems(res.data));
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    } catch (error, stackTrace) {
      logger.warning('Failed to load cars', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load cars';
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    }
  }

  List<_CarItem> _mapItems(List<CarDto> cars) {
    return cars
        .map(
          (c) => _CarItem(
            dto: c,
            id: c.id,
            name: _carName(c),
            power: c.power,
            torque: c.torque,
            massPowerRatio: c.massPowerRatio,
            transmission: c.transmission ?? '',
            carClass: c.carClass ?? '',
            pwratio: c.pwratio ?? '',
            imageId: c.imageHash,
          ),
        )
        .toList(growable: false);
  }

  String _carName(CarDto c) {
    final name = c.name.trim();
    if (name.isNotEmpty) return name;
    final brand = c.brand.trim();
    final model = c.model.trim();
    if (brand.isEmpty) return model;
    if (model.isEmpty) return brand;
    return '$brand $model';
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
          'No cars found',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          _CarCard(item: _items[i]),
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
