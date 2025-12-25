class CarDto {
  final int id;
  final String country;
  final String brand;
  final String model;
  final int power;
  final int torque;
  final double massPowerRatio;
  final String transmission;
  final String imageHash;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const CarDto({
    required this.id,
    required this.country,
    required this.brand,
    required this.model,
    required this.power,
    required this.torque,
    required this.massPowerRatio,
    required this.transmission,
    required this.imageHash,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    return value?.toString() ?? '';
  }

  factory CarDto.fromJson(Map<String, dynamic> json) => CarDto(
        id: json['id'] as int,
        country: _readString(json, 'country'),
        brand: _readString(json, 'brand'),
        model: _readString(json, 'model'),
        power: json['power'] as int,
        torque: json['torque'] as int,
        massPowerRatio: (json['mass_power_ratio'] as num).toDouble(),
        transmission: _readString(json, 'transmission'),
        imageHash: _readString(json, 'image_hash'),
        createdAt: _readString(json, 'created_at'),
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as String?,
      );
}
