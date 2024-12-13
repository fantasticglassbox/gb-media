import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gb_media/app/app_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/app_preferences.dart';
import '../di/service_locator.dart';
import '../model/ads.dart';

class AdsProvider extends ChangeNotifier {
  List<AdsModel> _ads = [];
  static const String _cacheKey = 'cached_ads_data';
  final appPreferences = getIt<AppPreferences>();
  List<AdsModel> get ads => _ads;

  Future<void> updateAds(List<AdsModel> newAds) async {
    print('updateAds here');
    _ads = newAds;
    await _cacheAdsData(newAds);
    notifyListeners();
  }

  Future<void> _cacheAdsData(List<AdsModel> ads) async {
    try {

      // Cache the ads metadata
      // final adsData = ads.map((ad) => ad.toJson()).toList();


      // Cache the actual media files
      final directory = await getApplicationDocumentsDirectory();
      for (var ad in ads) {
        final fileName = ad.content.split('/').last;
        final file = File('${directory.path}/$fileName');

        // Only download if file doesn't exist
        if (!await file.exists()) {
          try {
            final response = await HttpClient().getUrl(Uri.parse(ad.content));
            final httpResponse = await response.close();
            await httpResponse.pipe(file.openWrite());

            // Update the cached file path
            ad.cachedFilePath = file.path;
          } catch (e) {
            print('Error caching file ${ad.content}: $e');
          }
        }
      }
      // appPreferences.putCachedContent();
      appPreferences.putCachedValue(jsonEncode(ads));
    } catch (e) {
      print('Error caching ads data: $e');
    }
  }

  Future<List<AdsModel>> loadCachedAds() async {
    try {
      String? adsCached = appPreferences.getCachedAds();
      if (adsCached != null) {
        final directory = await getApplicationDocumentsDirectory();
        _ads = adsFromJson(adsCached);

        // Verify and update cached file paths
        for (var ad in _ads) {
          final fileName = ad.content.split('/').last;
          final file = File('${directory.path}/$fileName');
          debugPrint('checking file: ${ad.content}');
          if (await file.exists()) {
            debugPrint('Cached file exists: ${file.path}');
            ad.cachedFilePath = file.path; // Assign the correct path
          } else {
            debugPrint('Cached file not found: ${file.path}');
            ad.cachedFilePath = null; // Mark as null if the file doesn't exist
          }
        }
        notifyListeners();
      }
      return _ads;
    } catch (e) {
      debugPrint('Error loading cached ads: $e');
      return [];
    }
  }


  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);

      final directory = await getApplicationDocumentsDirectory();
      for (var ad in _ads) {
        if (ad.cachedFilePath != null) {
          final file = File(ad.cachedFilePath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }

      _ads = [];
      notifyListeners();
    } catch (e) {
      print('Error clearing ads cache: $e');
    }
  }

  bool hasValidCache() {
    return _ads.every((ad) => ad.cachedFilePath != null);
  }
}
