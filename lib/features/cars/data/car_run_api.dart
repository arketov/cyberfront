import 'package:cyberdriver/core/auth/auth_service.dart';
import 'package:cyberdriver/core/network/network.dart';
import 'package:cyberdriver/shared/models/user_car_run_dto.dart';

class CarRunApi {
  CarRunApi(this._client);

  final RestApiClient _client;

  Future<UserCarRunDto> getCarRunWithAuth(
    AuthService auth,
    int userId,
    int carId,
  ) {
    return auth.withAuth((token) async {
      final response = await _client.get<UserCarRunDto>(
        'users/$userId/cars/$carId/run',
        headers: {'Authorization': 'Bearer $token'},
        parse: (json) => UserCarRunDto.fromJson(json as Map<String, dynamic>),
      );
      return response.data;
    });
  }
}
