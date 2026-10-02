import 'dart:async';
import 'dart:ui';
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

class _VideoScreenState extends State<VideoScreen>
    with SingleTickerProviderStateMixin {
  late VideoService _videoService;
  bool _controlsVisible = true;
  Timer? _hideTimer;
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _videoService = VideoService();
    _videoService.addListener(_onVideoStateChanged);
    _initializeVideo();
    _scheduleHide();
  }

  Future<void> _initializeVideo() async {
    await _videoService.initialize(widget.product.video);
    if (mounted) _scheduleHide();
  }

  void _onVideoStateChanged() {
    if (!mounted) return;
    setState(() {});
    if (_videoService.isPlaying && _controlsVisible) _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _fadeCtrl.dispose();
    _videoService.removeListener(_onVideoStateChanged);
    _videoService.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_videoService.isPlaying) return;
    _hideTimer = Timer(const Duration(seconds: 2), _hideControls);
  }

  void _hideControls() {
    if (!mounted) return;
    setState(() => _controlsVisible = false);
    _fadeCtrl.reverse();
  }

  void _showControls() {
    if (!mounted) return;
    setState(() => _controlsVisible = true);
    _fadeCtrl.forward();
    _scheduleHide();
  }

  void _onTap() => _controlsVisible ? _hideControls() : _showControls();
  void _cancelHide() => _hideTimer?.cancel();

  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideo(),
            FadeTransition(
              opacity: _fadeCtrl,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: _buildControlsLayer(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo() {
    if (_videoService.isError) return _buildError();
    if (!_videoService.isInitialized) return _buildLoading();
    return Center(
      child: AspectRatio(
        aspectRatio: _videoService.controller!.value.aspectRatio,
        child: VideoPlayer(_videoService.controller!),
      ),
    );
  }

  Widget _buildControlsLayer() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.28, 0.72, 1.0],
          colors: [
            Color(0xBB000000),
            Colors.transparent,
            Colors.transparent,
            Color(0xBB000000),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Spacer(),
            if (_videoService.isInitialized) ...[
              _buildCenterBtn(),
              const SizedBox(height: 10),
              _buildBottomBar(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 19),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              widget.product.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildCenterBtn() {
    return Center(
      child: GestureDetector(
        onTap: () {
          _videoService.togglePlayPause();
          _scheduleHide();
        },
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Icon(
            _videoService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 38,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final progress = _videoService.duration.inMilliseconds > 0
        ? (_videoService.position.inMilliseconds /
                _videoService.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(_fmt(_videoService.position),
                  style: const TextStyle(color: Colors.white70, fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()])),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: AppColors.primary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 13),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (v) {
                      final pos = Duration(
                          milliseconds: (v * _videoService.duration.inMilliseconds).round());
                      _videoService.seekTo(pos);
                    },
                    onChangeStart: (_) => _cancelHide(),
                    onChangeEnd: (_) => _scheduleHide(),
                  ),
                ),
              ),
              Text(_fmt(_videoService.duration),
                  style: const TextStyle(color: Colors.white70, fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _iconBtn(Icons.replay_rounded, 'Replay', () {
                _videoService.replay();
                _scheduleHide();
              }),
              _iconBtn(
                _videoService.isPlaying ? Icons.pause_circle_rounded : Icons.play_circle_rounded,
                _videoService.isPlaying ? 'Pause' : 'Play',
                () { _videoService.togglePlayPause(); _scheduleHide(); },
                size: 42,
              ),
              _iconBtn(Icons.fullscreen_rounded, 'Fullscreen', _enterFullscreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String label, VoidCallback onTap, {double size = 26}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: size),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          SizedBox(height: 16),
          Text('Loading video…', style: TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 52),
            const SizedBox(height: 14),
            const Text('Unable to load video',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('File may be missing or corrupted',
                style: TextStyle(color: Colors.white54, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _initializeVideo,
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 18),
              label: const Text('Try Again', style: TextStyle(color: AppColors.primary)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
