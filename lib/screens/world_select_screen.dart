import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';
import 'package:my_rabbit/screens/game_screen.dart';
import 'package:my_rabbit/screens/chase_screen.dart';

class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

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
            colors: [Color(0xFF87CEEB), Color(0xFFE0FFFF), Color(0xFFFFF0F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        audioService.playClick();
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                        child: const Center(child: Text('←', style: TextStyle(fontSize: 24))),
                      ),
                    ),
                    const Expanded(
                      child: Text('🗺️ Select World', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF1493))),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [const Text('🪙', style: TextStyle(fontSize: 18)), const SizedBox(width: 6), Text('${gameState.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFAA00)))]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Regular worlds (1-50)
                    ...Worlds.all.map((world) {
                      final isUnlocked = gameState.highestLevel >= world.unlockLevel;
                      return _buildWorldCard(context, world, isUnlocked, gameState, audioService);
                    }),
                    
                    // Chase Mode (51+)
                    const SizedBox(height: 20),
                    _buildChaseModeCard(context, gameState, audioService),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildWorldCard(BuildContext context, GameWorld world, bool isUnlocked, GameStateService gameState, AudioService audioService) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [world.color1, world.color2, world.color3]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(world.emoji, style: const TextStyle(fontSize: 36)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(world.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (!isUnlocked) Text('🔒 Unlock at Level ${world.unlockLevel}', style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20))),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: 10,
                itemBuilder: (context, index) {
                  final levelNum = world.unlockLevel + index;
                  final isLevelUnlocked = gameState.isLevelUnlocked(levelNum);
                  final stars = gameState.getStars(levelNum);
                  
                  return GestureDetector(
                    onTap: isLevelUnlocked ? () {
                      audioService.playClick();
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(level: levelNum, bunnyLevel: gameState.bunnySize)));
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isLevelUnlocked ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]) : null,
                        color: isLevelUnlocked ? null : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(isLevelUnlocked ? '$levelNum' : '🔒', style: TextStyle(fontSize: isLevelUnlocked ? 18 : 14, fontWeight: FontWeight.bold, color: isLevelUnlocked ? Colors.white : Colors.grey)),
                          if (stars > 0) Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(3, (i) => Text(i < stars ? '⭐' : '☆', style: const TextStyle(fontSize: 8)))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildChaseModeCard(BuildContext context, GameStateService gameState, AudioService audioService) {
    final isUnlocked = gameState.highestLevel > 50;
    
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFFE91E63), Color(0xFFFF5722)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.purple.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('🐰', style: TextStyle(fontSize: 40)),
                  const Text('➡️', style: TextStyle(fontSize: 30)),
                  const Text('🐭', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CHASE MODE', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text(
                          isUnlocked ? 'Catch the mouse!' : '🔒 Complete Level 50 to unlock!',
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isUnlocked)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Text('🏃 Run • Jump over obstacles • Catch carrots • Chase the mouse! 🥕', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.purple)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: List.generate(10, (index) {
                        final chaseLevel = 51 + index;
                        final isChaseUnlocked = gameState.highestLevel >= chaseLevel;
                        
                        return GestureDetector(
                          onTap: isChaseUnlocked ? () {
                            audioService.playClick();
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ChaseScreen(level: chaseLevel)));
                          } : null,
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: isChaseUnlocked 
                                ? const LinearGradient(colors: [Color(0xFF9C27B0), Color(0xFFE91E63)])
                                : null,
                              color: isChaseUnlocked ? null : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isChaseUnlocked ? '$chaseLevel' : '🔒',
                                style: TextStyle(
                                  fontSize: isChaseUnlocked ? 18 : 14,
                                  fontWeight: FontWeight.bold,
                                  color: isChaseUnlocked ? Colors.white : Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
