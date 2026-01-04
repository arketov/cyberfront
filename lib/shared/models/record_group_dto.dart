import 'json_utils.dart';
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
        id: JsonUtils.asInt(json['id']) ?? 0,
        lapTime: JsonUtils.asDouble(json['lap_time']) ?? 0.0,
        minMassPowerRatio: JsonUtils.asDouble(json['min_mass_power_ratio']) ?? 0.0,
        track: TrackDto.fromJson(json['track'] as Map<String, dynamic>),
        participants: (json['participants'] as List<dynamic>)
            .map((p) => ParticipantDto.fromJson(p as Map<String, dynamic>))
            .toList(),
        createdAt: JsonUtils.asString(json['created_at']) ?? '',
      );
}
