import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/game_state_service.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF98FB98), Color(0xFF90EE90), Color(0xFFF0FFF0)],
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
                      child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(24)), child: const Center(child: Text('←', style: TextStyle(fontSize: 24)))),
                    ),
                    const Expanded(child: Text('🛍️ Candy Shop', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF228B22)))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [const Text('🪙', style: TextStyle(fontSize: 18)), const SizedBox(width: 6), Text('${gameState.coins}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFFAA00)))]),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.pink.shade100, Colors.purple.shade100]), borderRadius: BorderRadius.circular(24)),
                child: const Text('🐰', style: TextStyle(fontSize: 80)),
              ),
              const SizedBox(height: 20),
              const Text('👒 Hats', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22))),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: Hats.all.length,
                  itemBuilder: (context, index) {
                    final hat = Hats.all[index];
                    final owned = gameState.ownedHats.contains(hat.id);
                    final equipped = gameState.currentHat == hat.id;
                    final canAfford = gameState.coins >= hat.cost;
                    
                    return GestureDetector(
                      onTap: () {
                        if (owned) {
                          gameState.equipHat(hat.id);
                        } else if (canAfford && gameState.spendCoins(hat.cost)) {
                          gameState.purchaseHat(hat.id);
                          gameState.equipHat(hat.id);
                        }
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: equipped ? Colors.green.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: equipped ? Border.all(color: Colors.green, width: 3) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(hat.emoji.isEmpty ? '❌' : hat.emoji, style: const TextStyle(fontSize: 30)),
                            Text(hat.name, style: const TextStyle(fontSize: 10)),
                            if (!owned) Text('${hat.cost} 🪙', style: TextStyle(fontSize: 10, color: canAfford ? Colors.amber.shade700 : Colors.grey)),
                            if (owned) const Text('✓', style: TextStyle(fontSize: 12, color: Colors.green)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              const Text('🎨 Colors', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF228B22))),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: Outfits.all.length,
                  itemBuilder: (context, index) {
                    final outfit = Outfits.all[index];
                    final owned = gameState.ownedOutfits.contains(outfit.id);
                    final equipped = gameState.currentOutfit == outfit.id;
                    final canAfford = gameState.coins >= outfit.cost;
                    
                    return GestureDetector(
                      onTap: () {
                        if (owned) {
                          gameState.equipOutfit(outfit.id);
                        } else if (canAfford && gameState.spendCoins(outfit.cost)) {
                          gameState.purchaseOutfit(outfit.id);
                          gameState.equipOutfit(outfit.id);
                        }
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: equipped ? Colors.green.shade100 : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: equipped ? Border.all(color: Colors.green, width: 3) : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(width: 40, height: 40, decoration: BoxDecoration(color: outfit.color, shape: BoxShape.circle)),
                            const SizedBox(height: 4),
                            Text(outfit.name, style: const TextStyle(fontSize: 10)),
                            if (!owned) Text('${outfit.cost} 🪙', style: TextStyle(fontSize: 10, color: canAfford ? Colors.amber.shade700 : Colors.grey)),
                            if (owned) const Text('✓', style: TextStyle(fontSize: 12, color: Colors.green)),
                          ],
                        ),
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
