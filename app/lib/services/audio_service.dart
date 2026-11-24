import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  /// Play audio from assets
  Future<void> playAsset(String assetPath) async {
    try {
      await _player.stop();
      _isPlaying = true;
      await _player.play(AssetSource(assetPath));
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      print('Audio playback error: $e');
    }
  }

  /// Stop current playback
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Pause current playback
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  void dispose() {
    _player.dispose();
  }
}