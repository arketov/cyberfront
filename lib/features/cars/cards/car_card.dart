// lib/features/cars/cards/car_card.dart
part of cars_page;

class _CarCard extends CardBase {
  const _CarCard({required this.item});

  final _CarItem item;

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.fromLTRB(0, 0, 18, 0);

  @override
  VoidCallback? onTap(BuildContext context) {
    return () => Navigator.of(context).pushNamed(
          '/cars/${item.id}',
          arguments: item.dto,
        );
  }

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final title = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w900,
      letterSpacing: -0.3,
      height: 1.05,
      color: cs.onSurface.withOpacity(0.98),
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 86),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 100,
              child: _CarThumb(id: item.imageId),
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
                        const pillSpacing = 8.0;
                        const minCountryWidth = 90.0;
                        final countryMaxWidth = max(
                          minCountryWidth,
                          c.maxWidth - 120,
                        );

                        final pills = _buildPills(item);

                        return Wrap(
                          spacing: pillSpacing,
                          runSpacing: 6,
                          children: pills,
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

  List<Widget> _buildPills(_CarItem item) {
    final pills = <Widget>[];

    if (item.pwratio.trim().isNotEmpty) {
      pills.add(_Pill(text: item.pwratio.trim()));
    }
    final cls = item.carClass.trim();
    if (cls.isNotEmpty) {
      pills.add(_Pill(text: cls.toUpperCase()));
    }

    return pills;
  }

}

class _CarThumb extends StatefulWidget {
  const _CarThumb({required this.id});

  final String id;

  @override
  State<_CarThumb> createState() => _CarThumbState();
}

class _CarThumbState extends State<_CarThumb> {
  late Future<File> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant _CarThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _future = _load();
    }
  }

  Future<File> _load() {
    if (widget.id.trim().isEmpty) {
      return Future.error('empty');
    }
    return MediaCacheService.instance.getImageFile(id: widget.id, forceRefresh: false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox.expand(
        child: FutureBuilder<File>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.done && snap.hasData) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.file(
                      snap.data!,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ],
              );
            }
            return _fallback(cs);
          },
        ),
      ),
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      color: cs.surface.withOpacity(0.35),
      alignment: Alignment.center,
      child: Icon(Icons.directions_car, color: cs.onSurface.withOpacity(0.35)),
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
      child: ellipsize
          ? t
          : FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: t,
            ),
    );
  }
}
