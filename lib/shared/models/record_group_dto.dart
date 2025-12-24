import 'participant_dto.dart';
import 'track_dto.dart';

class RecordGroupDto {
  final int id;
  final double lapTime;
  final double minMassPowerRatio;
  final TrackDto track;
  final List<ParticipantDto> participants;
  final String createdAt;

  const RecordGroupDto({
    required this.id,
    required this.lapTime,
    required this.minMassPowerRatio,
    required this.track,
    required this.participants,
    required this.createdAt,
  });

  factory RecordGroupDto.fromJson(Map<String, dynamic> json) => RecordGroupDto(
        id: json['id'] as int,
        lapTime: (json['lap_time'] as num).toDouble(),
        minMassPowerRatio: (json['min_mass_power_ratio'] as num).toDouble(),
        track: TrackDto.fromJson(json['track'] as Map<String, dynamic>),
        participants: (json['participants'] as List<dynamic>)
            .map((p) => ParticipantDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: json['created_at'] as String,
      );
}
