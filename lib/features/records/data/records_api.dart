import 'package:cyberdriver/core/network/network.dart';

import 'package:cyberdriver/shared/models/record_duration_dto.dart';
import 'package:cyberdriver/shared/models/record_group_dto.dart';
import 'package:cyberdriver/shared/models/record_personal_dto.dart';

class RecordsApi {
  RecordsApi(this._client);

  final RestApiClient _client;

  Future<List<RecordGroupDto>> getTopGroups({
    int limit = 10,
    int? trackId,
    int? carId,
  }) async {
    const path = 'records/top/group';
    final queryParameters = <String, dynamic>{'limit': limit};
    if (trackId != null) {
      queryParameters['track_id'] = trackId;
    }
    if (carId != null) {
      queryParameters['car_id'] = carId;
    }
    final response = await _client.get<List<RecordGroupDto>>(
      path,
      queryParameters: queryParameters,
      parse: (json) => (json as List<dynamic>)
          .map((e) => RecordGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<List<RecordDurationDto>> getTopDurations({
    int limit = 10,
    int? trackId,
    int? carId,
  }) async {
    const path = 'records/top/duration';
    final queryParameters = <String, dynamic>{'limit': limit};
    if (trackId != null) {
      queryParameters['track_id'] = trackId;
    }
    if (carId != null) {
      queryParameters['car_id'] = carId;
    }
    final response = await _client.get<List<RecordDurationDto>>(
      path,
      queryParameters: queryParameters,
      parse: (json) => (json as List<dynamic>)
          .map((e) => RecordDurationDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }

  Future<List<RecordPersonalDto>> getTopPersonal({
    int limit = 10,
    int? trackId,
    int? carId,
  }) async {
    const path = 'records/top/personal';
    final queryParameters = <String, dynamic>{'limit': limit};
    if (trackId != null) {
      queryParameters['track_id'] = trackId;
    }
    if (carId != null) {
      queryParameters['car_id'] = carId;
    }
    final response = await _client.get<List<RecordPersonalDto>>(
      path,
      queryParameters: queryParameters,
      parse: (json) => (json as List<dynamic>)
          .map((e) => RecordPersonalDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }
}
