import 'dart:convert';
import 'package:gb_media/data/api_client.dart';
import 'package:gb_media/model/ads.dart';

import '../../model/login_request.dart';
import '../../model/login_response.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);
  Future<LoginResponse> login(LoginRequest request, String? token) async {
    final response = await apiClient.post(
      '/v1/public/device/login',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      print('Failed to login: ${response.statusCode}');
      return Future.value(null);
    }
  }
}
