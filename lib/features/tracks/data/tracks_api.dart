import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/track_dto.dart';

class TracksPageDto {
  const TracksPageDto({
    required this.count,
    required this.currentPage,
    required this.maxPage,
    required this.data,
  });

  final int count;
  final int currentPage;
  final int maxPage;
  final List<TrackDto> data;

  factory TracksPageDto.fromJson(Map<String, dynamic> json) => TracksPageDto(
        count: json['count'] as int,
        currentPage: json['current_page'] as int,
        maxPage: json['max_page'] as int,
        data: (json['data'] as List<dynamic>)
            .map((e) => TrackDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TracksApi {
  TracksApi(this._client);

  final RestApiClient _client;

  Future<TrackDto> getTrack(int id) async {
    final response = await _client.get<TrackDto>(
      'tracks/$id',
      parse: (json) => TrackDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<TracksPageDto> getTracks({
    int? page,
    String? countryCode,
    String? search,
  }) async {
    const path = 'tracks';
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (countryCode != null && countryCode.isNotEmpty) 'country_code': countryCode,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _client.get<TracksPageDto>(
      path,
      queryParameters: query,
      parse: (json) => TracksPageDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }
}
