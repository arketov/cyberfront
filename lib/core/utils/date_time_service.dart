class DateTimeService {
  const DateTimeService._();

  static DateTime? toLocal(String? utcValue) {
    if (utcValue == null || utcValue.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(utcValue);
    if (parsed == null) return null;
    return parsed.toLocal();
  }

  static String formatDayMonth(DateTime? value) {
    if (value == null) return '';
    const months = [
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];
    final month = months[(value.month - 1).clamp(0, months.length - 1)];
    return '${value.day} $month';
  }

  static String formatTime(DateTime? value) {
    if (value == null) return '';
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
