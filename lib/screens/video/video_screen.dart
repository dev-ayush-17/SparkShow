import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../models/product.dart';
import '../../services/video_service.dart';
import '../../utils/constants.dart';

class VideoScreen extends StatefulWidget {
  final Product product;

  const VideoScreen({super.key, required this.product});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoService _videoService;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _videoService = VideoService();
    _videoService.addListener(_onVideoStateChanged);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    await _videoService.initialize(widget.product.video);
  }

  void _onVideoStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _videoService.removeListener(_onVideoStateChanged);
    _videoService.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildVideoPlayer(),
            ),
            if (_videoService.isInitialized) _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.product.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoService.isError) {
      return _buildErrorState();
    }

    if (!_videoService.isInitialized) {
      return _buildLoadingState();
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoService.controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_videoService.controller!),
              if (_showControls) _buildOverlayControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayControls() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black54,
            Colors.transparent,
            Colors.transparent,
            Colors.black54,
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.replay,
              onPressed: () => _videoService.replay(),
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: _videoService.isPlaying
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              size: 64,
              onPressed: () => _videoService.togglePlayPause(),
            ),
            const SizedBox(width: 24),
            _buildControlButton(
              icon: Icons.fullscreen,
              onPressed: _enterFullscreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 40,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: size),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          _buildProgressBar(),
          const SizedBox(height: AppConstants.smallPadding),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: [
        Text(
          _formatDuration(_videoService.position),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: AppColors.primary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
            ),
            child: Slider(
              value: _videoService.duration.inMilliseconds > 0
                  ? _videoService.position.inMilliseconds /
                      _videoService.duration.inMilliseconds
                  : 0.0,
              onChanged: (value) {
                final position = Duration(
                  milliseconds: (value * _videoService.duration.inMilliseconds)
                      .round(),
                );
                _videoService.seekTo(position);
              },
            ),
          ),
        ),
        Text(
          _formatDuration(_videoService.duration),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildBottomControlButton(
          icon: Icons.replay,
          label: 'Replay',
          onPressed: () => _videoService.replay(),
        ),
        _buildBottomControlButton(
          icon: _videoService.isPlaying
              ? Icons.pause_circle_filled
              : Icons.play_circle_filled,
          label: _videoService.isPlaying ? 'Pause' : 'Play',
          size: 48,
          onPressed: () => _videoService.togglePlayPause(),
        ),
        _buildBottomControlButton(
          icon: Icons.fullscreen,
          label: 'Fullscreen',
          onPressed: _enterFullscreen,
        ),
      ],
    );
  }

  Widget _buildBottomControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double size = 32,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.white, size: size),
          onPressed: onPressed,
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppConstants.defaultPadding),
          Text(
            'Loading video...',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 64,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            'Unable to load video',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.smallPadding),
          Text(
            'Video file may be missing or corrupted',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.largePadding),
          ElevatedButton(
            onPressed: _initializeVideo,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
