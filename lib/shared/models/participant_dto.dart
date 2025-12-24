import 'car_dto.dart';
import 'user_dto.dart';

class ParticipantDto {
  final UserDto user;
  final CarDto car;

  const ParticipantDto({
    required this.user,
    required this.car,
  });

  factory ParticipantDto.fromJson(Map<String, dynamic> json) => ParticipantDto(

        user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
        car: CarDto.fromJson(json['car'] as Map<String, dynamic>),
      );
}
