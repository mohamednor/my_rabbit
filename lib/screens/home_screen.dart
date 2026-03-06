import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';
import 'package:my_rabbit/screens/world_select_screen.dart';
import 'package:my_rabbit/screens/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bunnyController;
  late Animation<double> _bunnyBounce;
  bool _playedIntro = false;

  @override
  void initState() {
    super.initState();
    
    _bunnyController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    
    _bunnyBounce = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bunnyController, curve: Curves.easeInOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_playedIntro) {
        _playedIntro = true;
        context.read<AudioService>().playWin();
      }
    });
  }

  @override
  void dispose() {
    _bunnyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    final audioService = context.read<AudioService>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1), Color(0xFFFFF0F5), Color(0xFFE6E6FA)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _bunnyBounce,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bunnyBounce.value),
                        child: const Text('🐰', style: TextStyle(fontSize: 100)),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFFFF1493), Color(0xFFFF69B4), Color(0xFFFF1493)],
                    ).createShader(bounds),
                    child: const Text(
                      'My Rabbit',
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text('🍬 Candy Adventure 🍬', style: TextStyle(fontSize: 22, color: Colors.pink)),
                  const SizedBox(height: 25),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatBadge('🪙', '${gameState.coins}'),
                      const SizedBox(width: 16),
                      _buildStatBadge('🐰', 'Lv.${gameState.bunnySize}'),
                      const SizedBox(width: 16),
                      _buildStatBadge('⭐', '${gameState.totalStars}'),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  GestureDetector(
                    onTap: () {
                      audioService.playClick();
                      audioService.playJump();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldSelectScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8))],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎮', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 10),
                          Text('PLAY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GestureDetector(
                    onTap: () {
                      audioService.playClick();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF98FB98),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
                      ),
                      child: const Text('🛍️ SHOP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Level ${gameState.highestLevel} • ${gameState.completedLevels}/50 completed',
                          style: const TextStyle(fontSize: 14, color: Colors.pink),
                        ),
                        if (gameState.highestLevel > 50)
                          const Text(
                            '🎉 CHASE MODE UNLOCKED! 🐭',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatBadge(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4))),
        ],
      ),
    );
  }
}
