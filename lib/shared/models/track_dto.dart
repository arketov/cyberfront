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
  final double lengthKm;
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
        id: json['id'] as int,
        country: (json['country_code'] ?? json['country']) as String,
        city: (json['city'] ?? json['city_name']) as String?,
        name: json['name'] as String,
        tags: (json['tags'] as List?)?.map((e) => e.toString()).toList(),
        geoLat: (json['geo_lat'] as num?)?.toDouble(),
        geoLon: (json['geo_lon'] as num?)?.toDouble(),
        width: json['width'] as String?,
        pitboxes: json['pitboxes'] as String?,
        year: (json['year'] as num?)?.toInt(),
        run: json['run'] as String?,
        description: json['description'] as String?,
        lengthKm: (json['length_km'] as num).toDouble(),
        imageHash: json['image_hash'] as String,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String?,
        deletedAt: json['deleted_at'] as String?,
      );
}
