// lib/core/ui/base_page.dart
import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/navigation/app_route_observer.dart';
import 'package:cyberdriver/core/ui/app_scaffold.dart';
import 'package:cyberdriver/core/ui/app_scroll_behavior.dart';
import 'package:cyberdriver/core/ui/widgets/infinite_ticker.dart';

abstract class BasePage extends StatefulWidget {
  const BasePage({super.key});

  AppSection get section;

  String get title => section.label;

  bool get showTicker => true;

  /// Каждая страница определяет СВОЙ набор (может быть случайным).
  /// BasePage вызовет это при "заходе" на страницу.
  List<TickerItem> buildTickerItems(BuildContext context);

  /// Статичные виджеты НАД основным списком (опционально).
  /// Например: фильтры, поиск, плашки, “hero”-блоки и т.п.
  List<Widget> buildTopBlocks(BuildContext context) => const [];

  /// Основные блоки страницы (список).
  List<Widget> buildBlocks(BuildContext context);

  List<Widget> buildActions(BuildContext context) => const [];

  EdgeInsetsGeometry contentPadding(BuildContext context) =>
      const EdgeInsets.fromLTRB(0, 10, 0, 0);

  double blockSpacing(BuildContext context) => 12;

  double get tickerHeight => 44;

  /// Нижний спейсер (чтобы контент не упирался/не прятался).
  double bottomSpacerHeight(BuildContext context) => 115;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with RouteAware {
  List<TickerItem> _tickerItems = const [];
  PageRoute<dynamic>? _route;

  final ScrollController _scroll = ScrollController();
  bool _showScrollToTop = false;

  static const double _scrollToTopThreshold = 240.0;

  // Эти числа у тебя уже фигурировали в мобильной навигации.
  // Нужны только чтобы "поднять" кнопку НАД навом.
  static const double _navHeight = 66.0;
  static const double _navBottomInset = 16.0;
  static const double _fabMargin = 14.0;

  void _regenTicker() {
    _tickerItems = widget.buildTickerItems(context);
  }

  void _onEnter() => setState(_regenTicker);

  void _handleScroll() {
    if (!_scroll.hasClients) return;
    final shouldShow = _scroll.offset > _scrollToTopThreshold;
    if (shouldShow != _showScrollToTop) {
      setState(() => _showScrollToTop = shouldShow);
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scroll.hasClients) return;
    await _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_handleScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 1) первый расчёт
    if (_tickerItems.isEmpty) {
      _regenTicker();
    }

    // 2) подписка на route events
    final r = ModalRoute.of(context);
    if (r is PageRoute<dynamic> && r != _route) {
      if (_route != null) appRouteObserver.unsubscribe(this);
      _route = r;
      appRouteObserver.subscribe(this, r);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    _scroll.removeListener(_handleScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didPush() => _onEnter();

  @override
  void didPopNext() => _onEnter();

  @override
  Widget build(BuildContext context) {
    final topBlocks = widget.buildTopBlocks(context);
    final blocks = widget.buildBlocks(context);
    final allBlocks = <Widget>[...topBlocks, ...blocks];

    final th = widget.tickerHeight;

    final mq = MediaQuery.of(context);
    final topInset = mq.padding.top; // высота статус-бара (0 на Windows)
    const topGap = 5.0; // твой визуальный зазор сверху
    final pinnedTop = topInset + topGap; // где реально начинается тикер
    final reservedTop = pinnedTop + th; // сколько места надо зарезервировать в скролле

    final fabBottom = mq.padding.bottom + _navHeight + _navBottomInset + _fabMargin;

    return AppScaffold(
      current: widget.section,
      title: widget.title,
      actions: widget.buildActions(context),
      child: ScrollConfiguration(
        behavior: const AppScrollBehavior(),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  // резервируем место под "прибитый" тикер
                  if (widget.showTicker)
                    SliverToBoxAdapter(child: SizedBox(height: reservedTop)),

                  SliverPadding(
                    padding: widget.contentPadding(context),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, i) {
                          // последний "виртуальный" элемент — спейсер
                          if (i == allBlocks.length) {
                            return SizedBox(height: widget.bottomSpacerHeight(context));
                          }

                          final isLast = i == allBlocks.length - 1;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: isLast ? 0 : widget.blockSpacing(context),
                            ),
                            child: allBlocks[i],
                          );
                        },
                        childCount: allBlocks.length + 1, // +1 под SizedBox
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PINNED HEADER (вне скролла)
            if (widget.showTicker)
              Positioned(
                left: 10,
                right: 10,
                top: pinnedTop,
                child: SizedBox(
                  height: th,
                  child: InfiniteTickerBar(items: _tickerItems, height: th),
                ),
              ),

            // SCROLL-TO-TOP BUTTON (над нижней навигацией)
            Positioned(
              right: 16,
              bottom: fabBottom,
              child: AnimatedOpacity(
                opacity: _showScrollToTop ? 1 : 0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                child: IgnorePointer(
                  ignoring: !_showScrollToTop,
                  child: _ScrollToTopFab(onTap: _scrollToTop),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollToTopFab extends StatelessWidget {
  const _ScrollToTopFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.black.withOpacity(0.45),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.arrow_upward_rounded, size: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
