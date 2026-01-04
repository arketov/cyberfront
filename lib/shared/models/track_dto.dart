import 'json_utils.dart';

class TrackDto {
  final int id;
  final String country;
  final String? city;
  final String name;
  final List<String>? tags;
  final double? geoLat;
  final double? geoLon;
  final String? width;
  final String? pitboxes;
  final int? year;
  final String? run;
  final String? description;
  final String lengthKm;
  final String imageHash;
  final String createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const TrackDto({
    required this.id,
    required this.country,
    this.city,
    required this.name,
    this.tags,
    this.geoLat,
    this.geoLon,
    this.width,
    this.pitboxes,
    this.year,
    this.run,
    this.description,
    required this.lengthKm,
    required this.imageHash,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory TrackDto.fromJson(Map<String, dynamic> json) => TrackDto(
        id: JsonUtils.asInt(json['id']) ?? 0,
        country: JsonUtils.asString(json['country_code'] ?? json['country']) ?? '',
        city: JsonUtils.asString(json['city'] ?? json['city_name']),
        name: JsonUtils.asString(json['name']) ?? '',
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        geoLat: JsonUtils.asDouble(json['geo_lat']),
        geoLon: JsonUtils.asDouble(json['geo_lon']),
        width: JsonUtils.asString(json['width']),
        pitboxes: JsonUtils.asString(json['pitboxes']),
        year: JsonUtils.asInt(json['year']),
        run: JsonUtils.asString(json['run']),
        description: JsonUtils.asString(json['description']),
        lengthKm: JsonUtils.asString(json['length_km']) ?? '-',
        imageHash: JsonUtils.asString(json['image_hash']) ?? '',
        createdAt: JsonUtils.asString(json['created_at']) ?? '',
        updatedAt: JsonUtils.asString(json['updated_at']),
        deletedAt: JsonUtils.asString(json['deleted_at']),
      );
}
