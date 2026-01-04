import 'json_utils.dart';

class CarDto {
  final int id;
  final String country;
  final String name;
  final String brand;
  final String model;
  final String power;
  final String torque;
  final String massPowerRatio;
  final String? transmission;
  final String? descr;
  final List<String> tags;
  final String? carClass;
  final String? weight;
  final String? topspeed;
  final String? acceleration;
  final String? pwratio;
  final String? range;
  final List<CarCurvePoint> powerCurve;
  final List<CarCurvePoint> torqueCurve;
  final String imageHash;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const CarDto({
    required this.id,
    required this.country,
    required this.name,
    required this.brand,
    required this.model,
    required this.power,
    required this.torque,
    required this.massPowerRatio,
    required this.transmission,
    required this.descr,
    required this.tags,
    required this.carClass,
    required this.weight,
    required this.topspeed,
    required this.acceleration,
    required this.pwratio,
    required this.range,
    required this.powerCurve,
    required this.torqueCurve,
    required this.imageHash,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CarDto.fromJson(Map<String, dynamic> json) => CarDto(
        id: JsonUtils.asInt(json['id']) ?? 0,
        country: JsonUtils.asString(json['country']) ?? '',
        name: JsonUtils.asString(json['name']) ?? '',
        brand: JsonUtils.asString(json['brand']) ?? '',
        model: JsonUtils.asString(json['model']) ?? '',
        power: JsonUtils.asString(json['power']) ?? '',
        torque: JsonUtils.asString(json['torque']) ?? '',
        massPowerRatio: JsonUtils.asString(json['mass_power_ratio']) ?? '',
        transmission: JsonUtils.asString(json['transmission']),
        descr: JsonUtils.asString(json['descr']),
        tags: (json['tags'] is List)
            ? (json['tags'] as List<dynamic>).map((e) => e.toString()).toList()
            : const [],
        carClass: JsonUtils.asString(json['class']),
        weight: JsonUtils.asString(json['weight']),
        topspeed: JsonUtils.asString(json['topspeed']),
        acceleration: JsonUtils.asString(json['acceleretion']),
        pwratio: JsonUtils.asString(json['pwratio']),
        range: JsonUtils.asString(json['range']),
        powerCurve: _parseCurve(json['power_curve']),
        torqueCurve: _parseCurve(json['torque_curve']),
        imageHash: JsonUtils.asString(json['image_hash']) ?? '',
        createdAt: JsonUtils.asString(json['created_at']) ?? '',
        updatedAt: JsonUtils.asString(json['updated_at']),
        deletedAt: JsonUtils.asString(json['deleted_at']),
      );

  static List<CarCurvePoint> _parseCurve(Object? raw) {
    if (raw is! List) return const [];
    final points = <CarCurvePoint>[];
    for (final item in raw) {
      if (item is List && item.length >= 2) {
        final rpm = JsonUtils.asInt(item[0]);
        final value = JsonUtils.asDouble(item[1]);
        if (rpm != null && value != null) {
          points.add(CarCurvePoint(rpm: rpm, value: value));
        }
      }
    }
    return points;
  }
}

class CarCurvePoint {
  const CarCurvePoint({required this.rpm, required this.value});

  final int rpm;
  final double value;
}
