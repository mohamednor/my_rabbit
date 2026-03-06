import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/models/game_config.dart';

class ObstacleComponent extends PositionComponent {
  late ObstacleType obstacleType;
  double fallSpeed = 0;
  bool horizontalMove = false;
  double screenWidth = 0;
  double _horizontalDirection = 1;
  
  TextPainter? _emojiPainter;

  ObstacleComponent() : super(size: Vector2(50, 50), anchor: Anchor.center);

  void reset({
    required Vector2 position,
    required ObstacleType obstacleType,
    required double fallSpeed,
    required bool horizontalMove,
    required double screenWidth,
  }) {
    this.position = position;
    this.obstacleType = obstacleType;
    this.fallSpeed = fallSpeed;
    this.horizontalMove = horizontalMove;
    this.screenWidth = screenWidth;
    _horizontalDirection = Random().nextBool() ? 1 : -1;
    
    _emojiPainter = TextPainter(
      text: TextSpan(text: obstacleType.emoji, style: const TextStyle(fontSize: 36)),
      textDirection: TextDirection.ltr,
    );
    _emojiPainter!.layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;
    
    if (horizontalMove) {
      position.x += 80 * _horizontalDirection * dt;
      if (position.x <= 30 || position.x >= screenWidth - 30) {
        _horizontalDirection *= -1;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    // Warning glow
    final paint = Paint()..color = Colors.red.withOpacity(0.3);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 28, paint);
    
    // Draw emoji
    if (_emojiPainter != null) {
      _emojiPainter!.paint(
        canvas,
        Offset((size.x - _emojiPainter!.width) / 2, (size.y - _emojiPainter!.height) / 2),
      );
    }
  }
}
