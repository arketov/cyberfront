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

  factory CarDto.fromJson(Map<String, dynamic> json) => CarDto(
        id: json['id'] as int,
        country: json['country'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        power: json['power'] as int,
        torque: json['torque'] as int,
        massPowerRatio: (json['mass_power_ratio'] as num).toDouble(),
        transmission: json['transmission'] as String,
        imageHash: json['image_hash'] as String,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as String?,
      );
}
