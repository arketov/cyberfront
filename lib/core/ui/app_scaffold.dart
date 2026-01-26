// lib/core/ui/app_scaffold.dart

import 'dart:ui';
import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/ui/widgets/app_notifications.dart';
import 'package:cyberdriver/core/ui/widgets/logo.dart';
import 'package:flutter/material.dart';

import '../navigation/app_section.dart';
import '../theme/app_theme.dart';

class AppScaffold extends StatefulWidget {
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

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  AuthService? _auth;
  bool _authReady = false;

  static const double _desktopBreakpoint = 900;
  static const double _desktopMaxWidth = 1280;

  @override
  void initState() {
    super.initState();
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final auth = await AuthService.getInstance();
    await auth.loadSession();
    if (!mounted) return;
    setState(() {
      _auth = auth;
      _authReady = true;
    });
  }

  void _go(BuildContext context, AppSection to) {
    if (to == widget.current) return;
    Navigator.of(context).pushReplacementNamed(to.route);
  }

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= _desktopBreakpoint;

        final isAdmin = _authReady && (_auth?.session?.user.role.id == 1);
        final primary = AppSectionX.primarySections;
        final mobileItems =
            isAdmin ? [...primary, AppSection.admin] : primary;
        final desktopExtra = isAdmin
            ? AppSectionX.desktopExtraSections
            : AppSectionX.desktopExtraSections
                .where((s) => s != AppSection.admin)
                .toList(growable: false);

        final content = isDesktop
            ? Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _desktopMaxWidth),
            child: Row(
              children: [
                _Sidebar(
                  current: widget.current,
                  primary: primary,
                  extra: desktopExtra,
                  onTap: (s) => _go(context, s),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            : _MobileBody(
          nav: _FloatingBottomNav(
            current: widget.current,
            items: mobileItems,
            onTap: (s) => _go(context, s),
          ),
          child: widget.child,
        );

        return Scaffold(
          backgroundColor: palette.bg,
          body: Stack(
            children: [
              content,
              SafeArea(
                top: true,
                bottom: false,
                left: false,
                right: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AppNotificationHost(
                      controller: AppNotifications.controller,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Mobile: навбар поверх контента
class _MobileBody extends StatelessWidget {
  const _MobileBody({required this.child, required this.nav});

  final Widget child;
  final Widget nav;

  static const double _navBottomInset = 16;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0), // <= без navHeight
          child: child,
        ),
        if (topInset > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topInset + 25,
            child: IgnorePointer(
              child: ClipRect(
                child: ShaderMask(
                  blendMode: BlendMode.dstIn,
                  shaderCallback: (rect) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFFFFFFF),Color(0x90FFFFFF), Color(0x00ffffff),], // маска: сверху видно, снизу нет
                  ).createShader(rect),
                  child:  Container(
                      color: Colors.black, // “тёмный” слой
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: _navBottomInset),
              child: Center(child: nav), // если надо во всю ширину — убери Center
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
    required this.items,
    required this.onTap,
  });

  final AppSection current;
  final List<AppSection> items;
  final ValueChanged<AppSection> onTap;

  static const double _height = 66;
  static const double _maxWidth = 390; // фиксированная ширина блока (но не больше экрана)

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
    final currentIndex = items.indexOf(current);
    final idx = (currentIndex < 0 ? 0 : currentIndex).clamp(0, items.length - 1);

    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 32).clamp(0, _maxWidth); // чтобы на узких экранах не вылезало
        return SizedBox(
          width: w.toDouble(),
          height: _height,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: palette.blurSigma, sigmaY: palette.blurSigma),
              child: Container(
                decoration: BoxDecoration(
                    color: palette.blurBlack,
                  borderRadius: BorderRadius.circular(18),
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
    required this.primary,
    required this.extra,
    required this.onTap,
  });

  final AppSection current;
  final List<AppSection> primary;
  final List<AppSection> extra;
  final ValueChanged<AppSection> onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).extension<AppPalette>()!;
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
