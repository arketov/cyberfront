// lib/features/hello/cards/hello_news_card.dart
import 'dart:io';

import 'package:cyberdriver/core/media/media_cache_service.dart';
import 'package:cyberdriver/core/theme/app_theme.dart';
import 'package:cyberdriver/core/ui/cards/card_base.dart';
import 'package:cyberdriver/core/ui/widgets/kicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HelloNewsCard extends CardBase {
  const HelloNewsCard({super.key});

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(16, 14, 16, 16);

  @override
  Widget buildContent(BuildContext context) => const _HelloNewsCardContent();
}

class _HelloNewsCardContent extends StatefulWidget {
  const _HelloNewsCardContent();

  @override
  State<_HelloNewsCardContent> createState() => _HelloNewsCardContentState();
}

class _HelloNewsCardContentState extends State<_HelloNewsCardContent>
    with SingleTickerProviderStateMixin {
  static const _title =
      'ОБНОВЛЕНИЕ 1.2 — НОВЫЕ ТРАССЫ, ПРАВКИ ФФБ, СЕТАПЫ';
  static const _date = '24 янв';
  static const _time = '09:10';
  static const _readTime = '2 мин';
  static const _author = 'CYBERDRIVER';
  static const _imageHashes = [
    'news_patch_1_2_cover_01',
    'news_patch_1_2_cover_02',
    'news_patch_1_2_cover_03',
  ];

  static const _bodyMarkdown = '''
Добавили новые трассы, подкрутили **force feedback**, и теперь загрузка сетапов не ломает пит-стоп.

### Что нового:
- Добавили 3 трассы в общий пул
- Улучшили стабильность на старте сессии
- Поправили force feedback на некоторых рулях

> Важно: после обновления рекомендуется перезапустить клиент.

Где смотреть? Откройте раздел рекордов или список трасс.
''';

  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  String _excerpt(String text, int limit) {
    final plain = text
        .replaceAll(RegExp(r'[#>*_`\\-]'), '')
        .replaceAll(RegExp(r'\n+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (plain.length <= limit) return plain;
    return '${plain.substring(0, limit).trim()}…';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pal = Theme.of(context).extension<AppPalette>();
    final accent = pal?.pink ?? cs.primary;

    final titleStyle = TextStyle(
      height: 1.05,
      fontSize: 20,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.4,
      color: Colors.white.withValues(alpha: 0.92),
    );

    final metaStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: Colors.white.withValues(alpha: 0.58),
    );

    final descStyle = TextStyle(
      height: 1.25,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.72),
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedOpacity(
              opacity: _expanded ? 0 : 1,
              duration: const Duration(milliseconds: 200),
              child: _NewsBackground(hash: _imageHashes.first),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Kicker('[НОВОСТИ]'),
                    const Spacer(),
                    _PillButton(
                      label: 'ВСЕ',
                      icon: Icons.arrow_forward_rounded,
                      tone: Colors.white.withValues(alpha: 0.10),
                      textColor: Colors.white.withValues(alpha: 0.85),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _title,
                        style: titleStyle,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    _MetaItem(
                      icon: Icons.calendar_today_rounded,
                      label: _date,
                      style: metaStyle,
                    ),
                    _MetaItem(
                      icon: Icons.schedule_rounded,
                      label: _time,
                      style: metaStyle,
                    ),
                    _MetaItem(
                      icon: Icons.timer_outlined,
                      label: _readTime,
                      style: metaStyle,
                    ),
                    _MetaItem(
                      icon: Icons.bolt_rounded,
                      label: _author,
                      style: metaStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: _expanded
                      ? _ExpandedBody(
                          key: const ValueKey('expanded'),
                          hashes: _imageHashes,
                          markdown: _bodyMarkdown,
                        )
                      : _CollapsedBody(
                          key: const ValueKey('collapsed'),
                          excerpt: _excerpt(_bodyMarkdown, 100),
                          textStyle: descStyle,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedBody extends StatelessWidget {
  const _CollapsedBody({
    super.key,
    required this.excerpt,
    required this.textStyle,
  });

  final String excerpt;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(excerpt, style: textStyle),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    super.key,
    required this.hashes,
    required this.markdown,
  });

  final List<String> hashes;
  final String markdown;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      height: 1.25,
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.white.withValues(alpha: 0.72),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: _NewsCarousel(hashes: hashes),
        ),
        const SizedBox(height: 12),
        MarkdownBody(
          data: markdown,
          styleSheet: MarkdownStyleSheet(
            p: baseStyle,
            h3: baseStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            blockquote: baseStyle.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
            listBullet: baseStyle,
          ),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.textColor,
  });

  final String label;
  final IconData icon;
  final Color tone;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: textColor,
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, size: 14, color: textColor),
        ],
      ),
    );
  }
}


class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: style.color),
        const SizedBox(width: 6),
        Text(label, style: style),
      ],
    );
  }
}


class _NewsCarousel extends StatefulWidget {
  const _NewsCarousel({required this.hashes});

  final List<String> hashes;

  @override
  State<_NewsCarousel> createState() => _NewsCarouselState();
}

class _NewsCarouselState extends State<_NewsCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _shift(int direction) {
    if (widget.hashes.isEmpty) return;
    final next = (_index + direction).clamp(0, widget.hashes.length - 1);
    if (next == _index) return;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.hashes.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cs.surface.withValues(alpha: 0.12),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.image, color: cs.onSurface.withValues(alpha: 0.35)),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.hashes.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return _NewsImage(hash: widget.hashes[i]);
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: _NavButton(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => _shift(-1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _NavButton(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () => _shift(1),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _Dots(current: _index, total: widget.hashes.length),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.hash});

  final String hash;

  @override
  Widget build(BuildContext context) {
    return _CachedImage(
      hash: hash,
      fit: BoxFit.cover,
      overlay: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.15),
          Colors.transparent,
          Colors.black.withValues(alpha: 0.25),
        ],
      ),
    );
  }
}

class _NewsBackground extends StatelessWidget {
  const _NewsBackground({required this.hash});

  final String hash;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _CachedImage(
        hash: hash,
        fit: BoxFit.cover,
        overlay: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.45),
            Colors.black.withValues(alpha: 0.2),
            Colors.black.withValues(alpha: 0.55),
          ],
        ),
      ),
    );
  }
}

class _CachedImage extends StatelessWidget {
  const _CachedImage({
    required this.hash,
    required this.fit,
    required this.overlay,
  });

  final String hash;
  final BoxFit fit;
  final Gradient overlay;

  Future<File> _load() {
    if (hash.trim().isEmpty) {
      return Future.error('empty');
    }
    return MediaCacheService.instance.getImageFile(id: hash, forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<File>(
      future: _load(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done && snap.hasData) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.file(snap.data!, fit: fit),
              DecoratedBox(decoration: BoxDecoration(gradient: overlay)),
            ],
          );
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

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.85)),
      ),
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
    final safeTotal = total <= 0 ? 1 : total;
    final safeIndex = current.clamp(0, safeTotal - 1);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < safeTotal; i++)
          Container(
            width: i == safeIndex ? 8 : 6,
            height: i == safeIndex ? 8 : 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == safeIndex
                  ? cs.primary.withValues(alpha: 0.9)
                  : Colors.white.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}
