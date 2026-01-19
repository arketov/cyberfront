import 'package:cyberdriver/shared/models/user_dto.dart';

class AuthSession {
  final String accessToken;
  final String tokenType;
  final UserDto user;

  const AuthSession({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: (json['access_token'] as String?) ?? '',
        tokenType: (json['token_type'] as String?) ?? 'bearer',
        user: UserDto.fromJson((json['user'] as Map<String, dynamic>?) ?? const {}),
      );

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'user': user.toJson(),
      };
}
