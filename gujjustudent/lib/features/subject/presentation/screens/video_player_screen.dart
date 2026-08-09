import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/screen_protector.dart';
import '../providers/video_stream_providers.dart';

class VideoPlayerScreen extends ConsumerStatefulWidget {
  final int videoId;
  final String videoName;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.videoName,
  });

  @override
  ConsumerState<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends ConsumerState<VideoPlayerScreen> {
  BetterPlayerController? _betterPlayerController;

  // Watermark positioning
  double _watermarkTop = 50;
  double _watermarkLeft = 50;
  Timer? _watermarkTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _secureScreen();
    _startWatermarkMovement();
  }

  Future<void> _secureScreen() async {
    await ScreenProtector.protect();
  }

  void _startWatermarkMovement() {
    _watermarkTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (!mounted) return;
      setState(() {
        // Keeps watermark within safe bounds roughly
        _watermarkTop = _random.nextDouble() * (MediaQuery.of(context).size.height - 100);
        _watermarkLeft = _random.nextDouble() * (MediaQuery.of(context).size.width - 200);
      });
    });
  }

  void _setupPlayer(String url, String watermarkText) {
    if (_betterPlayerController != null) return; // Already setup

    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      videoFormat: BetterPlayerVideoFormat.hls,
    );

    BetterPlayerConfiguration configuration = const BetterPlayerConfiguration(
      autoPlay: true,
      looping: false,
      fullScreenByDefault: false,
      aspectRatio: 16 / 9,
      fit: BoxFit.contain,
      controlsConfiguration: BetterPlayerControlsConfiguration(
        enableSkips: true,
        enableFullscreen: true,
        enableMute: true,
        enablePlayPause: true,
        enableProgressBar: true,
        enablePlaybackSpeed: true,
        textColor: Colors.white,
        iconsColor: Colors.white,
      ),
    );

    _betterPlayerController = BetterPlayerController(configuration, betterPlayerDataSource: dataSource);
  }

  @override
  void dispose() {
    _watermarkTimer?.cancel();
    _betterPlayerController?.dispose();
    ScreenProtector.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final streamAsyncValue = ref.watch(videoStreamUrlProvider(widget.videoId));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.videoName,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: streamAsyncValue.when(
        data: (data) {
          final streamUrl = data['stream_url'];
          final watermarkText = data['watermark_text'] ?? 'EduStream User';

          if (!kIsWeb) {
            _setupPlayer(streamUrl, watermarkText);
          }

          return Stack(
            children: [
              Center(
                child: kIsWeb 
                  ? Container(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.computer, color: Colors.white24, size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            "Secure HLS Streaming",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "This premium video is protected. For the best experience and full security, please use our Mobile App.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  : _betterPlayerController != null 
                      ? AspectRatio(
                          aspectRatio: 16 / 9,
                          child: BetterPlayer(
                            controller: _betterPlayerController!,
                          ),
                        )
                      : const CircularProgressIndicator(),
              ),
              // Moving Watermark Overlay
              AnimatedPositioned(
                duration: const Duration(seconds: 2),
                curve: Curves.easeInOut,
                top: _watermarkTop,
                left: _watermarkLeft,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.3, // Semi-transparent
                    child: Text(
                      watermarkText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                'Video not available.\n${error.toString().replaceAll('Exception: ', '')}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(videoStreamUrlProvider(widget.videoId)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
