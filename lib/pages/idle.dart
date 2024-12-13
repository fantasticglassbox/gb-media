import 'dart:async'; // Import for Timer
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gb_media/pages/carousel.dart';
import 'package:gb_media/providers/ads.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_preferences.dart';
import '../data/repositories/ads_repository.dart';
import '../di/service_locator.dart';
import '../manager/connectivity.dart';
import '../model/ads.dart';

final getIt = GetIt.instance;

class Idle extends StatefulWidget {
  Idle({Key? key}) : super(key: key);

  @override
  _IdleState createState() => _IdleState();
}

class _IdleState extends State<Idle> {
  late TextEditingController _editingController;
  Timer? _adsRefreshTimer;
  final _adsRepository = getIt<AdsRepository>();
  final _preferences = getIt<AppPreferences>();
  final _connectivity = getIt<GbConnectivity>();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
    _fetchAdsFromServer(); // Fetch ads initially
    _startAdsRefreshTimer(); // Start the timer to fetch ads regularly
    _fetchCachedContent();
  }

  @override
  void dispose() {
    _editingController.dispose();
    _adsRefreshTimer?.cancel(); // Cancel the timer when widget is disposed
    super.dispose();
  }

  Future<void> _fetchCachedContent() async {
    print('fetch cached ads');
    try {
      final cachedAds = await context
          .read<AdsProvider>().loadCachedAds();
      context
          .read<AdsProvider>()
          .updateAds(cachedAds); // Use updateAds instead of direct assignment


    } catch (error) {
      print('Error fetching cached ads: $error');
    }
  }
  // Method to fetch ads from the server
  Future<void> _fetchAdsFromServer() async {
    print('fetch new ads');
    if (!await _connectivity.hasNetwork()) {
      return;
    }
    try {
      final token = _preferences.retrieveAccessToken();
      print('token $token');
      final adsList = await _adsRepository.getAds(token ?? '');
      await context
          .read<AdsProvider>()
          .updateAds(adsList); // Use updateAds instead of direct assignment

      print('new ads ${adsList.length}');
    } catch (error) {
      print('Error fetching ads: $error');
    }
  }

  // Method to start the timer to refresh ads
  void _startAdsRefreshTimer() {
    _adsRefreshTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _fetchAdsFromServer(); // Fetch ads every 30 seconds
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF000000),
      child: Consumer<AdsProvider>(
        builder: (context, adsProvider, child) {
          print('Building Carousel with ${adsProvider.ads.length} ads');
          return Stack(
            children: [
              Carousel(ads: adsProvider.ads),
            ],
          );
        },
      ),
    );
  }

  void closeDialog() {
    Navigator.of(context, rootNavigator: true).pop();
    _editingController.clear();
  }

  void submitPack() {
    Navigator.of(context).pop(_editingController.text);
    _editingController.clear();
  }
}
