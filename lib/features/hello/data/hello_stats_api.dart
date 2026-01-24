import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/cyber_stats_dto.dart';

class HelloStatsApi {
  HelloStatsApi(this._client);

  final RestApiClient _client;

  Future<CyberStatsDto> getCyberStats() async {
    final response = await _client.get<CyberStatsDto>(
      'cyber/stats',
      parse: (json) => CyberStatsDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
