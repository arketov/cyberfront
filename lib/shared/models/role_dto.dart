class RoleDto {
  final int id;
  final String name;

  const RoleDto({
    required this.id,
    required this.name,
  });

  factory RoleDto.fromJson(Map<String, dynamic> json) => RoleDto(
        id: json['id'] as int,
        name: json['name'] as String,
      );
}
