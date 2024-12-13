import 'dart:convert';

import 'package:gb_media/app/extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  final SharedPreferences _preferences;
  final String _kAccessToken = "access_token";
  final String _kRefreshToken = "refresh_token";

  final String _cachedAdsValue = "cached_ads_value";

  AppPreferences(this._preferences);

  void insertAccessToken(String? token) {
    _preferences.setString(_kAccessToken, token.orEmpty());
  }

  void insertRefreshToken(String? token) {
    _preferences.setString(_kRefreshToken, token.orEmpty());
  }

  String? retrieveRefreshToken() {
    return _preferences.getString(_kRefreshToken);
  }

  String? retrieveAccessToken() {
    return _preferences.getString(_kAccessToken.orEmpty());
  }
  void putCachedValue(String s) {
    _preferences.setString(_cachedAdsValue,s);
  }
  String? getCachedAds() {
    return _preferences.getString(_cachedAdsValue.orEmpty());
  }

  void clearCache(){
    _preferences.remove(_cachedAdsValue);
  }
}
