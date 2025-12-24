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
        id: json['id'] as int,
        login: json['login'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        role: RoleDto.fromJson(json['role'] as Map<String, dynamic>),
        imageHash: json['image_hash'] as String,
      );
}
