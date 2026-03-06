import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _clickPlayer = AudioPlayer();
  final AudioPlayer _collectPlayer = AudioPlayer();
  final AudioPlayer _jumpPlayer = AudioPlayer();
  final AudioPlayer _hurtPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();
  final AudioPlayer _losePlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  Future<void> initialize() async {
    await _clickPlayer.setSource(AssetSource('audio/click.wav'));
    await _collectPlayer.setSource(AssetSource('audio/collect.wav'));
    await _jumpPlayer.setSource(AssetSource('audio/jump.wav'));
    await _hurtPlayer.setSource(AssetSource('audio/hurt.wav'));
    await _winPlayer.setSource(AssetSource('audio/win.wav'));
    await _losePlayer.setSource(AssetSource('audio/lose.wav'));
    
    // Set volume
    _clickPlayer.setVolume(0.5);
    _collectPlayer.setVolume(0.6);
    _jumpPlayer.setVolume(0.5);
    _hurtPlayer.setVolume(0.7);
    _winPlayer.setVolume(0.8);
    _losePlayer.setVolume(0.7);
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  void playClick() {
    if (_soundEnabled) {
      _clickPlayer.stop();
      _clickPlayer.resume();
    }
  }

  void playCollect() {
    if (_soundEnabled) {
      _collectPlayer.stop();
      _collectPlayer.resume();
    }
  }

  void playJump() {
    if (_soundEnabled) {
      _jumpPlayer.stop();
      _jumpPlayer.resume();
    }
  }

  void playHurt() {
    if (_soundEnabled) {
      _hurtPlayer.stop();
      _hurtPlayer.resume();
    }
  }

  void playWin() {
    if (_soundEnabled) {
      _winPlayer.stop();
      _winPlayer.resume();
    }
  }

  void playLose() {
    if (_soundEnabled) {
      _losePlayer.stop();
      _losePlayer.resume();
    }
  }

  void dispose() {
    _clickPlayer.dispose();
    _collectPlayer.dispose();
    _jumpPlayer.dispose();
    _hurtPlayer.dispose();
    _winPlayer.dispose();
    _losePlayer.dispose();
  }
}
