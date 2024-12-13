import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdsModel {
  final String content;
  final String type;
  final int duration;
  String? cachedFilePath;

  AdsModel({
    required this.content,
    required this.type,
    required this.duration,
    this.cachedFilePath,
  });

  Map<String, dynamic> toJson() => {
        'content': content,
        'type': type,
        'duration': duration,
        'cachedFilePath': cachedFilePath,
      };

  factory AdsModel.fromJson(Map<String, dynamic> json) => AdsModel(
        content: json['content'],
        type: json['type'],
        duration: json['duration'],
        cachedFilePath: json['cachedFilePath'],
      );
  // Factory constructor to create an instance from a Map
  factory AdsModel.fromMap(Map<String, dynamic> map) {
    return AdsModel(
      content: map['content'] as String,
      type: map['type'] as String,
      duration: map['duration'] as int,
      cachedFilePath: map['cachedFilePath'] as String?,
    );
  }

  // Method to convert an instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'type': type,
      'duration': duration,
      'cachedFilePath': cachedFilePath,
    };
  }
}


List<AdsModel> adsFromJson(String str) {
  final List<dynamic> jsonData = json.decode(str);
  return jsonData.map((x) => AdsModel.fromJson(x)).toList();
}
Future<List<AdsModel>> _getCachedAds() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Retrieve the JSON string from SharedPreferences
    final jsonString = prefs.getString('flutter.cached_ads_data');
    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('No cached ads found.');
      return [];
    }

    // Decode the JSON string into a list of maps
    final List<dynamic> adsList = jsonDecode(jsonString);

    // Map the list of maps to a list of AdsModel objects
    final ads = adsList.map((adMap) => AdsModel.fromMap(adMap as Map<String, dynamic>)).toList();

    debugPrint('Retrieved cached ads: $ads');
    return ads;
  } catch (e) {
    debugPrint('Error retrieving cached ads: $e');
    return [];
  }
}
