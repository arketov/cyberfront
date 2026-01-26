import 'json_utils.dart';

class RegTokenDto {
  const RegTokenDto({
    required this.regToken,
    required this.descr,
    required this.createdAt,
  });

  final String regToken;
  final String descr;
  final String? createdAt;

  factory RegTokenDto.fromJson(Map<String, dynamic> json) => RegTokenDto(
        regToken: JsonUtils.asString(json['reg_token']) ?? '',
        descr: JsonUtils.asString(json['descr']) ?? '',
        createdAt: JsonUtils.asString(json['created_at']),
      );
}
