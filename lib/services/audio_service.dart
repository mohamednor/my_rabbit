import 'package:flame_audio/flame_audio.dart';

class AudioService {
  bool _initialized = false;
  bool _musicEnabled = true;
  bool _sfxEnabled = true;
  
  bool get musicEnabled => _musicEnabled;
  bool get sfxEnabled => _sfxEnabled;
  
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
  }
  
  void toggleMusic() {
    _musicEnabled = !_musicEnabled;
    if (!_musicEnabled) {
      FlameAudio.bgm.stop();
    }
  }
  
  void toggleSfx() {
    _sfxEnabled = !_sfxEnabled;
  }
  
  void playClick() {}
  void playCollect() {}
  void playJump() {}
  void playHurt() {}
  void playLevelUp() {}
  void playVictory() {}
}
