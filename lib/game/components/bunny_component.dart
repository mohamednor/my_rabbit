import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/models/game_config.dart';

class BunnyComponent extends PositionComponent {
  int bunnyLevel;
  bool isJumping = false;
  bool isHurt = false;
  
  double _jumpProgress = 0;
  double _baseY = 0;
  double _hurtTimer = 0;
  double _visualScale = 1.0;
  
  final Paint _bodyPaint = Paint()..color = const Color(0xFFFFB6C1);
  final Paint _facePaint = Paint()..color = Colors.white;
  final Paint _eyePaint = Paint()..color = Colors.black;
  
  BunnyComponent({
    required Vector2 position,
    this.bunnyLevel = 1,
  }) : super(position: position, size: Vector2(60, 60), anchor: Anchor.center) {
    _baseY = position.y;
    _updateScale();
  }
  
  void _updateScale() {
    _visualScale = 1.0 + (bunnyLevel - 1) * 0.08;
    size = Vector2(60 * _visualScale, 60 * _visualScale);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (isJumping) {
      _jumpProgress += dt / GameConfig.bunnyJumpDuration;
      if (_jumpProgress >= 1.0) {
        _jumpProgress = 0;
        isJumping = false;
        position.y = _baseY;
      } else {
        final jumpCurve = 4 * _jumpProgress * (1 - _jumpProgress);
        position.y = _baseY - (GameConfig.bunnyJumpHeight * jumpCurve * _visualScale);
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
    if (isHurt && (_hurtTimer * 10).floor() % 2 == 0) {
      _bodyPaint.color = Colors.red.shade200;
    } else {
      _bodyPaint.color = const Color(0xFFFFB6C1);
    }
    
    final cx = size.x / 2;
    final cy = size.y / 2;
    
    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 12, cy - 25), width: 12, height: 28), _bodyPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 12, cy - 25), width: 12, height: 28), _bodyPaint);
    
    // Body
    canvas.drawCircle(Offset(cx, cy), size.x * 0.38, _bodyPaint);
    
    // Face
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 3), width: size.x * 0.5, height: size.y * 0.4), _facePaint);
    
    // Eyes
    canvas.drawCircle(Offset(cx - 8, cy - 3), 4, _eyePaint);
    canvas.drawCircle(Offset(cx + 8, cy - 3), 4, _eyePaint);
    
    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 6), width: 6, height: 4), Paint()..color = Colors.pink.shade300);
  }
  
  void moveHorizontal(double deltaX) {
    position.x += deltaX * 1.5;
    final game = findGame();
    if (game != null) {
      position.x = position.x.clamp(size.x / 2, game.size.x - size.x / 2);
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
    _updateScale();
  }
  
  void hurt() {
    isHurt = true;
    _hurtTimer = 0;
  }
}
