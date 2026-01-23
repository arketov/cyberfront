// lib/features/cars/details/cards/car_skins.dart
import 'dart:io';
import 'dart:math';

import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:cyberdriver/core/ui/widgets/radial_fade_image.dart';
import 'package:cyberdriver/features/cars/data/cars_api.dart';
import 'package:flutter/material.dart';

class CarSkinsCard extends CardBase {
  const CarSkinsCard({super.key, required this.carId});

  final int carId;

  @override
  EdgeInsetsGeometry get padding => EdgeInsets.zero;

  @override
  Widget buildContent(BuildContext context) {
    return _CarSkinsContent(carId: carId);
  }
}

class _CarSkinsContent extends StatefulWidget {
  const _CarSkinsContent({required this.carId});

  final int carId;

  @override
  State<_CarSkinsContent> createState() => _CarSkinsContentState();
}

class _CarSkinsContentState extends State<_CarSkinsContent> {
  late final CarsApi _api;
  Future<List<CarSkinDto>>? _future;
  final PageController _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _api = CarsApi(createApiClient(AppConfig.dev));
    _future = _api.getCarSkins(widget.carId);
  }

  @override
  void didUpdateWidget(covariant _CarSkinsContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carId != widget.carId) {
      setState(() {
        _future = _api.getCarSkins(widget.carId);
        _index = 0;
        _pageController.jumpToPage(0);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const contentPadding = EdgeInsets.fromLTRB(18, 14, 18, 16);
    final cs = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 140),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: .99),
                      Colors.black.withValues(alpha: .50),
                      Colors.black.withValues(alpha: .20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: contentPadding,
              child: FutureBuilder<List<CarSkinDto>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CyberDotsLoader(width: 120, height: 44),
                    );
                  }

                  if (snap.hasError || !snap.hasData) {
                    return Text(
                      'Failed to load skins',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: .75),
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }

                  final items = snap.data!
                      .where((e) => e.imageHash.trim().isNotEmpty)
                      .toList();
                  if (items.isEmpty) {
                    return Text(
                      'No skins',
                      style: TextStyle(
                        color: cs.onSurface.withValues(alpha: .75),
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }

                  items.sort((a, b) => a.priority.compareTo(b.priority));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Kicker('[ЭТО СКИНЫ]'),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: items.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (context, i) => _SkinImageCard(
                            dto: items[i],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SkinName(text: items[_index].skinName),
                          _Dots(current: _index, total: items.length),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkinImageCard extends StatelessWidget {
  const _SkinImageCard({required this.dto});

  final CarSkinDto dto;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: cs.surface.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: _SkinImage(hash: dto.imageHash),
        ),
      ),
    );
  }
}

class _SkinImage extends StatefulWidget {
  const _SkinImage({required this.hash});

  final String hash;

  @override
  State<_SkinImage> createState() => _SkinImageState();
}

class _SkinImageState extends State<_SkinImage> {
  late Future<File> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _SkinImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hash != widget.hash) {
      _future = _load();
    }
  }

  Future<File> _load() {
    if (widget.hash.trim().isEmpty) {
      return Future.error('empty');
    }
    return MediaCacheService.instance.getImageFile(id: widget.hash, forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<File>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          return RadialFadeImage(file: snap.data!);
        }
        return Container(
          color: cs.surface.withValues(alpha: 0.2),
          alignment: Alignment.center,
          child: Icon(Icons.image, color: cs.onSurface.withValues(alpha: 0.35)),
        );
      },
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const maxDots = 12;
    final count = total <= 0 ? 0 : min(total, maxDots);
    final safeCurrent = total <= 1 ? 0 : current.clamp(0, total - 1);
    final mappedIndex = total <= 1
        ? 0
        : ((safeCurrent * (count - 1)) / (total - 1)).round();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(left: 6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == mappedIndex
                  ? cs.primary.withValues(alpha: 0.9)
                  : cs.onSurface.withValues(alpha: 0.25),
            ),
          ),
        if (total > maxDots)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '${safeCurrent + 1}/$total',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
      ],
    );
  }
}

class _SkinName extends StatelessWidget {
  const _SkinName({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = text.trim().isEmpty ? '-' : text.trim();

    return Text(
      value,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        color: cs.onSurface.withValues(alpha: 0.85),
      ),
    );
  }
}
