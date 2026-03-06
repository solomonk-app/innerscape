import 'package:just_audio/just_audio.dart';

enum AmbientSound { none, rain, ocean, forest }

class BreathworkAudioService {
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _chimePlayer = AudioPlayer();

  AmbientSound _currentSound = AmbientSound.rain;
  bool _isMuted = false;
  bool _isPlaying = false;

  AmbientSound get currentSound => _currentSound;
  bool get isMuted => _isMuted;

  Future<void> init() async {
    await _ambientPlayer.setLoopMode(LoopMode.one);
    await _ambientPlayer.setVolume(0.4);
    await _chimePlayer.setVolume(0.7);
  }

  Future<void> setAmbientSound(AmbientSound sound) async {
    _currentSound = sound;
    if (_isPlaying && sound != AmbientSound.none) {
      await _loadAndPlayAmbient();
    } else if (sound == AmbientSound.none && _isPlaying) {
      await _ambientPlayer.stop();
    }
  }

  Future<void> start() async {
    _isPlaying = true;
    if (_currentSound != AmbientSound.none && !_isMuted) {
      await _loadAndPlayAmbient();
    }
  }

  Future<void> stop() async {
    _isPlaying = false;
    await _ambientPlayer.stop();
  }

  Future<void> playChime() async {
    if (_isMuted) return;
    try {
      await _chimePlayer.setAsset('assets/audio/chime.mp3');
      await _chimePlayer.seek(Duration.zero);
      _chimePlayer.play();
    } catch (_) {}
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted) {
      _ambientPlayer.setVolume(0);
      _chimePlayer.setVolume(0);
    } else {
      _ambientPlayer.setVolume(0.4);
      _chimePlayer.setVolume(0.7);
    }
  }

  Future<void> _loadAndPlayAmbient() async {
    final asset = _assetPath(_currentSound);
    if (asset == null) return;
    try {
      await _ambientPlayer.setAsset(asset);
      _ambientPlayer.play();
    } catch (_) {}
  }

  String? _assetPath(AmbientSound sound) {
    switch (sound) {
      case AmbientSound.rain:
        return 'assets/audio/rain.mp3';
      case AmbientSound.ocean:
        return 'assets/audio/ocean.mp3';
      case AmbientSound.forest:
        return 'assets/audio/forest.mp3';
      case AmbientSound.none:
        return null;
    }
  }

  Future<void> dispose() async {
    await _ambientPlayer.dispose();
    await _chimePlayer.dispose();
  }
}
