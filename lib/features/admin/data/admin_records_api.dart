import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';

class AdminRecordParticipant {
  const AdminRecordParticipant({
    required this.userId,
    required this.carId,
  });

  final int userId;
  final int carId;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'car_id': carId,
      };
}

class AdminRecordsApi {
  AdminRecordsApi(this._client);

  final RestApiClient _client;

  Future<void> createGroupRecordWithAuth({
    required AuthService auth,
    required int trackId,
    required double lapTimeSeconds,
    required double minMassPowerRatio,
    required List<AdminRecordParticipant> participants,
  }) {
    return auth.withAuth((token) async {
      await _client.post<void>(
        'admin/records/group',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'track_id': trackId,
          'lap_time': lapTimeSeconds,
          'min_mass_power_ratio': minMassPowerRatio,
          'participants': participants.map((p) => p.toJson()).toList(),
        },
        parse: (_) => null,
      );
    });
  }

  Future<void> createGroupDurationRecordWithAuth({
    required AuthService auth,
    required int trackId,
    required double durationHours,
    required double lapTimeSeconds,
    required String className,
    required double trackDuration,
    required List<AdminRecordParticipant> participants,
  }) {
    return auth.withAuth((token) async {
      await _client.post<void>(
        'admin/records/group-duration',
        headers: {'Authorization': 'Bearer $token'},
        body: {
          'track_id': trackId,
          'duration_hours': durationHours,
          'lap_time': lapTimeSeconds,
          'class_name': className,
          'track_duration': trackDuration,
          'participants': participants.map((p) => p.toJson()).toList(),
        },
        parse: (_) => null,
      );
    });
  }
}
