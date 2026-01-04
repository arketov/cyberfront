import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/car_dto.dart';

class CarSkinDto {
  const CarSkinDto({
    required this.id,
    required this.carId,
    required this.imageHash,
    required this.skinName,
    required this.priority,
  });

  final int id;
  final int carId;
  final String imageHash;
  final String skinName;
  final int priority;

  factory CarSkinDto.fromJson(Map<String, dynamic> json) => CarSkinDto(
        id: json['id'] as int,
        carId: json['car_id'] as int,
        imageHash: json['image_hash'] as String? ?? '',
        skinName: json['skinname'] as String? ?? '',
        priority: json['priority'] as int? ?? 0,
      );
}

class CarsPageDto {
  const CarsPageDto({
    required this.count,
    required this.currentPage,
    required this.maxPage,
    required this.data,
  });

  final int count;
  final int currentPage;
  final int maxPage;
  final List<CarDto> data;

  factory CarsPageDto.fromJson(Map<String, dynamic> json) => CarsPageDto(
        count: json['count'] as int,
        currentPage: json['current_page'] as int,
        maxPage: json['max_page'] as int,
        data: (json['data'] as List<dynamic>)
            .map((e) => CarDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CarsApi {
  CarsApi(this._client);

  final RestApiClient _client;

  Future<CarDto> getCar(int id) async {
    final response = await _client.get<CarDto>(
      'cars/$id',
      parse: (json) => CarDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<CarsPageDto> getCars({
    int? page,
    String? brand,
    String? carClass,
    String? search,
  }) async {
    const path = 'cars';
    final query = <String, dynamic>{
      if (page != null) 'page': page,
      if (brand != null && brand.isNotEmpty) 'brand': brand,
      if (carClass != null && carClass.isNotEmpty) 'class': carClass,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final response = await _client.get<CarsPageDto>(
      path,
      queryParameters: query,
      parse: (json) => CarsPageDto.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  Future<List<String>> getCarBrands() async {
    const path = 'cars/filters';
    final response = await _client.get<dynamic>(
      path,
      parse: (json) => json,
    );
    final data = response.data;
    return _parseBrands(data);
  }

  Future<List<String>> getCarClasses() async {
    const path = 'cars/filters';
    final response = await _client.get<dynamic>(
      path,
      parse: (json) => json,
    );
    final data = response.data;
    return _parseClasses(data);
  }

  List<String> _parseBrands(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (data is Map<String, dynamic>) {
      final raw = data['brand'] ?? data['brands'] ?? data['data'] ?? data['items'];
      if (raw is List) {
        return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
    }
    return const [];
  }

  List<String> _parseClasses(dynamic data) {
    if (data is List) {
      return data.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    if (data is Map<String, dynamic>) {
      final raw = data['class'] ?? data['classes'] ?? data['data'] ?? data['items'];
      if (raw is List) {
        return raw.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
      }
    }
    return const [];
  }

  Future<List<CarSkinDto>> getCarSkins(int carId) async {
    final response = await _client.get<List<CarSkinDto>>(
      'cars/$carId/skins',
      parse: (json) => (json as List<dynamic>)
          .map((e) => CarSkinDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
    return response.data;
  }
}
