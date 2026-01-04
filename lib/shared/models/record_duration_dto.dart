import 'json_utils.dart';
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
        id: JsonUtils.asInt(json['id']) ?? 0,
        durationHours: JsonUtils.asDouble(json['duration_hours']) ?? 0.0,
        lapTime: JsonUtils.asDouble(json['lap_time']) ?? 0.0,
        className: JsonUtils.asString(json['class_name']) ?? '',
        trackDuration: JsonUtils.asDouble(json['track_duration']) ?? 0.0,
        track: TrackDto.fromJson(json['track'] as Map<String, dynamic>),
        participants: (json['participants'] as List<dynamic>)
            .map((p) => ParticipantDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: JsonUtils.asString(json['created_at']) ?? '',
      );
}
