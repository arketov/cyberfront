// lib/core/ui/base_page.dart

import 'package:flutter/material.dart';

import 'package:cyberdriver/core/navigation/app_section.dart';
import 'package:cyberdriver/core/navigation/app_route_observer.dart';
import 'package:cyberdriver/core/ui/app_scaffold.dart';
import 'package:cyberdriver/core/ui/app_scroll_behavior.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';

abstract class BasePage extends StatefulWidget {
  const BasePage({super.key});

  AppSection get section;

  String get title => section.label;

  bool get showTicker => true;

  /// Каждая страница определяет СВОЙ набор (может быть случайным).
  /// BasePage вызовет это при "заходе" на страницу.
  List<TickerItem> buildTickerItems(BuildContext context);

  List<Widget> buildBlocks(BuildContext context);

  List<Widget> buildActions(BuildContext context) => const [];

  EdgeInsetsGeometry contentPadding(BuildContext context) =>
      const EdgeInsets.fromLTRB(0, 10, 0, 0);

  double blockSpacing(BuildContext context) => 12;

  double get tickerHeight => 44;

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with RouteAware {
  List<TickerItem> _tickerItems = const [];
  PageRoute<dynamic>? _route;

  void _regenTicker() {
    _tickerItems = widget.buildTickerItems(context);
  }

  void _onEnter() => setState(_regenTicker);

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
    super.dispose();
  }

  @override
  void didPush() => _onEnter();

  @override
  void didPopNext() => _onEnter();

  @override
  Widget build(BuildContext context) {
    final blocks = widget.buildBlocks(context);
    final th = widget.tickerHeight;

    return AppScaffold(
      current: widget.section,
      title: widget.title,
      actions: widget.buildActions(context),
      child: ScrollConfiguration(
        behavior: const AppScrollBehavior(),
        child: Stack(
          children: [
            Padding(padding: EdgeInsetsGeometry.only(top: 16, left: 10, right: 10),
            child:
            CustomScrollView(
              slivers: [
                // резервируем место под "прибитый" тикер
                if (widget.showTicker)
                  SliverToBoxAdapter(child: SizedBox(height: th)),

                SliverPadding(
                  padding: widget.contentPadding(context),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, i) {
                        // последний "виртуальный" элемент — спейсер
                        if (i == blocks.length) {
                          return const SizedBox(height: 90); // нужная высота
                          // или: return SizedBox(height: widget.bottomSpacer(context));
                        }

                        final isLast = i == blocks.length - 1;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: isLast ? 0 : widget.blockSpacing(context),
                          ),
                          child: blocks[i],
                        );
                      },
                      childCount: blocks.length + 1, // +1 под SizedBox
                    ),
                  ),
                )
              ],
            ),
      ),

            // PINNED HEADER (вне скролла)
            if (widget.showTicker)
              Positioned(
                left: 10,
                right: 10,
                top: 16,
                child: SizedBox(
                  height: th,
                  child: InfiniteTickerBar(items: _tickerItems, height: th),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
