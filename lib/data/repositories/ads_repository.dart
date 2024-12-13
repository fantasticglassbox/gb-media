import 'dart:convert';
import 'package:gb_media/data/api_client.dart';
import 'package:gb_media/model/ads.dart';

class AdsRepository {
  final ApiClient apiClient;

  AdsRepository(this.apiClient);

  Future<List<AdsModel>> getAds(String token) async {

    final response = await apiClient.get(
      '/v1/merchants/ads',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode <= 300) {
      final List<dynamic> adsData = json.decode(response.body);
    return adsData.map((data) => AdsModel.fromJson(data)).toList();
    } else {
      throw Exception(response.body);
    }
  }
} 