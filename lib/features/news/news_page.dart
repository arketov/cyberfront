// lib/features/news/news_page.dart
import 'dart:math';
import 'package:cyberdriver/core/config/app_config.dart';
import 'package:cyberdriver/core/network/api_client_provider.dart';
import 'package:cyberdriver/core/ui/widgets/cyber_dots_loader.dart';
import 'package:cyberdriver/core/utils/logger.dart';
import 'package:cyberdriver/features/news/cards/news_card.dart';
import 'package:cyberdriver/features/news/data/news_api.dart';
import 'package:cyberdriver/shared/models/news_dto.dart';
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/ui/base_page.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';

TickerItem _choice(Random r, List<TickerItem> items) => items[r.nextInt(items.length)];

class NewsPage extends BasePage {
  const NewsPage({super.key});

  @override
  AppSection get section => AppSection.news;

  @override
  List<TickerItem> buildTickerItems(BuildContext context) {
    final r = Random();
    return <TickerItem>[
      const TickerItem('НОВОСТИ', accent: true),
      _choice(r, const [
        TickerItem('КОК ПИТ'),
        TickerItem('КОК'),
        TickerItem('ВАЗИЛИНОВЫЙ ТРЕК'),
        TickerItem('БЭУ'),
      ]),
      const TickerItem('НОВОСТИ', accent: true),
      _choice(r, const [
        TickerItem('АПДЕЙТЫ'),
        TickerItem('ПАТЧИ'),
        TickerItem('ИЗМЕНЕНИЯ'),
        TickerItem('АНОНСЫ'),
      ]),
      const TickerItem('НОВОСТИ', accent: true),
      _choice(r, const [
        TickerItem('СЕТАПЫ'),
        TickerItem('ТРАССЫ'),
        TickerItem('ФФБ'),
        TickerItem('КИБЕРДРАЙВ'),
      ]),
      const TickerItem('НОВОСТИ', accent: true),
      _choice(r, const [
        TickerItem('НОВЫЙ БОСС'),
        TickerItem('НОВАЯ ТАЧКА'),
        TickerItem('НОВАЯ ТРАССА'),
        TickerItem('НОВЫЙ АПЕКС'),
      ]),
      const TickerItem('НОВОСТИ', accent: true),
    ];
  }

  @override
  List<Widget> buildBlocks(BuildContext context) => const [
        _NewsListBlock(),
      ];
}

class _NewsListBlock extends StatefulWidget {
  const _NewsListBlock();

  @override
  State<_NewsListBlock> createState() => _NewsListBlockState();
}

class _NewsListBlockState extends State<_NewsListBlock> {
  static const double _itemExtent = 220.0;
  late final NewsApi _api;

  final List<NewsDto> _items = [];
  bool _isLoadingInitial = false;
  bool _isLoadingMore = false;
  String? _error;

  int _currentPage = 0;
  int _maxPage = 1;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _api = NewsApi(createApiClient(AppConfig.dev));
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
    super.dispose();
  }

  void _attachScrollPosition() {
    final scrollable = Scrollable.of(context);
    final position = scrollable.position;
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

    try {
      final res = await _api.getNewsPage(page: nextPage);
      if (!mounted) return;
      setState(() {
        _currentPage = res.currentPage;
        _maxPage = res.maxPage;
        _items.addAll(res.data);
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    } catch (error, stackTrace) {
      logger.warning('Failed to load news', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load news';
        _isLoadingInitial = false;
        _isLoadingMore = false;
      });
    }
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
                color: cs.onSurface.withValues(alpha: .75),
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
          'No news found',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          NewsCard(news: _items[i]),
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
