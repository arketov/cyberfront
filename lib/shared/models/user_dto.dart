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

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final roleJson = json['role'];
    final role = roleJson is Map<String, dynamic>
        ? RoleDto.fromJson(roleJson)
        : const RoleDto(id: 0, name: '');
    return UserDto(
      id: JsonUtils.asInt(json['id']) ?? 0,
      login: JsonUtils.asString(json['login']) ?? '',
      name: JsonUtils.asString(json['name']) ?? '',
      email: JsonUtils.asString(json['email']) ?? '',
      role: role,
      imageHash: JsonUtils.asString(json['image_hash']) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'login': login,
        'name': name,
        'email': email,
        'role': role.toJson(),
        'image_hash': imageHash,
      };
}
