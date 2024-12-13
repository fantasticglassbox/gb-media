import 'package:gb_media/app/app_preferences.dart';
import 'package:gb_media/data/api_client.dart';
import 'package:gb_media/data/repositories/ads_repository.dart';
import 'package:gb_media/data/repositories/auth_repository.dart';
import 'package:gb_media/env/environment_variables.dart';
import 'package:gb_media/manager/connectivity.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../manager/custom_cache_manager.dart';
import '../providers/ads.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator(EnvironmentVariables env) async {
  // External Dependencies
  getIt.registerLazySingleton<http.Client>(() => http.Client());
  getIt.registerLazySingleton<AdsProvider>(() => AdsProvider());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // App Level Services
  getIt.registerLazySingleton<AppPreferences>(() => AppPreferences(getIt()));
  getIt.registerLazySingleton<CustomCacheManager>(() => CustomCacheManager(
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 100,
      ));
  getIt.registerLazySingleton<GbConnectivity>(() => GbConnectivity());
  getIt.registerLazySingleton<ApiClient>(
      () => ApiClient(baseUrl: env.baseUrl, client: getIt()));

  // Repositories
  getIt.registerLazySingleton<AdsRepository>(() => AdsRepository(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt()));
}
