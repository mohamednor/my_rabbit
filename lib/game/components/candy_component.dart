import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/models/game_config.dart';

class CandyComponent extends PositionComponent {
  late CandyType candyType;
  double fallSpeed = 0;
  double _wobble = 0;
  
  TextPainter? _emojiPainter;

  CandyComponent() : super(size: Vector2(60, 60), anchor: Anchor.center);

  void reset({
    required Vector2 position,
    required CandyType candyType,
    required double fallSpeed,
  }) {
    this.position = position;
    this.candyType = candyType;
    this.fallSpeed = fallSpeed;
    _wobble = 0;
    
    _emojiPainter = TextPainter(
      text: TextSpan(text: candyType.emoji, style: const TextStyle(fontSize: 40)),
      textDirection: TextDirection.ltr,
    );
    _emojiPainter!.layout();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;
    _wobble += dt * 4;
  }

  @override
  void render(Canvas canvas) {
    // Glow effect
    final glowPaint = Paint()..color = candyType.color.withOpacity(0.4);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 30, glowPaint);
    
    // Draw emoji
    if (_emojiPainter != null) {
      final wobbleX = 3 * ((_wobble % 6.28) - 3.14).abs() / 3.14 - 1.5;
      canvas.save();
      canvas.translate(wobbleX, 0);
      _emojiPainter!.paint(
        canvas,
        Offset((size.x - _emojiPainter!.width) / 2, (size.y - _emojiPainter!.height) / 2),
      );
      canvas.restore();
    }
  }
}
