// lib/features/cars/details/details_car.dart
import 'dart:math';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';
import 'package:cyberdriver/features/cars/data/cars_api.dart';
import 'package:cyberdriver/features/cars/details/cards/car_hello.dart';
import 'package:cyberdriver/features/cars/details/cards/car_curve.dart';
import 'package:cyberdriver/features/cars/details/cards/car_props.dart';
import 'package:cyberdriver/features/cars/details/cards/car_records.dart';
import 'package:cyberdriver/features/cars/details/cards/car_skins.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';
import 'package:flutter/material.dart';

class CarDetailsPage extends BasePage {
  const CarDetailsPage({super.key, required this.carId, this.dto});

  final int carId;
  final CarDto? dto;

  @override
  AppSection get section => AppSection.cars;

  @override
  bool get showTicker => true;

  TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      _choice(r, const [
        TickerItem('ЗАВОДИМ'),
        TickerItem('ПРОГРЕВ'),
        TickerItem('ВЫЕЗД'),
        TickerItem('ПИТ_ЛЕЙН'),
        TickerItem('НА_ХОДУ'),
        TickerItem('В_ТЕМПЕ'),
        TickerItem('НЕ_РВИ'),
        TickerItem('ПЛАВНО_ГАЗ'),
        TickerItem('ДЕРЖИ_ОБОРОТЫ'),
        TickerItem('БЕЗ_РЫВКОВ'),
      ]),
      _choice(r, const [
        TickerItem('ЧИСТЫЙ_ГАЗ'),
        TickerItem('ДОЗИРУЙ_БУСТ'),
        TickerItem('НЕ_БУКСУЙ'),
        TickerItem('КОНТРОЛЬ_ЗАЦЕПА'),
        TickerItem('ТОРМОЗИ_РОВНО'),
        TickerItem('НЕ_ПЕРЕТОРМОЗИ'),
        TickerItem('ПЕРЕКЛЮЧАЙСЯ_МЯГКО'),
        TickerItem('ДАУНШИФТ'),
        TickerItem('НЕ_ЛОМАЙ_КПП'),
        TickerItem('РОВНЫЙ_РУЛЬ'),
      ]),
      _choice(r, const [
        TickerItem('БУСТ'),
        TickerItem('ТУРБО'),
        TickerItem('АТМО'),
        TickerItem('ОТСЕЧКА'),
        TickerItem('ЛС'),
        TickerItem('НМ'),
        TickerItem('ЛАГ'),
        TickerItem('АНТИ-ЛАГ'),
        TickerItem('ДИФФ'),
        TickerItem('ЛСД'),
      ]),
      _choice(r, const [
        TickerItem('МАШИНА', accent: true),
        TickerItem('ТАЧКА', accent: true),
        TickerItem('КИБЕРКАР', accent: true),
      ]),
      _choice(r, const [
        TickerItem('ОБГОН'),
        TickerItem('ЛАУНЧ'),
        TickerItem('БЫСТРЫЙ_СТАРТ'),
        TickerItem('ТОРМОЗА_ГОРЯЧИЕ'),
        TickerItem('ПРОГРЕТЬ_ШИНЫ'),
        TickerItem('ХОЛОДНЫЕ_ШИНЫ'),
        TickerItem('ПОДРУЛИВАНИЕ'),
        TickerItem('СНОС_ПЕРЕДКА'),
        TickerItem('СНОС_ЗАДКА'),
        TickerItem('КОНТРРУЛЕНИЕ'),
      ]),
      _choice(r, const [
        TickerItem('ПРОСТО_ВАЙБ'),
        TickerItem('ЗЛОЙ_ЗАЦЕП'),
        TickerItem('ЗАЦЕПА_НЕТ'),
        TickerItem('ПОЕХАЛИ_ПО_НОВОЙ'),
        TickerItem('ПЛОТНЫЙ_ЗАЕЗД'),
        TickerItem('ЕЩЁ_ЗАЕЗД'),
        TickerItem('НЕ_ПЕРЕГРЕЙ'),
        TickerItem('СМОТРИ_ТЕМПЫ'),
        TickerItem('ДАВЛЕНИЕ_В_ШИНАХ'),
        TickerItem('БЕЗ_ЧЕК-ЭНДЖИН'),
      ]),
      _choice(r, const [
        TickerItem('СПОКОЙНО'),
        TickerItem('НА_ЛАЙТЕ'),
        TickerItem('ПЛАВНО'),
        TickerItem('НЕ_ПЕРЕГАЗУЙ'),
        TickerItem('НЕ_ПЕРЕКРУЧИВАЙ'),
        TickerItem('СЛУШАЙ_МОТОР'),
        TickerItem('ПРОВЕРЬ_МАСЛО'),
        TickerItem('ПРОВЕРЬ_ОЖ'),
        TickerItem('ПРОВЕРЬ_ТОРМОЗА'),
        TickerItem('ВСЁ_НОРМ'),
      ]),
    ];

  }

  @override
  List<Widget> buildBlocks(BuildContext context) => [
    _CarDetailsBody(carId: carId, initialDto: dto),
  ];
}

class _CarDetailsBody extends StatefulWidget {
  const _CarDetailsBody({required this.carId, required this.initialDto});

  final int carId;
  final CarDto? initialDto;

  @override
  State<_CarDetailsBody> createState() => _CarDetailsBodyState();
}

class _CarDetailsBodyState extends State<_CarDetailsBody> {
  late final CarsApi _api;
  Future<CarDto>? _future;

  @override
  void initState() {
    super.initState();
    _api = CarsApi(createApiClient(AppConfig.dev));
    _prime();
  }

  @override
  void didUpdateWidget(covariant _CarDetailsBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carId != widget.carId || oldWidget.initialDto != widget.initialDto) {
      setState(_prime);
    }
  }

  void _prime() {
    _future = _api.getCar(widget.carId);
  }

  void _reload() {
    setState(() {
      _future = _api.getCar(widget.carId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<CarDto>(
      future: future,
      initialData: widget.initialDto,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: CyberDotsLoader(width: 120, height: 44),
            ),
          );
        }

        if (snap.hasError && !snap.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load car',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(.75),
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

        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        final dto = snap.data!;
        return _CarDetailsCards(dto: dto);
      },
    );
  }
}

class _CarDetailsCards extends StatelessWidget {
  const _CarDetailsCards({required this.dto});

  final CarDto dto;

  String _safeText(String? value) {
    final v = value?.trim();
    return (v == null || v.isEmpty) ? '-' : v;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        HelloCarCard(
          name: dto.name,
          brand: dto.brand,
          carClass: dto.carClass,
          pwratio: dto.pwratio,
        ),
        const SizedBox(height: 12),
        PropCarCard(
          carClass: _safeText(dto.carClass),
          weight: _safeText(dto.weight),
          topspeed: _safeText(dto.topspeed),
          acceleration: _safeText(dto.acceleration),
          pwratio: _safeText(dto.pwratio),
          power: _safeText(dto.power),
          torque: _safeText(dto.torque),
          range: _safeText(dto.range),
          descr: dto.descr,
          tags: dto.tags,
        ),
        const SizedBox(height: 12),
        CarSkinsCard(carId: dto.id),
        const SizedBox(height: 12),
        CarCurveCard(
          power: dto.powerCurve,
          torque: dto.torqueCurve,
        ),
        const SizedBox(height: 12),
        RecordsCarCard(carId: dto.id),
      ],
    );
  }
}
