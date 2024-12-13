import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gb_media/app/app_preferences.dart';
import 'package:gb_media/data/api_client.dart';
import 'package:gb_media/data/repositories/ads_repository.dart';
import 'package:gb_media/data/repositories/auth_repository.dart';
import 'package:gb_media/manager/connectivity.dart';
import 'package:gb_media/model/ads.dart';
import 'package:gb_media/model/login_request.dart';
import 'package:gb_media/routes/routes.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/service_locator.dart';
import '../providers/ads.dart';
import 'dart:io';
import 'dart:convert';

final getIt = GetIt.instance;

class ConnectivityPage extends StatefulWidget {
  const ConnectivityPage({super.key});
  @override
  _ConnectivityPageState createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  static const platform = MethodChannel('gb_channel');
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  String connectionStatus = 'Not connected';
  String macAddress = 'Unknown'; // Variable to hold MAC address
  AppPreferences appPreferences = getIt<AppPreferences>();
  // Add focus nodes for each button
  late List<FocusNode> _focusNodes;
  int _currentFocusIndex = 0;


  @override
  void initState() {
    super.initState();
    // Initialize focus nodes
    _focusNodes = List.generate(4, (index) => FocusNode());
    login();
    // getAndroidId();
    // checkWifiConnection();

    // Request focus for the first button
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _moveFocus(1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _moveFocus(-1);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _moveFocus(2);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _moveFocus(-2);
      } else if (event.logicalKey == LogicalKeyboardKey.select ||
          event.logicalKey == LogicalKeyboardKey.enter) {
        _activateCurrentButton();
      }
    }
  }

  void _moveFocus(int delta) {
    setState(() {
      _currentFocusIndex = (_currentFocusIndex + delta).clamp(0, 3);
      _focusNodes[_currentFocusIndex].requestFocus();
    });
  }

  void _activateCurrentButton() {
    final buttons = [
      openWifiSettings,
      openDeveloperSetting,
      clearCache,
      startGlassbox,
    ];
    buttons[_currentFocusIndex]();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isWideScreen = screenSize.width > 1200; // Threshold for wide screens

    final List<Map<String, dynamic>> buttons = [
      {
        'text': 'Connect To Wifi',
        'onPressed': openWifiSettings,
        'icon': Icons.wifi,
        'color': Colors.blue,
      },
      {
        'text': 'System Setting',
        'onPressed': openDeveloperSetting,
        'icon': Icons.settings,
        'color': Colors.orange,
      },
      {
        'text': 'Clear Cache',
        'onPressed': clearCache,
        'icon': Icons.cleaning_services,
        'color': Colors.red,
      },
      {
        'text': 'Start Glassbox',
        'onPressed': startGlassbox,
        'icon': Icons.play_circle,
        'color': Colors.green,
      },
    ];

    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKeyEvent,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade900, Colors.blue.shade700],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.width * 0.05,
                vertical: screenSize.height * 0.05,
              ),
              child: Row(
                children: [
                  // Left side - Connection Status
                  Expanded(
                    flex: isWideScreen ? 2 : 1,
                    child: Center(
                      child: FutureBuilder<bool>(
                        future: GbConnectivity().isNetworkConnected(),
                        builder: (context, snapshot) {
                          final bool hasConnection = snapshot.data ?? false;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                hasConnection
                                    ? Icons.wifi
                                    : Icons.wifi_off_rounded,
                                size: isWideScreen ? 120 : 80,
                                color: Colors.white,
                              ),
                              SizedBox(height: isWideScreen ? 32 : 24),
                              Text(
                                hasConnection ? 'Connected' : 'No Connection',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isWideScreen ? 48 : 32,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // Right side - Buttons Grid
                  Expanded(
                    flex: isWideScreen ? 3 : 2,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.width * 0.05,
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: isWideScreen ? 32 : 16,
                          mainAxisSpacing: isWideScreen ? 32 : 16,
                          childAspectRatio: isWideScreen ? 2 : 1.8,
                        ),
                        itemCount: buttons.length,
                        itemBuilder: (context, index) {
                          return Focus(
                            focusNode: _focusNodes[index],
                            child: Builder(
                              builder: (BuildContext context) {
                                final isFocused = Focus.of(context).hasFocus;
                                return Card(
                                  elevation: isFocused ? 8 : 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          buttons[index]['color'],
                                          buttons[index]['color']
                                              .withOpacity(0.8),
                                        ],
                                      ),
                                      border: isFocused
                                          ? Border.all(
                                              color: Colors.white, width: 3)
                                          : null,
                                    ),
                                    child: InkWell(
                                      onTap: buttons[index]['onPressed'],
                                      borderRadius: BorderRadius.circular(16),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            buttons[index]['icon'],
                                            size: isWideScreen ? 48 : 36,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                              height: isWideScreen ? 16 : 8),
                                          Text(
                                            buttons[index]['text'],
                                            style: TextStyle(
                                              fontSize: isWideScreen
                                                  ? (isFocused ? 24 : 20)
                                                  : (isFocused ? 18 : 16),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    if (await GbConnectivity().hasNetwork()) {
      try {
        final deviceId = await platform.invokeMethod('getAndroidId');
        final loginRequest = LoginRequest(
          deviceId: deviceId,
          deviceName: 'Android Device',
          operatingSystem: 'Android',
        );

        final response = await getIt<AuthRepository>()
            .login(loginRequest, appPreferences.retrieveAccessToken());
        print('response.accessToken ${response.accessToken}');
        // Store tokens in preferences
        final prefs = getIt<AppPreferences>();
        prefs.insertAccessToken(response.accessToken);
        prefs.insertRefreshToken(response.refreshToken);

        if (mounted) {
          Navigator.of(context).pushReplacementNamed(Routes.startAds);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $e')),
          );
        }
      }
    } else {
      print('NOT CONNECTED');
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text('Please connect to WiFi first')),
      //   );
      // }
      await startGlassbox();
    }
  }

  Future<void> openWifiSettings() async {
    try {
      await platform.invokeMethod('openWifiSettings');
    } on PlatformException catch (e) {
      print("Failed to open Wi-Fi settings: '${e.message}'.");
    }
  }

  Future<void> connectToWifi() async {
    await openWifiSettings(); // This will open the Wi-Fi settings page
  }

  Future<void> getAndroidId() async {
    try {
      final String result = await platform.invokeMethod('getAndroidId');
      setState(() {
        macAddress = result; // Set the retrieved Android ID
      });
    } on PlatformException catch (e) {
      print("Failed to get Android ID: '${e.message}'.");
    }
  }

  Future<void> checkWifiConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isConnected = await GbConnectivity().isNetworkConnected();

      setState(() {
        if ((connectivityResult == ConnectivityResult.wifi ||
                connectivityResult == ConnectivityResult.ethernet) &&
            isConnected) {
          connectionStatus = 'Connected to Wi-Fi';
        } else if ((connectivityResult == ConnectivityResult.wifi ||
                connectivityResult == ConnectivityResult.ethernet) &&
            !isConnected) {
          connectionStatus = 'Wi-Fi enabled but not connected';
        } else {
          connectionStatus = 'Not connected to Wi-Fi';
        }
      });

      // Set up a stream to listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
        checkWifiConnection(); // Recheck connection when status changes
      });
    } catch (e) {
      print('Error checking connectivity: $e');
      setState(() {
        connectionStatus = 'Error checking connection';
      });
    }
  }

  Future<void> openDeveloperSetting() async {
    try {
      await platform.invokeMethod('openDeveloperOptions');
    } on PlatformException catch (e) {
      print("Failed to open developer options: '${e.message}'.");
    }
  }

  Future<void> startGlassbox() async {
    try {
      // Load cached URLs first
      // final cachedUrls = await _loadCachedUrls();
      final isCacheExist = appPreferences.getCachedAds() != null? true:false;
      debugPrint('Cached URLs found: ${appPreferences.getCachedAds()}');

      if (appPreferences.getCachedAds() != null && appPreferences.getCachedAds() == '[]') {
        debugPrint('Using cached content');
        if (mounted) {
          Navigator.of(context).pushNamed(Routes.startAds);
        }
        return;
      }

      // If no cache, check connection
      final isConnected = await GbConnectivity().hasNetwork();
      if (!isConnected) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'No internet connection and no cached content available'),
            ),
          );
        }
        return;
      }

      // Get token from cache

      final token = appPreferences.retrieveAccessToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('No token available, please register device first')),
          );
        }
        return;
      }

      // If connected and have token, get new content from repository
      final adsRepository = getIt<AdsRepository>();
      final newAds = await adsRepository.getAds(token);
      context
          .read<AdsProvider>()
          .updateAds(newAds);
      if (newAds.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No ads content available')),
          );
        }
        return;
      }

      // Extract URLs from ads and save them
      // final newUrls = newAds.map((ad) => ad.content).toList();
      // await _saveCachedUrls(newAds);

      if (mounted) {
        Navigator.of(context).pushNamed(Routes.startAds);
      }
    } catch (e) {
      debugPrint('Error starting Glassbox: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Future<List<String>> _loadCachedUrls() async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final cachedAdsString = prefs.getBool(_cachedUrlsKey);
  //     debugPrint('Raw cached ads string: $cachedAdsString');
  //
  //     if (cachedAdsString != null && cachedAdsString.isNotEmpty) {
  //
  //       final List<dynamic> adsList = jsonDecode(cachedAdsString);
  //       final ads = adsList.map((adMap) => AdsModel.fromMap(adMap as Map<String, dynamic>)).toList();
  //
  //
  //       // Extract content URLs from maps
  //       List<String> urls = ads
  //           .map((ad) => ad.content as String)
  //           .where((url) => url != null && url.isNotEmpty)
  //           .toList();
  //
  //       debugPrint('Extracted URLs: $urls');
  //       return urls;
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading cached ads: $e');
  //   }
  //   return [];
  // }


  // Modify the clear cache function to be more specific
  Future<void> clearCache() async {
    try {
      // Clear application documents directory
      final directory = await getApplicationDocumentsDirectory();
      if (await directory.exists()) {
        final files = directory.listSync();
        for (var file in files) {
          if (file is File) {
            await file.delete();
          }
        }
      }

      // Clear shared preferences except for essential data
      appPreferences.clearCache();

      // Reset providers
      final adsProvider = getIt<AdsProvider>();
      adsProvider.updateAds([]);

      // Show success message
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      print('Error clearing cache: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to clear cache')),
        );
      }
    }
  }
}
