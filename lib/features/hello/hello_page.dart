// lib/features/hello/hello_page.dart

import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:cyberdriver/core/ui/infinite_ticker.dart';
import 'package:cyberdriver/core/ui/stretch_ticker_header.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_section.dart';
import '../../core/ui/base_page.dart';


class AlwaysBouncyScrollBehavior extends MaterialScrollBehavior {
  const AlwaysBouncyScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child; // без glow
  }
}

class HelloPage extends BasePage {
  const HelloPage({super.key});

  @override
  AppSection get section => AppSection.hello;

  @override
  Widget buildBody(BuildContext context) {
    final p = Theme.of(context).extension<AppPalette>()!;
    final items = const <TickerItem>[
      TickerItem('МУЖИКИ'),
      TickerItem('КИБЕРВОДИЛЫ', accent: true),
      TickerItem('ГОНКИ'),
      TickerItem('ДРОЧ', accent: true),
    ];
    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverAppBar(
          primary: false,                 // если у тебя сверху уже есть свой AppBar
          automaticallyImplyLeading: false,
          pinned: false,
          stretch: true,

          expandedHeight: 44,
          collapsedHeight: 44,
          toolbarHeight: 44,

          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,

          flexibleSpace: StretchTickerHeader(
            items: items,
            baseHeight: 44,
            maxStretch: 140,
            maxAngleDeg: 28,
          ),
        ),
        // дальше обычный контент
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, i) => ListTile(title: Text('Item $i')),
            childCount: 50,
          ),
        ),
      ],
    );
  }
}