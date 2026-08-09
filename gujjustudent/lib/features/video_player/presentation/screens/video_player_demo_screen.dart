import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:edustream/core/constants/app_colors.dart';

class VideoPlayerDemoScreen extends StatefulWidget {
  const VideoPlayerDemoScreen({super.key});

  @override
  State<VideoPlayerDemoScreen> createState() => _VideoPlayerDemoScreenState();
}

class _VideoPlayerDemoScreenState extends State<VideoPlayerDemoScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  VideoPlayerController? _controller;
  bool _isFullScreen = false;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeVideo();
  }

  void _initializeVideo() {
    // Local asset video
    _controller = VideoPlayerController.asset(
      'assets/videos/demo_video.mp4',
    )..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
            _hasError = false;
          });
          _controller?.play();
          _controller?.setLooping(true);
        }
      }).catchError((error) {
        if (mounted) {
          setState(() {
            _hasError = true;
          });
          debugPrint('Video player error: $error');
        }
      });

    _controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller?.dispose();
    // Reset orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (_isFullScreen) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _toggleFullScreen();
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: OrientationBuilder(
            builder: (context, orientation) {
              final bool shouldRotate = orientation == Orientation.portrait;
              Widget content = _buildVideoContent(isFullScreen: true);
              if (shouldRotate) {
                content = RotatedBox(quarterTurns: 1, child: content);
              }

              return Stack(
                children: [
                  Positioned.fill(child: content),
                  Positioned(
                    top: shouldRotate ? 20 : 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: _toggleFullScreen,
                      child: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              floating: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Video Lesson', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            SliverToBoxAdapter(
              child: _buildVideoPlayerArea(),
            ),
            SliverToBoxAdapter(
              child: _buildLessonHeader(),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Divider(color: AppColors.lightGrey, height: 1),
                      _buildTabsSection(),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLessonsTab(),
            _buildDoubtsTab(),
            _buildResourcesTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildContinueSection(),
    );
  }

  Widget _buildVideoPlayerArea() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          _buildVideoContent(isFullScreen: false),
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleFullScreen,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
                child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent({required bool isFullScreen}) {
    if (_hasError) {
      return Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 40),
            const SizedBox(height: 12),
            const Text('Error loading video', style: TextStyle(color: Colors.white)),
            TextButton(onPressed: _initializeVideo, child: const Text('Retry', style: TextStyle(color: AppColors.primary))),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
            });
          },
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: AnimatedOpacity(
                opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  width: isFullScreen ? 80 : 50,
                  height: isFullScreen ? 80 : 50,
                  decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: Icon(_controller!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: isFullScreen ? 50 : 36),
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Transform.rotate(
              angle: -0.5,
              child: Text(
                'Shah-Kalp-5871 | ID: EDU-2024-X',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.1), fontSize: isFullScreen ? 32 : 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black54, Colors.transparent])),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                  colors: VideoProgressColors(playedColor: AppColors.primary, bufferedColor: Colors.white24, backgroundColor: Colors.white10),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Introduction to Quantum Computing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
          const SizedBox(height: 4),
          const Text('Chapter 1: Foundations of Future Tech', style: TextStyle(fontSize: 14, color: AppColors.darkGrey)),
        ],
      ),
    );
  }

  Widget _buildTabsSection() {
    return TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.darkGrey,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      tabs: const [Tab(text: 'Lessons'), Tab(text: 'Doubts'), Tab(text: 'Resources')],
    );
  }

  Widget _buildLessonsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        bool isPlaying = index == 1;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isPlaying ? AppColors.primary.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)],
          ),
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: Container(width: 50, height: 35, color: AppColors.lightGrey, child: const Icon(Icons.play_arrow, size: 18, color: AppColors.primary))),
            title: Text('Lesson ${index + 1}: Topic Name', style: TextStyle(fontSize: 14, fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal)),
            subtitle: const Text('15:00', style: TextStyle(fontSize: 12)),
            trailing: isPlaying ? const Icon(Icons.graphic_eq, color: AppColors.primary, size: 18) : const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildDoubtsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Ask a doubt...',
            filled: true,
            fillColor: Colors.white,
            suffixIcon: const Icon(Icons.send, color: AppColors.primary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 20),
        _buildDoubtItem('User A', '2 min ago', 'Is this part important?'),
      ],
    );
  }

  Widget _buildDoubtItem(String user, String time, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(radius: 15, backgroundColor: AppColors.lightGrey, child: Icon(Icons.person, size: 15)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(text, style: const TextStyle(fontSize: 13)),
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourcesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
            title: Text('Resource ${index + 1}.pdf'),
            subtitle: const Text('2.5 MB'),
          ),
        );
      },
    );
  }

  Widget _buildContinueSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), minimumSize: const Size(double.infinity, 50)),
        child: const Text('Continue to Next Lesson', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 50;
  @override
  double get maxExtent => 50;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
