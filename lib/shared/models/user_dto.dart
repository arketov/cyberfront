import 'json_utils.dart';
import 'role_dto.dart';

class UserDto {
  final int id;
  final String login;
  final String name;
  final String email;
  final RoleDto role;
  final String imageHash;

  const UserDto({
    required this.id,
    required this.login,
    required this.name,
    required this.email,
    required this.role,
    required this.imageHash,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
        id: JsonUtils.asInt(json['id']) ?? 0,
        login: JsonUtils.asString(json['login']) ?? '',
        name: JsonUtils.asString(json['name']) ?? '',
        email: JsonUtils.asString(json['email']) ?? '',
        role: RoleDto.fromJson(json['role'] as Map<String, dynamic>),
        imageHash: JsonUtils.asString(json['image_hash']) ?? '',
      );
}
