import 'dart:ui';
import 'package:cyberdriver/core/ui/logo.dart';
import 'package:flutter/material.dart';

import '../navigation/app_section.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.current,
    required this.child,
    this.title,
    this.actions,
  });

  final AppSection current;
  final Widget child;
  final String? title;
  final List<Widget>? actions;

  static const double _desktopBreakpoint = 900;

  void _go(BuildContext context, AppSection to) {
    if (to == current) return;
    Navigator.of(context).pushReplacementNamed(to.route);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        final content = isDesktop
            ? Row(
          children: [
            _Sidebar(
              current: current,
              onTap: (s) => _go(context, s),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DesktopHeader(
                      title: title ?? current.label,
                      actions: actions ?? const [],
                    ),
                    const SizedBox(height: 12),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ],
        )
            : _MobileBody(
          nav: _FloatingBottomNav(
            current: current,
            onTap: (s) => _go(context, s),
          ),
          child: child,
        );

        return Scaffold(
          backgroundColor: palette.bg,
          // ВАЖНО: на desktop appBar не нужен, иначе он "лежит" поверх sidebar.
          appBar: isDesktop
              ? null
              : AppBar(
            title: Text(title ?? current.label),
            actions: actions,
          ),
          body: SafeArea(child: content),
        );
      },
    );
  }
}

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader({required this.title, required this.actions});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).appBarTheme.titleTextStyle;
    return Row(
      children: [
        Expanded(child: Text(title, style: tt)),
        if (actions.isNotEmpty) ...actions,
      ],
    );
  }
}

/// Mobile: навбар поверх контента
class _MobileBody extends StatelessWidget {
  const _MobileBody({required this.child, required this.nav});

  final Widget child;
  final Widget nav;

  static const double _navHeight = 66;
  static const double _navBottomInset = 16;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Контент с нижним отступом, чтобы важное не пряталось под панелью.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, _navHeight + _navBottomInset + 16),
          child: child,
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: _navBottomInset),
              child: Center(child: nav),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingBottomNav extends StatelessWidget {
  const _FloatingBottomNav({
    required this.current,
    required this.onTap,
  });

  final AppSection current;
  final ValueChanged<AppSection> onTap;

  static const double _height = 66;
  static const double _maxWidth = 390; // фиксированная ширина блока (но не больше экрана)

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final items = AppSectionX.primarySections;
    final idx = items.indexOf(current).clamp(0, items.length - 1);

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 32).clamp(0, _maxWidth); // чтобы на узких экранах не вылезало
        return SizedBox(
          width: w.toDouble(),
          height: _height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xD6000000), // тёмный полупрозрачный
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: palette.line, width: 1),
                ),
                child: Row(
                  children: [
                    for (int i = 0; i < items.length; i++)
                      Expanded(
                        child: _NavItem(
                          section: items[i],
                          selected: i == idx,
                          onTap: () => onTap(items[i]),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final iconColor = selected ? palette.pink : palette.muted2;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Icon(section.icon, color: iconColor, size: 24),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.current,
    required this.onTap,
  });

  final AppSection current;
  final ValueChanged<AppSection> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final primary = AppSectionX.primarySections;
    final extra = AppSectionX.desktopExtraSections;

    return Container(
      width: 280,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.panel,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.line, width: 1),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const SizedBox(height: 14),
          const Logo(size: 25),
          const SizedBox(height: 14),

          ...primary.map((s) => _SideItem(
            section: s,
            selected: s == current,
            onTap: () => onTap(s),
          )),

          if (extra.isNotEmpty) ...[
            const SizedBox(height: 18),
            Divider(color: palette.line),
            ...extra.map((s) => _SideItem(
              section: s,
              selected: s == current,
              onTap: () => onTap(s),
            )),
          ],
        ],
      ),
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AppSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final borderColor = selected ? palette.pink : palette.line;
    final bg = selected ? palette.panel2 : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(section.icon, color: selected ? palette.pink : palette.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
