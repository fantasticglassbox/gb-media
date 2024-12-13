import 'package:flutter/material.dart';
import 'package:gb_media/pages/connectivity.dart';
import 'package:gb_media/pages/idle.dart';
import 'package:gb_media/routes/routes.dart';
class RoutesGenerator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const ConnectivityPage(),
          settings: routeSettings,
        );
      case Routes.startAds:
        return MaterialPageRoute(
          builder: (_) =>  Idle(),
          settings: routeSettings,
        );
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: const Center(
          child: Text(''),
        ),
      ),
    );
  }
}
