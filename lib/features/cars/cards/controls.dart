// lib/features/cars/cards/controls.dart
part of cars_page;

TextStyle _bracketStyle(ColorScheme cs) => TextStyle(
  color: Colors.white.withValues(alpha: 0.9),
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
    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
  );
}

String _randomSearchHint() {
  const pool = [
    'supra mk4...',
    'nissan gtr...',
    'porsche 911...',
    'bmw m3...',
    'audi rs6...',
    'lancer evo...',
    'mustang gt...',
    'c63 amg...',
    'civic type r...',
    'mazda rx-7...',
    'ferrari f8...',
    'lamborghini huracan...',
  ];
  final r = Random();
  return pool[r.nextInt(pool.length)];
}

class _SearchCard extends CardBase {
  _SearchCard({required this.controller, required this.width, required this.onChanged, required this.onSubmitted})
      : hint = _randomSearchHint();

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

class _BrandCard extends CardBase {
  const _BrandCard({required this.width, required this.brands, required this.isLoading, required this.errorMessage});

  final double width;
  final List<String> brands;
  final bool isLoading;
  final String? errorMessage;

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
                child: ValueListenableBuilder<_CarsQuery>(
                  valueListenable: _q,
                  builder: (context, q, _) {
                    return _BrandPopupField(
                      value: q.brand,
                      items: brands,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                      decoration: _controlDecoration(context, hint: 'Все бренды', icon: Icons.public),
                      onChanged: (code) {
                        _q.value = (code == null)
                            ? _q.value.copyWith(clearBrand: true)
                            : _q.value.copyWith(brand: code);
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

class _ClassCard extends CardBase {
  const _ClassCard({required this.width, required this.classes, required this.isLoading, required this.errorMessage});

  final double width;
  final List<String> classes;
  final bool isLoading;
  final String? errorMessage;

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
        const Kicker('[ЭТО КЛАСС]'),
        SizedBox(
          width: width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('[', style: bs),
              Expanded(
                child: ValueListenableBuilder<_CarsQuery>(
                  valueListenable: _q,
                  builder: (context, q, _) {
                    return _BrandPopupField(
                      value: q.carClass,
                      items: classes,
                      isLoading: isLoading,
                      errorMessage: errorMessage,
                      decoration: _controlDecoration(context, hint: 'Все классы', icon: Icons.layers),
                      onChanged: (value) {
                        _q.value = (value == null)
                            ? _q.value.copyWith(clearClass: true)
                            : _q.value.copyWith(carClass: value);
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

class _CarsControlsBlock extends StatefulWidget {
  const _CarsControlsBlock();

  @override
  State<_CarsControlsBlock> createState() => _CarsControlsBlockState();
}

class _CarsControlsBlockState extends State<_CarsControlsBlock> {
  late final TextEditingController _c;
  Timer? _searchDebounce;
  late final CarsApi _api;
  List<String> _brands = [];
  List<String> _classes = [];
  bool _isLoadingBrands = false;
  bool _isLoadingClasses = false;
  String? _brandsError;
  String? _classesError;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(text: _q.value.search);
    _api = CarsApi(createApiClient(AppConfig.dev));
    _loadBrands();
    _loadClasses();
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
    if (v.length < 2) return;
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

  Future<void> _loadBrands() async {
    if (_isLoadingBrands) return;
    setState(() {
      _isLoadingBrands = true;
      _brandsError = null;
    });

    try {
      final brands = await _api.getCarBrands();
      final uniqueBrands = {...brands}.toList();
      uniqueBrands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _brands = uniqueBrands;
        _isLoadingBrands = false;
      });
    } catch (error, stackTrace) {
      logger.warning('Failed to load car brands', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoadingBrands = false;
        _brandsError = 'Не удалось загрузить бренды';
      });
    }
  }

  Future<void> _loadClasses() async {
    if (_isLoadingClasses) return;
    setState(() {
      _isLoadingClasses = true;
      _classesError = null;
    });

    try {
      final classes = await _api.getCarClasses();
      final uniqueClasses = {...classes}.toList();
      uniqueClasses.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _classes = uniqueClasses;
        _isLoadingClasses = false;
      });
    } catch (error, stackTrace) {
      logger.warning('Failed to load car classes', error, stackTrace);
      if (!mounted) return;
      setState(() {
        _isLoadingClasses = false;
        _classesError = 'Не удалось загрузить классы';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          const spacing = 10.0;
          final isCompact = w < 560;

          final searchW = isCompact ? w : max(260.0, w * 0.45);
          final dropdownW = isCompact
              ? w
              : max(200.0, min(320.0, (w - searchW - spacing * 2) / 2));

          return Wrap(
            spacing: spacing,
            runSpacing: 12,
            children: [
              _SearchCard(controller: _c, width: searchW, onChanged: _onSearchChanged, onSubmitted: _onSearchSubmitted),
              _BrandCard(
                width: dropdownW,
                brands: _brands,
                isLoading: _isLoadingBrands,
                errorMessage: _brandsError,
              ),
              _ClassCard(
                width: dropdownW,
                classes: _classes,
                isLoading: _isLoadingClasses,
                errorMessage: _classesError,
              ),
            ],
          );
        },
      ),
    );
  }
}
