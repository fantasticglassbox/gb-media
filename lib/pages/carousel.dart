import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:better_player/better_player.dart';
import '../model/ads.dart';

class Carousel extends StatefulWidget {
  final List<AdsModel> ads;

  const Carousel({Key? key, required this.ads}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int currentIndex = 0;
  BetterPlayerController? _betterPlayerController;
  Timer? _mediaTimer;
  Widget? _currentMediaWidget;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _playCurrentMedia();

    // App lifecycle handling
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.paused.toString()) {
        _cleanUpResources();
      }
      return null;
    });
  }

  @override
  void didUpdateWidget(Carousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ads != widget.ads) {
      currentIndex = 0;
      _playCurrentMedia();
    }
  }

  @override
  void dispose() {
    _cleanUpResources();
    super.dispose();
  }

  void _cleanUpResources() {
    _mediaTimer?.cancel();

    if (_betterPlayerController != null) {
      _betterPlayerController!.dispose();
      _betterPlayerController = null;
    }
  }

  void _playCurrentMedia() {
    if (widget.ads.isEmpty) {
      debugPrint('Ads list is empty, nothing to play.');
      return;
    }

    final currentAd = widget.ads[currentIndex];
    debugPrint('Playing media at index $currentIndex: ${currentAd.type}');
    debugPrint('currentAd.cachedFilePath ${currentAd.cachedFilePath}');
    // Check if the media is a video or an image
    if (currentAd.type == 'VIDEO') {
      final videoPath = currentAd.cachedFilePath != null &&
          File(currentAd.cachedFilePath!).existsSync()
          ? currentAd.cachedFilePath!
          : currentAd.content;

      if (videoPath.isNotEmpty) {
        _playVideo(videoPath);
      } else {
        debugPrint('Invalid video path, skipping to the next media.');
        _nextMedia();
      }
    } else {
      _showImage(currentAd);
    }
  }

  void _playVideo(String videoPath) {
    _cleanUpResources();

    // Check if the videoPath is a local file or a URL
    final isLocalFile = videoPath.startsWith('/') || videoPath.contains('file://');

    if (isLocalFile && !File(videoPath).existsSync()) {
      debugPrint('Local video file not found: $videoPath');
      _nextMedia();
      return;
    }

    // Create BetterPlayerController and initialize it
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: true,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: false,
        ),
        errorBuilder: (context, error) {
          debugPrint('Error loading video: $error');
          return Center(child: Text("Error loading video"));
        },
      ),
    );

    final videoSource = BetterPlayerDataSource(
      isLocalFile
          ? BetterPlayerDataSourceType.file
          : BetterPlayerDataSourceType.network,
      videoPath,
    );

    _betterPlayerController!.setupDataSource(videoSource).then((_) {
      setState(() {
        isLoading = false; // Set loading to false once video is ready
      });
    }).catchError((error) {
      debugPrint('Error initializing video: $error');
      _nextMedia();
    });

    setState(() {
      _currentMediaWidget = BetterPlayer(controller: _betterPlayerController!);
    });
  }


  void _showImage(AdsModel currentAd) {
    _cleanUpResources();

    setState(() {
      _currentMediaWidget = Center(
        child: (currentAd.cachedFilePath != null
            ? Image.file(
          File(currentAd.cachedFilePath!),
          fit: BoxFit.contain, // Change fit to control how the image fits
          width: MediaQuery.of(context)
              .size
              .width, // Ensure the image takes up the full width
          height: MediaQuery.of(context)
              .size
              .height, // Ensure the image takes up the full height
        )
            : Image.network(
          currentAd.content,
          fit: BoxFit.contain, // Change fit to control how the image fits
          width: MediaQuery.of(context)
              .size
              .width, // Ensure the image takes up the full width
          height: MediaQuery.of(context)
              .size
              .height, // Ensure the image takes up the full height
        )),
      );
    });

    _mediaTimer = Timer(Duration(seconds: currentAd.duration), _nextMedia);
  }

  void _nextMedia() {
    _cleanUpResources();

    setState(() {
      currentIndex = (currentIndex + 1) % widget.ads.length;
      _playCurrentMedia();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : _currentMediaWidget ?? Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
