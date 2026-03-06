import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/ad_service.dart';

// ==================== BUNNY ====================
class Bunny extends PositionComponent {
  bool isJumping = false;
  double jumpTime = 0;
  double baseY = 0;
  int level = 1;
  
  Bunny(Vector2 pos) : super(position: pos, size: Vector2(80, 80), anchor: Anchor.center) {
    baseY = pos.y;
  }
  
  @override
  void render(Canvas canvas) {
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    
    // Ears
    canvas.drawOval(Rect.fromCenter(center: const Offset(22, 10), width: 16, height: 35), pink);
    canvas.drawOval(Rect.fromCenter(center: const Offset(58, 10), width: 16, height: 35), pink);
    
    // Body
    canvas.drawCircle(const Offset(40, 45), 32, pink);
    
    // Face
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 50), width: 40, height: 30), white);
    
    // Eyes
    canvas.drawCircle(const Offset(30, 42), 5, black);
    canvas.drawCircle(const Offset(50, 42), 5, black);
    canvas.drawCircle(const Offset(28, 40), 2, white);
    canvas.drawCircle(const Offset(48, 40), 2, white);
    
    // Nose
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 52), width: 8, height: 5), Paint()..color = Colors.pink);
    
    // Cheeks
    final cheek = Paint()..color = Colors.pink.shade100.withOpacity(0.5);
    canvas.drawCircle(const Offset(18, 50), 6, cheek);
    canvas.drawCircle(const Offset(62, 50), 6, cheek);
  }
  
  @override
  void update(double dt) {
    if (isJumping) {
      jumpTime += dt;
      if (jumpTime >= 0.5) {
        isJumping = false;
        jumpTime = 0;
        position.y = baseY;
      } else {
        position.y = baseY - 100 * (1 - (jumpTime - 0.25).abs() * 4);
      }
    }
  }
  
  void moveX(double dx) {
    position.x = (position.x + dx * 2).clamp(50, 350);
  }
  
  void jump() {
    if (!isJumping) {
      isJumping = true;
      jumpTime = 0;
    }
  }
}

// ==================== CANDY ====================
class Candy extends PositionComponent {
  final String emoji;
  final int points;
  double speed;
  late TextPainter tp;
  
  Candy(Vector2 pos, this.emoji, this.points, this.speed) 
    : super(position: pos, size: Vector2(50, 50), anchor: Anchor.center) {
    tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 36)),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  
  @override
  void render(Canvas canvas) {
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
  
  @override
  void update(double dt) {
    position.y += speed * dt;
  }
}

// ==================== GAME ====================
class MyRabbitGame extends FlameGame with PanDetector, TapDetector {
  final int level;
  final Function onLevelComplete;
  final Function onLevelFailed;
  final Function(int, int) onScoreUpdate;
  int bunnyLevel;
  
  late Bunny bunny;
  List<Candy> candies = [];
  Random rnd = Random();
  
  int score = 0;
  int candiesCollected = 0;
  int candyGoal = 15;
  double timeRemaining = 60;
  int lives = 3;
  bool isPlaying = true;
  bool isPaused = false;
  
  double spawnTimer = 0;
  
  AdRewardType? activeBoost;
  double boostTimeRemaining = 0;
  
  final emojis = ['🍬', '🍭', '🍫', '🍩', '🧁', '🍪', '🍰', '🍦'];
  
  MyRabbitGame({
    required this.level,
    required this.onLevelComplete,
    required this.onLevelFailed,
    required this.onScoreUpdate,
    this.bunnyLevel = 1,
  }) {
    candyGoal = 10 + level * 3;
    timeRemaining = 60 - (level ~/ 5) * 5;
    if (timeRemaining < 30) timeRemaining = 30;
  }
  
  @override
  Color backgroundColor() => const Color(0xFFFFB6C1);
  
  @override
  Future<void> onLoad() async {
    bunny = Bunny(Vector2(size.x / 2, size.y - 150));
    bunny.baseY = size.y - 150;
    add(bunny);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || isPaused) return;
    
    // Timer
    timeRemaining -= dt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      isPlaying = false;
      if (candiesCollected >= candyGoal) {
        onLevelComplete();
      } else {
        onLevelFailed();
      }
      return;
    }
    
    // Spawn candies
    spawnTimer += dt;
    if (spawnTimer >= 0.5 && candies.length < 20) {
      spawnTimer = 0;
      final emoji = emojis[rnd.nextInt(emojis.length)];
      final candy = Candy(
        Vector2(rnd.nextDouble() * (size.x - 100) + 50, -50),
        emoji,
        10,
        150 + level * 10.0,
      );
      candies.add(candy);
      add(candy);
    }
    
    // Update candies & check collision
    for (int i = candies.length - 1; i >= 0; i--) {
      final candy = candies[i];
      
      // Remove if off screen
      if (candy.position.y > size.y + 50) {
        remove(candy);
        candies.removeAt(i);
        continue;
      }
      
      // Check collision with bunny
      if ((candy.position - bunny.position).length < 50) {
        score += candy.points;
        candiesCollected++;
        onScoreUpdate(score, candiesCollected);
        remove(candy);
        candies.removeAt(i);
        
        // Check win
        if (candiesCollected >= candyGoal) {
          isPlaying = false;
          onLevelComplete();
          return;
        }
      }
    }
    
    // Boost timer
    if (activeBoost != null) {
      boostTimeRemaining -= dt;
      if (boostTimeRemaining <= 0) activeBoost = null;
    }
  }
  
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isPlaying && !isPaused) {
      bunny.moveX(info.delta.global.x);
    }
  }
  
  @override
  void onTapDown(TapDownInfo info) {
    if (isPlaying && !isPaused) {
      bunny.jump();
    }
  }
  
  void pause() => isPaused = true;
  void resume() => isPaused = false;
  
  void applyBoost(AdRewardType type) {
    activeBoost = type;
    boostTimeRemaining = 12;
  }
}
