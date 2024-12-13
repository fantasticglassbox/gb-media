import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class GbConnectivity {
  Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('api.glassbox.id');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<bool> isNetworkConnected() async {
    try {
      // First check if WiFi is enabled
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.wifi) {
        return false;
      }

      // Then check if we have actual internet connectivity
      final hasInternet = await hasNetwork();
      return hasInternet;
    } catch (e) {
      print('Error checking WiFi connection: $e');
      return false;
    }
  }
}
