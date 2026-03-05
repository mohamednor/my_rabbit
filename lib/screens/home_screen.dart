import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/screens/world_select_screen.dart';
import 'package:my_rabbit/screens/shop_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    
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
                  const Text('🐰', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 20),
                  const Text(
                    'My Rabbit',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF1493),
                      shadows: [Shadow(color: Colors.white, offset: Offset(2, 2), blurRadius: 4)],
                    ),
                  ),
                  const Text('🍬 Candy Adventure 🍬', style: TextStyle(fontSize: 20, color: Colors.pink)),
                  const SizedBox(height: 20),
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
                  _buildButton(context, '🎮 PLAY', const Color(0xFFFFD700), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldSelectScreen()));
                  }),
                  const SizedBox(height: 16),
                  _buildButton(context, '🛍️ SHOP', const Color(0xFF98FB98), () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                  }),
                  const SizedBox(height: 30),
                  Text(
                    'Level ${gameState.highestLevel} • ${gameState.completedLevels}/50 completed',
                    style: const TextStyle(fontSize: 14, color: Colors.pink),
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
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4))),
        ],
      ),
    );
  }
  
  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}
