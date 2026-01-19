import 'json_utils.dart';

class RoleDto {
  final int id;
  final String name;

  const RoleDto({
    required this.id,
    required this.name,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) => RoleDto(
        id: JsonUtils.asInt(json['id']) ?? 0,
        name: JsonUtils.asString(json['name']) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}
