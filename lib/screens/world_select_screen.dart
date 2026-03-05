import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/screens/game_screen.dart';

class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    
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
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)),
                        child: const Center(child: Text('←', style: TextStyle(fontSize: 24))),
                      ),
                    ),
                    const Expanded(
                      child: Text('🗺️ Candy Worlds', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFFF1493))),
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
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: Worlds.all.length,
                  itemBuilder: (context, worldIndex) {
                    final world = Worlds.all[worldIndex];
                    final isUnlocked = gameState.highestLevel >= world.unlockLevel;
                    
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
