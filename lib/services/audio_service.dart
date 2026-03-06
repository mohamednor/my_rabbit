import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  Future<void> initialize() async {
    // Pre-warm the audio players
    await _playSound('audio/click.wav', volume: 0.01);
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  Future<void> _playSound(String path, {double volume = 0.5}) async {
    if (!_soundEnabled) return;
    try {
      final player = AudioPlayer();
      await player.setVolume(volume);
      await player.play(AssetSource(path));
      player.onPlayerComplete.listen((_) {
        player.dispose();
      });
    } catch (e) {
      // Ignore audio errors
    }
  }

  void playClick() => _playSound('audio/click.wav', volume: 0.5);
  void playCollect() => _playSound('audio/collect.wav', volume: 0.7);
  void playJump() => _playSound('audio/jump.wav', volume: 0.5);
  void playHurt() => _playSound('audio/hurt.wav', volume: 0.8);
  void playWin() => _playSound('audio/win.wav', volume: 0.9);
  void playLose() => _playSound('audio/lose.wav', volume: 0.8);

  void dispose() {}
}
