import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/services/ad_service.dart';

// ==================== BUNNY ====================
class Bunny extends PositionComponent {
  bool isJumping = false;
  double jumpTime = 0;
  double baseY = 0;
  int level;
  int hatStyle;
  
  Bunny(Vector2 pos, this.level, this.hatStyle) 
    : super(position: pos, size: Vector2(80 + level * 4.0, 80 + level * 4.0), anchor: Anchor.center) {
    baseY = pos.y;
  }
  
  @override
  void render(Canvas canvas) {
    final scale = 1.0 + (level - 1) * 0.08;
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    
    canvas.save();
    canvas.scale(scale);
    final offset = (1 - scale) * 40;
    canvas.translate(offset, offset);
    
    // === HAT based on level ===
    _drawHat(canvas, hatStyle);
    
    // Ears
    canvas.drawOval(Rect.fromCenter(center: const Offset(22, 15), width: 16, height: 35), pink);
    canvas.drawOval(Rect.fromCenter(center: const Offset(58, 15), width: 16, height: 35), pink);
    final earInner = Paint()..color = const Color(0xFFFFDAB9);
    canvas.drawOval(Rect.fromCenter(center: const Offset(22, 15), width: 9, height: 22), earInner);
    canvas.drawOval(Rect.fromCenter(center: const Offset(58, 15), width: 9, height: 22), earInner);
    
    // Body
    canvas.drawCircle(const Offset(40, 50), 32, pink);
    
    // Face
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 55), width: 42, height: 32), white);
    
    // Eyes
    canvas.drawCircle(const Offset(30, 47), 6, black);
    canvas.drawCircle(const Offset(50, 47), 6, black);
    canvas.drawCircle(const Offset(28, 45), 2.5, white);
    canvas.drawCircle(const Offset(48, 45), 2.5, white);
    
    // Nose
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 57), width: 9, height: 6), Paint()..color = Colors.pink.shade400);
    
    // Mouth
    final mouthPaint = Paint()..color = Colors.pink.shade300..style = PaintingStyle.stroke..strokeWidth = 1.5;
    canvas.drawArc(Rect.fromCenter(center: const Offset(40, 62), width: 12, height: 8), 0.2, 2.7, false, mouthPaint);
    
    // Cheeks
    final cheek = Paint()..color = Colors.pink.shade200.withOpacity(0.6);
    canvas.drawCircle(const Offset(16, 55), 7, cheek);
    canvas.drawCircle(const Offset(64, 55), 7, cheek);
    
    canvas.restore();
    
    // Level badge
    if (level > 1) {
      final badge = Paint()..color = Colors.amber;
      canvas.drawCircle(Offset(size.x - 10, 10), 14, badge);
      final tp = TextPainter(
        text: TextSpan(text: '$level', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.x - 10 - tp.width / 2, 10 - tp.height / 2));
    }
  }
  
  void _drawHat(Canvas canvas, int style) {
    switch (style % 6) {
      case 0: // No hat (level 1-5)
        break;
      case 1: // Crown (level 6-10)
        final gold = Paint()..color = Colors.amber;
        canvas.drawRect(const Rect.fromLTWH(20, -5, 40, 15), gold);
        canvas.drawCircle(const Offset(25, -5), 6, gold);
        canvas.drawCircle(const Offset(40, -10), 6, gold);
        canvas.drawCircle(const Offset(55, -5), 6, gold);
        break;
      case 2: // Party hat (level 11-15)
        final partyPaint = Paint()..color = Colors.purple;
        final path = Path()..moveTo(40, -20)..lineTo(20, 10)..lineTo(60, 10)..close();
        canvas.drawPath(path, partyPaint);
        canvas.drawCircle(const Offset(40, -20), 5, Paint()..color = Colors.yellow);
        break;
      case 3: // Top hat (level 16-20)
        final hatPaint = Paint()..color = Colors.black87;
        canvas.drawRect(const Rect.fromLTWH(22, -25, 36, 30), hatPaint);
        canvas.drawRect(const Rect.fromLTWH(15, 0, 50, 8), hatPaint);
        canvas.drawRect(const Rect.fromLTWH(25, -5, 30, 5), Paint()..color = Colors.red);
        break;
      case 4: // Flower (level 21-25)
        final flowerPaint = Paint()..color = Colors.pink.shade300;
        for (int i = 0; i < 5; i++) {
          final angle = i * 3.14159 * 2 / 5;
          canvas.drawCircle(Offset(40 + cos(angle) * 10, -5 + sin(angle) * 10), 7, flowerPaint);
        }
        canvas.drawCircle(const Offset(40, -5), 6, Paint()..color = Colors.yellow);
        break;
      case 5: // Star crown (level 26+)
        final starPaint = Paint()..color = Colors.amber;
        for (int i = 0; i < 3; i++) {
          _drawStar(canvas, Offset(25 + i * 15.0, -8), 8, starPaint);
        }
        break;
    }
  }
  
  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = -3.14159 / 2 + i * 3.14159 * 2 / 5;
      final point = Offset(center.dx + cos(angle) * size, center.dy + sin(angle) * size);
      if (i == 0) path.moveTo(point.dx, point.dy);
      else path.lineTo(point.dx, point.dy);
      
      final innerAngle = angle + 3.14159 / 5;
      final innerPoint = Offset(center.dx + cos(innerAngle) * size * 0.4, center.dy + sin(innerAngle) * size * 0.4);
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  void update(double dt) {
    if (isJumping) {
      jumpTime += dt;
      if (jumpTime >= 0.45) {
        isJumping = false;
        jumpTime = 0;
        position.y = baseY;
      } else {
        position.y = baseY - 120 * (1 - (jumpTime - 0.225).abs() * 4.44);
      }
    }
  }
  
  void moveX(double dx, double screenWidth) {
    position.x = (position.x + dx * 2.2).clamp(50, screenWidth - 50);
  }
  
  void jump() {
    if (!isJumping) {
      isJumping = true;
      jumpTime = 0;
    }
  }
}

// ==================== FALLING ITEM ====================
class FallingItem extends PositionComponent {
  final String emoji;
  final int points;
  final bool isCarrot;
  double speed;
  late TextPainter tp;
  double wobble = 0;
  
  FallingItem(Vector2 pos, this.emoji, this.points, this.speed, {this.isCarrot = false}) 
    : super(position: pos, size: Vector2(55, 55), anchor: Anchor.center) {
    tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 40)),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  
  @override
  void render(Canvas canvas) {
    wobble += 0.1;
    canvas.save();
    canvas.translate(sin(wobble) * 3, 0);
    
    // Glow
    final glow = Paint()..color = (isCarrot ? Colors.orange : Colors.pink).withOpacity(0.3);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 28, glow);
    
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
    canvas.restore();
  }
  
  @override
  void update(double dt) {
    position.y += speed * dt;
  }
}

// ==================== OBSTACLE ====================
class Obstacle extends PositionComponent {
  final String emoji;
  double speed;
  double hSpeed;
  double screenWidth;
  late TextPainter tp;
  
  Obstacle(Vector2 pos, this.emoji, this.speed, this.hSpeed, this.screenWidth) 
    : super(position: pos, size: Vector2(50, 50), anchor: Anchor.center) {
    tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 36)),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  
  @override
  void render(Canvas canvas) {
    final glow = Paint()..color = Colors.red.withOpacity(0.25);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 26, glow);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
  
  @override
  void update(double dt) {
    position.y += speed * dt;
    position.x += hSpeed * dt;
    if (position.x < 30 || position.x > screenWidth - 30) hSpeed = -hSpeed;
  }
}

// ==================== WORLD BACKGROUNDS ====================
class WorldTheme {
  final Color color1;
  final Color color2;
  final String name;
  final String emoji;
  
  const WorldTheme(this.color1, this.color2, this.name, this.emoji);
  
  static WorldTheme forLevel(int level) {
    if (level <= 5) return const WorldTheme(Color(0xFFFFB6C1), Color(0xFFFF69B4), 'Candy Land', '🍭');
    if (level <= 10) return const WorldTheme(Color(0xFF87CEEB), Color(0xFF4169E1), 'Sky World', '☁️');
    if (level <= 15) return const WorldTheme(Color(0xFF98FB98), Color(0xFF228B22), 'Forest', '🌲');
    if (level
