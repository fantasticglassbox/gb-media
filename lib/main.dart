import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:gb_media/env/environment_variables.dart';
import 'package:gb_media/pages/glassbox.dart';
import 'package:gb_media/providers/ads.dart';
import 'package:gb_media/providers/scheduler_provider.dart';
import 'package:gb_media/di/service_locator.dart';
import 'package:gb_media/routes/routes.dart';
import 'package:gb_media/routes/routes_generator.dart';
import 'package:provider/provider.dart';
import 'package:gb_media/services/scheduler_service.dart';

Future<void> mainCommon(EnvironmentVariables env) async {
  WidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();

  // Initialize scheduler service with navigation callback
  await SchedulerService(
    onWakeUp: () {
      navigatorKey.currentState?.pushReplacementNamed(Routes.splash);
    },
  ).initialize();

  // Force landscape orientation and full screen
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  await setupServiceLocator(env);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdsProvider()),
        ChangeNotifierProvider(create: (_) => SchedulerProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: EdgeInsets.zero,
            ),
            child: child!,
          );
        },
        onGenerateRoute: RoutesGenerator.generateRoute,
        initialRoute: Routes.splash
        ,
      ),
    ),
  );
}
