// lib/features/tracks/cards/controls.dart
part of tracks_page;


TextStyle _bracketStyle(ColorScheme cs) => TextStyle(
  color: Colors.white.withOpacity(0.9),
  fontSize: 26,
  fontWeight: FontWeight.w800,
  height: 1.0,
);

InputDecoration _controlDecoration(BuildContext context, {required String hint, required IconData icon}) {
  return InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colors.transparent,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
  );
}

String _randomSearchHint() {
  const pool = [
    'nurburgring gp...',
    'spa-franco...',
    'monza...',
    'silverst...',
    'brands hat...',
    'bathurst...',
    'laguna sec...',
    'suzuka 130r...',
    'paul ric...',
    'mugello...',
    'zandvoort...',
    'sochi aut...',
    'moscow ra...',
    'groznaya...',
    'kazan rin...',
  ];
  final r = Random();
  return pool[r.nextInt(pool.length)];
}

class _SearchCard extends CardBase {
  _SearchCard({required this.controller, required this.width, required this.onChanged, required this.onSubmitted}) : hint = _randomSearchHint();

  final TextEditingController controller;
  final double width;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final String hint;

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFF1557FF);

  @override
  bool get backgroundGradientEnabled => false;

  @override
  BoxBorder? border(BuildContext context) => null;

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.symmetric(horizontal: 10, vertical: 10);

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bs = _bracketStyle(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЭТО ПОИСК]'),
        SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('[', style: bs),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  decoration: _controlDecoration(context, hint: hint, icon: Icons.search),
                ),
              ),
              Text(']', style: bs),
            ],
          ),
        ),
      ],
    );
  }
}

class _CountryCard extends CardBase {
  const _CountryCard({required this.width});

  final double width;

  @override
  Color? backgroundColor(BuildContext context) => const Color(0xFF1557FF);

  @override
  bool get backgroundGradientEnabled => false;

  @override
  BoxBorder? border(BuildContext context) => null;

  @override
  EdgeInsetsGeometry get padding => const EdgeInsets.symmetric(horizontal: 10, vertical: 10);

  @override
  Widget buildContent(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bs = _bracketStyle(cs);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Kicker('[ЭТО ФИЛЬТР]'),
        SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('[', style: bs),
              Expanded(
                child: ValueListenableBuilder<_TracksQuery>(
                  valueListenable: _q,
                  builder: (context, q, _) {
                    return _CountryPopupField(
                      value: q.countryCode,
                      decoration: _controlDecoration(context, hint: 'Все страны', icon: Icons.public),
                      onChanged: (code) {
                        _q.value = (code == null)
                            ? _q.value.copyWith(clearCountry: true)
                            : _q.value.copyWith(countryCode: code);
                      },
                    );
                  },
                ),
              ),
              Text(']', style: bs),
            ],
          ),
        ),
      ],
    );
  }
}

class _TracksControlsBlock extends StatefulWidget {
  const _TracksControlsBlock();

  @override
  State<_TracksControlsBlock> createState() => _TracksControlsBlockState();
}

class _TracksControlsBlockState extends State<_TracksControlsBlock> {
  late final TextEditingController _c;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _q.value.search);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _applySearch(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      _q.value = _q.value.copyWith(search: '');
      return;
    }
    if (v.length < 3) return;
    _q.value = _q.value.copyWith(search: v);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _applySearch(value);
    });
  }

  void _onSearchSubmitted(String value) {
    _searchDebounce?.cancel();
    _applySearch(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0,0, 0, ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          const spacing = 10.0;
          final isCompact = w < 560;

          final searchW = isCompact ? w : max(260.0, w * 0.6);
          final dropdownW = isCompact
              ? w
              : max(220.0, min(320.0, w - searchW - spacing));

          return Wrap(
            spacing: spacing,
            runSpacing: 12,
            children: [
              _SearchCard(controller: _c, width: searchW, onChanged: _onSearchChanged, onSubmitted: _onSearchSubmitted),
              _CountryCard(width: dropdownW),
            ],
          );
        },
      ),
    );
  }
}
