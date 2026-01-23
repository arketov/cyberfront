class RunStatsFormat {
  const RunStatsFormat._();

  static String distanceKmValue(int meters) {
    final km = meters / 1000.0;
    return km.toStringAsFixed(1);
  }

  static String distanceKmLabel(int meters) {
    return '${distanceKmValue(meters)} км';
  }

  static String durationHours(int minutes) {
    final hours = minutes <= 0 ? 0 : minutes ~/ 60;
    return hours.toString();
  }

  static String durationMinutes(int minutes) {
    final mins = minutes <= 0 ? 0 : minutes % 60;
    return mins.toString().padLeft(2, '0');
  }

  static String durationLong(int minutes) {
    if (minutes <= 0) return '0 минут';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours <= 0) return '$mins минут';
    return '$hours час $mins минут';
  }
}
