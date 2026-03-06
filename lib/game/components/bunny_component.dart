import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class BunnyComponent extends PositionComponent {
  int bunnyLevel;
  bool isJumping = false;
  bool isHurt = false;
  
  double _jumpProgress = 0;
  double _baseY = 0;
  double _hurtTimer = 0;

  BunnyComponent({
    required Vector2 position,
    this.bunnyLevel = 1,
  }) : super(
    position: position,
    size: Vector2(80, 80),
    anchor: Anchor.center,
  ) {
    _baseY = position.y;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (isJumping) {
      _jumpProgress += dt / 0.5;
      if (_jumpProgress >= 1.0) {
        _jumpProgress = 0;
        isJumping = false;
        position.y = _baseY;
      } else {
        final jumpCurve = 4 * _jumpProgress * (1 - _jumpProgress);
        position.y = _baseY - (100 * jumpCurve);
      }
    }
    
    if (isHurt) {
      _hurtTimer += dt;
      if (_hurtTimer >= 0.3) {
        isHurt = false;
        _hurtTimer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    
    // Body color
    if (isHurt && (_hurtTimer * 10).floor() % 2 == 0) {
      paint.color = Colors.red.shade200;
    } else {
      paint.color = const Color(0xFFFFB6C1); // Pink
    }
    
    final cx = size.x / 2;
    final cy = size.y / 2;
    
    // === EARS ===
    // Left ear
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 18, cy - 35), width: 18, height: 40),
      paint,
    );
    // Right ear  
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 18, cy - 35), width: 18, height: 40),
      paint,
    );
    
    // Inner ears (lighter pink)
    paint.color = const Color(0xFFFFDAB9);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 18, cy - 35), width: 10, height: 28),
      paint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 18, cy - 35), width: 10, height: 28),
      paint,
    );
    
    // === BODY ===
    if (isHurt && (_hurtTimer * 10).floor() % 2 == 0) {
      paint.color = Colors.red.shade200;
    } else {
      paint.color = const Color(0xFFFFB6C1);
    }
    canvas.drawCircle(Offset(cx, cy), 35, paint);
    
    // === FACE (white) ===
    paint.color = Colors.white;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 5), width: 45, height: 35),
      paint,
    );
    
    // === EYES ===
    paint.color = Colors.black;
    canvas.drawCircle(Offset(cx - 12, cy - 5), 6, paint);
    canvas.drawCircle(Offset(cx + 12, cy - 5), 6, paint);
    
    // Eye shine
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx - 14, cy - 7), 2, paint);
    canvas.drawCircle(Offset(cx + 10, cy - 7), 2, paint);
    
    // === NOSE ===
    paint.color = Colors.pink;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 10, height: 7),
      paint,
    );
    
    // === CHEEKS ===
    paint.color = Colors.pink.shade100.withOpacity(0.6);
    canvas.drawCircle(Offset(cx - 25, cy + 5), 8, paint);
    canvas.drawCircle(Offset(cx + 25, cy + 5), 8, paint);
    
    // === LEVEL BADGE ===
    if (bunnyLevel > 1) {
      paint.color = Colors.amber;
      canvas.drawCircle(Offset(size.x - 12, 12), 12, paint);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '$bunnyLevel',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.x - 12 - textPainter.width / 2, 12 - textPainter.height / 2));
    }
  }

  void moveHorizontal(double deltaX) {
    position.x += deltaX * 1.8;
    final game = findGame();
    if (game != null) {
      position.x = position.x.clamp(50, game.size.x - 50);
    }
  }

  void jump() {
    if (!isJumping) {
      isJumping = true;
      _jumpProgress = 0;
    }
  }

  void levelUp(int newLevel) {
    bunnyLevel = newLevel;
  }

  void hurt() {
    isHurt = true;
    _hurtTimer = 0;
  }
}
