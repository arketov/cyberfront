// lib/features/tracks/cards/track_card.dart
part of tracks_page;

class _TrackCard extends CardBase {
  const _TrackCard({required this.item});
  final _TrackItem item;

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(6, 6, 6, 6);

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final kicker = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.0,
      color: cs.onSurface.withOpacity(0.55),
    );

    final title = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.3,
      height: 1.05,
      color: cs.onSurface.withOpacity(0.98),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 76),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 100,
              child: _MapThumb(id: item.mapImageId),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 112),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    LayoutBuilder(
                      builder: (context, c) {
                        // Guard against overflow on narrow widths by constraining the country pill.
                        const pillSpacing = 8.0;
                        const minCountryWidth = 80.0;
                        final countryMaxWidth = max(minCountryWidth, c.maxWidth - 96);

                        return Wrap(
                          spacing: pillSpacing,
                          runSpacing: 6,
                          children: [
                            _Pill(text: '${item.lengthKm.toStringAsFixed(1)} км'),
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: countryMaxWidth),
                              child: _Pill(
                                text: countryNameRu(item.countryCode).toUpperCase(),
                                ellipsize: true,
                              ),
                            ),
                          ],
                        );

                      },
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapThumb extends StatefulWidget {
  const _MapThumb({required this.id});
  final String id;

  @override
  State<_MapThumb> createState() => _MapThumbState();
}

class _MapThumbState extends State<_MapThumb> {
  late Future<File> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _MapThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _future = _load();
    }
  }

  Future<File> _load() {
    if (widget.id.trim().isEmpty) {
      return Future.error('empty');
    }
    return MediaCacheService.instance.getImageFile(id: widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: Stack(
          fit: StackFit.expand,
          children: [
            FutureBuilder<File>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.done && snap.hasData) {
                  return Image.file(
                    snap.data!,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (_, __, ___) => _fallback(cs),
                  );
                }
                return _fallback(cs);
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      color: cs.surface.withOpacity(0.35),
      alignment: Alignment.center,
      child: Icon(Icons.map, color: cs.onSurface.withOpacity(0.35)),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, this.ellipsize = false});
  final String text;
  final bool ellipsize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final t = Text(
      text,
      maxLines: 1,
      overflow: ellipsize ? TextOverflow.ellipsis : TextOverflow.visible,
      softWrap: false,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: cs.onSurface.withOpacity(0.92),
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.onSurface.withOpacity(0.12)),
        color: cs.surface.withOpacity(0.18),
      ),
      child: ellipsize ? t : FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: t),
    );
  }
}
