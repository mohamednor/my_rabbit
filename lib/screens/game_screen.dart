import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/game/my_rabbit_game.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/ad_service.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';

class GameScreen extends StatefulWidget {
  final int level;
  final int bunnyLevel;

  const GameScreen({super.key, required this.level, required this.bunnyLevel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  MyRabbitGame? _game;
  int _score = 0;
  int _candies = 0;
  double _timeRemaining = 0;
  int _lives = 3;
  bool _showPauseMenu = false;
  bool _showLevelComplete = false;
  bool _levelWon = false;
  int _earnedStars = 0;
  AdRewardType? _activeBoost;
  double _boostTime = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    final audioService = context.read<AudioService>();
    _game = MyRabbitGame(
      level: widget.level,
      bunnyLevel: widget.bunnyLevel,
      audioService: audioService,
      onLevelComplete: _onLevelComplete,
      onLevelFailed: _onLevelFailed,
      onScoreUpdate: (score, candies) {
        if (mounted) setState(() { _score = score; _candies = candies; });
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
      _activeBoost = _game!.activeBoost;
      _boostTime = _game!.boostTimeRemaining;
    });
    
    if (_game!.isPlaying && !_showLevelComplete) {
      Future.delayed(const Duration(milliseconds: 100), _updateHud);
    }
  }

  void _onLevelComplete() {
    final candyGoal = GameConfig.candyGoal(widget.level);
    int stars = 1;
    if (_candies >= candyGoal * 1.5) stars = 2;
    if (_candies >= candyGoal * 2) stars = 3;
    
    if (mounted) {
      setState(() { _showLevelComplete = true; _levelWon = true; _earnedStars = stars; });
    }
    
    final gameState = context.read<GameStateService>();
    gameState.completeLevel(widget.level, stars, _score);
    gameState.addCoins(_score + (stars * 25));
    gameState.addCandies(_candies);
    if (_game!.bunnyLevel > widget.bunnyLevel) gameState.setBunnySize(_game!.bunnyLevel);
  }

  void _onLevelFailed() {
    if (mounted) {
      setState(() { _showLevelComplete = true; _levelWon = false; _earnedStars = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adService = context.read<AdService>();
    final audioService = context.read<AudioService>();
    final candyGoal = GameConfig.candyGoal(widget.level);

    return Scaffold(
      body: Stack(
        children: [
          if (_game != null) GameWidget(game: _game!),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          audioService.playClick();
                          _game?.pause();
                          setState(() => _showPauseMenu = true);
                        },
                        child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('⏸️', style: TextStyle(fontSize: 24)))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text('Level ${widget.level}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4))),
                                Text('⏱️ ${_timeRemaining.toInt()}s', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _timeRemaining <= 10 ? Colors.red : Colors.grey.shade700)),
                              ]),
                              const SizedBox(height: 6),
                              ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(value: (_candies / candyGoal).clamp(0.0, 1.0), backgroundColor: Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation(Color(0xFFFF69B4)), minHeight: 8)),
                              const SizedBox(height: 4),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('🍬 $_candies/$candyGoal', style: const TextStyle(fontSize: 12)), Text('💰 $_score', style: const TextStyle(fontSize: 12))]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(16)),
                        child: Row(children: List.generate(3, (i) => Text(i < _lives ? '❤️' : '🖤', style: const TextStyle(fontSize: 18)))),
                      ),
                    ],
                  ),
                  if (_activeBoost != null)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(20)),
                      child: Text('${_activeBoost!.displayName} ${_boostTime.toInt()}s', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                    ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 80, left: 0, right: 0,
            child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(20)), child: const Text('👆 Drag to move • Tap to jump', style: TextStyle(color: Colors.white, fontSize: 14)))),
          ),
          
          if (adService.isBannerLoaded && adService.bannerAd != null)
            Positioned(bottom: 0, left: 0, right: 0, child: SizedBox(height: 50, child: AdWidget(ad: adService.bannerAd!))),
          
          if (_showPauseMenu) _buildPauseMenu(adService, audioService),
          if (_showLevelComplete) _buildLevelCompleteMenu(audioService),
        ],
      ),
    );
  }

  Widget _buildPauseMenu(AdService adService, AudioService audioService) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32), padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⏸️ Paused', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4))),
              const SizedBox(height: 24),
              _buildMenuButton('▶️ Resume', Colors.green, () {
                audioService.playClick();
                _game?.resume();
                setState(() => _showPauseMenu = false);
              }),
              const SizedBox(height: 12),
              _buildMenuButton('🔄 Restart', Colors.orange, () {
                audioService.playClick();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, bunnyLevel: context.read<GameStateService>().bunnySize)));
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
              Text(_levelWon ? '🎉 Level Complete!' : '😢 Try Again!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _levelWon ? const Color(0xFFFF69B4) : Colors.grey)),
              const SizedBox(height: 16),
              if (_levelWon) Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Text(i < _earnedStars ? '⭐' : '☆', style: TextStyle(fontSize: 36, color: i < _earnedStars ? Colors.amber : Colors.grey.shade300)))),
              const SizedBox(height: 16),
              Text('🍬 Candies: $_candies', style: const TextStyle(fontSize: 18)),
              Text('💰 Score: $_score', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_levelWon && widget.level < GameConfig.totalLevels) _buildSmallButton('Next ➡️', Colors.green, () {
                    audioService.playClick();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level + 1, bunnyLevel: context.read<GameStateService>().bunnySize)));
                  }),
                  const SizedBox(width: 12),
                  _buildSmallButton('🔄', Colors.orange, () {
                    audioService.playClick();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => GameScreen(level: widget.level, bunnyLevel: context.read<GameStateService>().bunnySize)));
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
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Center(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)))),
    );
  }

  Widget _buildSmallButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
    );
  }
}
