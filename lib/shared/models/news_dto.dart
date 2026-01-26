import 'json_utils.dart';

class NewsDto {
  final int id;
  final String title;
  final int readMinutes;
  final int userId;
  final String body;
  final List<String> imagesHash;
  final String? createdAt;

  const NewsDto({
    required this.id,
    required this.title,
    required this.readMinutes,
    required this.userId,
    required this.body,
    required this.imagesHash,
    required this.createdAt,
  });

  factory NewsDto.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images_hash'];
    final images = <String>[];
    if (rawImages is List) {
      images.addAll(
        rawImages
            .map((e) => JsonUtils.asString(e) ?? '')
            .where((e) => e.isNotEmpty),
      );
    } else if (rawImages != null) {
      final value = JsonUtils.asString(rawImages);
      if (value != null && value.isNotEmpty) {
        images.add(value);
      }
    }

    return NewsDto(
      id: JsonUtils.asInt(json['id']) ?? 0,
      title: JsonUtils.asString(json['title']) ?? '',
      readMinutes: JsonUtils.asInt(json['read_minutes']) ?? 0,
      userId: JsonUtils.asInt(json['user_id']) ?? 0,
      body: JsonUtils.asString(json['body']) ?? '',
      imagesHash: images,
      createdAt: JsonUtils.asString(json['created_at']),
    );
  }
}
