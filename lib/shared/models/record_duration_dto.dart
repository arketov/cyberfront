import 'participant_dto.dart';
import 'track_dto.dart';

class RecordDurationDto {
  final int id;
  final double durationHours;
  final double lapTime;
  final String className;
  final double trackDuration;
  final TrackDto track;
  final List<ParticipantDto> participants;
  final String createdAt;

  const RecordDurationDto({
    required this.id,
    required this.durationHours,
    required this.lapTime,
    required this.className,
    required this.trackDuration,
    required this.track,
    required this.participants,
    required this.createdAt,
  });

  factory RecordDurationDto.fromJson(Map<String, dynamic> json) =>
      RecordDurationDto(
        id: json['id'] as int,
        durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 0.0,
        lapTime: (json['lap_time'] as num?)?.toDouble() ?? 0.0,
        className: (json['class_name'] as String?) ?? '',
        trackDuration: (json['track_duration'] as num?)?.toDouble() ?? 0.0,
        track: TrackDto.fromJson(json['track'] as Map<String, dynamic>),
        participants: (json['participants'] as List<dynamic>)
            .map((p) => ParticipantDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: (json['created_at'] as String?) ?? '',
      );
}
