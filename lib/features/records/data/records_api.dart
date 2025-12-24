import 'package:cyberdriver/core/network/network.dart';

import 'package:cyberdriver/shared/models/record_group_dto.dart';

class RecordsApi {
  RecordsApi(this._client);

  final RestApiClient _client;

  Future<List<RecordGroupDto>> getTopGroups({int limit = 10}) async {
    const path = 'records/top/group';
    final response = await _client.get<List<RecordGroupDto>>(
      path,
      queryParameters: {'limit': limit},
      parse: (json) => (json as List<dynamic>)
          .map((e) => RecordGroupDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }
}
