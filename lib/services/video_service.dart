import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoService extends ChangeNotifier {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _isError = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  VideoPlayerController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _isPlaying;
  bool get isError => _isError;
  Duration get duration => _duration;
  Duration get position => _position;

  Future<void> initialize(String videoPath) async {
    _isError = false;
    _isInitialized = false;
    notifyListeners();

    try {
      _controller = VideoPlayerController.asset(videoPath);

      await _controller!.initialize();

      _duration = _controller!.value.duration;

      _controller!.addListener(_onVideoProgress);

      _isInitialized = true;
      notifyListeners();

      await play();
    } catch (e) {
      _isError = true;
      _isInitialized = false;
      notifyListeners();
    }
  }

  void _onVideoProgress() {
    if (_controller == null) return;

    final newValue = _controller!.value;
    final isPlaying = newValue.isPlaying;
    final position = newValue.position;

    if (_isPlaying != isPlaying || _position != position) {
      _isPlaying = isPlaying;
      _position = position;
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (_controller == null || !_isInitialized) return;

    try {
      await _controller!.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      _isError = true;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_controller == null || !_isInitialized) return;

    try {
      await _controller!.pause();
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _isError = true;
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null || !_isInitialized) return;

    try {
      await _controller!.seekTo(position);
      _position = position;
      notifyListeners();
    } catch (e) {
      _isError = true;
      notifyListeners();
    }
  }

  Future<void> replay() async {
    if (_controller == null || !_isInitialized) return;

    try {
      await _controller!.seekTo(Duration.zero);
      await play();
    } catch (e) {
      _isError = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
}
