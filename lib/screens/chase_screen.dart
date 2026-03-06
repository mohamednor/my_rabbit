import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/game/chase_game.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';

class ChaseScreen extends StatefulWidget {
  final int level;

  const ChaseScreen({super.key, required this.level});

  @override
  State<ChaseScreen> createState() => _ChaseScreenState();
}

class _ChaseScreenState extends State<ChaseScreen> {
  ChaseGame? _game;
  int _score = 0;
  int _carrots = 0;
  double _timeRemaining = 90;
  int _lives = 3;
  bool _showPauseMenu = false;
  bool _showLevelComplete = false;
  bool _levelWon = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final audioService = context.read<AudioService>();
    _game = ChaseGame(
      level: widget.level,
      audioService: audioService,
      onLevelComplete: _onLevelComplete,
      onLevelFailed: _onLevelFailed,
      onScoreUpdate: (score, carrots) {
        if (mounted) setState(() { _score = score; _carrots = carrots; });
      },
    );
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _updateHud();
    });
  }

  void _updateHud() {
    if (!mounted || _game == null) return;
    
    setState(() {
      _timeRemaining = _game!.timeRemaining;
      _lives = _game!.lives;
    });
    
    if (_game!.isPlaying && !_showLevelComplete) {
      Future.delayed(const Duration(milliseconds: 100), _updateHud);
    }
  }

  void _onLevelComplete() {
    if (mounted) {
      setState(() { _showLevelComplete = true; _levelWon = true; });
    }
    
    final gameState = context.read<GameStateService>();
    gameState.completeLevel(widget.level, 3, _score);
    gameState.addCoins(_score * 2);
  }

  void _onLevelFailed() {
    if (mounted) {
      setState(() { _showLevelComplete = true; _levelWon = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioService = context.read<AudioService>();

    return Scaffold(
      body: Stack(
        children: [
          if (_game != null) GameWidget(game: _game!),
          
          // HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 45, 12, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      audioService.playClick();
                      _game?.pause();
                      setState(() => _showPauseMenu = true);
                    },
                    child: Container(
                      width: 45, height: 45,
                      decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Text('⏸️', style: TextStyle(fontSize: 22))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('🥕 $_carrots', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('⏱️ ${_timeRemaining.toInt()}s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _timeRemaining <= 15 ? Colors.red : Colors.black)),
                          Text('💰 $_score', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
                    child: Row(children: List.generate(3, (i) => Text(i < _lives ? '❤️' : '🖤', style: const TextStyle(fontSize: 16)))),
                  ),
                ],
              ),
            ),
          ),
          
          // Instructions
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)),
                child: const Text('👆 Tap lane or Swipe ↑↓ to move', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
          
          if (_showPauseMenu) _buildPauseMenu(audioService),
          if (_showLevelComplete) _buildLevelCompleteMenu(audioService),
        ],
      ),
    );
  }

  Widget _buildPauseMenu(AudioService audioService) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32), padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏸️ Paused', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple)),
              const SizedBox(height: 24),
              _buildMenuButton('▶️ Resume', Colors.green, () {
                audioService.playClick();
                _game?.resume();
                setState(() => _showPauseMenu = false);
              }),
              const SizedBox(height: 12),
              _buildMenuButton('🔄 Restart', Colors.orange, () {
                audioService.playClick();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChaseScreen(level: widget.level)));
              }),
              const SizedBox(height: 12),
              _buildMenuButton('🚪 Exit', Colors.pink, () {
                audioService.playClick();
                Navigator.of(context).popUntil((route) => route.isFirst);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCompleteMenu(AudioService audioService) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32), padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _levelWon ? '🎉 Mouse Caught!' : '😢 Mouse Escaped!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _levelWon ? Colors.purple : Colors.grey),
              ),
              const SizedBox(height: 16),
              if (_levelWon) const Text('🐭 ➡️ 🐰', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 16),
              Text('🥕 Carrots: $_carrots', style: const TextStyle(fontSize: 18)),
              Text('💰 Score: $_score', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_levelWon && widget.level < 60) _buildSmallButton('Next ➡️', Colors.purple, () {
                    audioService.playClick();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChaseScreen(level: widget.level + 1)));
                  }),
                  const SizedBox(width: 12),
                  _buildSmallButton('🔄', Colors.orange, () {
                    audioService.playClick();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ChaseScreen(level: widget.level)));
                  }),
                  const SizedBox(width: 12),
                  _buildSmallButton('🗺️', Colors.pink, () {
                    audioService.playClick();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))),
      ),
    );
  }

  Widget _buildSmallButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
