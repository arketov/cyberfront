// lib/features/tracks/countries_ru.dart

class CountryRu {
  const CountryRu(this.code, this.nameRu);
  final String code;
  final String nameRu;
}

String countryNameRu(String code) => _map[code.toUpperCase()] ?? code.toUpperCase();

List<CountryRu> countriesRuSorted() {
  final list = _map.entries.map((e) => CountryRu(e.key, e.value)).toList();
  list.sort((a, b) => a.nameRu.compareTo(b.nameRu));
  return list;
}

/// Минимальный набор — добавляй по мере надобности.
const Map<String, String> _map = {
  'RU': 'Россия',
  'BY': 'Беларусь',
  'KZ': 'Казахстан',
  'UA': 'Украина',
  'GE': 'Грузия',
  'AM': 'Армения',
  'AZ': 'Азербайджан',

  'DE': 'Германия',
  'AT': 'Австрия',
  'CH': 'Швейцария',
  'FR': 'Франция',
  'IT': 'Италия',
  'ES': 'Испания',
  'PT': 'Португалия',
  'NL': 'Нидерланды',
  'BE': 'Бельгия',
  'GB': 'Великобритания',
  'IE': 'Ирландия',
  'SE': 'Швеция',
  'NO': 'Норвегия',
  'FI': 'Финляндия',
  'DK': 'Дания',
  'PL': 'Польша',
  'CZ': 'Чехия',
  'SK': 'Словакия',
  'HU': 'Венгрия',
  'RO': 'Румыния',
  'BG': 'Болгария',
  'GR': 'Греция',
  'TR': 'Турция',

  'US': 'США',
  'CA': 'Канада',
  'MX': 'Мексика',
  'BR': 'Бразилия',
  'AR': 'Аргентина',

  'JP': 'Япония',
  'CN': 'Китай',
  'KR': 'Южная Корея',
  'IN': 'Индия',

  'AE': 'ОАЭ',
  'SA': 'Саудовская Аравия',

  'AU': 'Австралия',
  'NZ': 'Новая Зеландия',
};
