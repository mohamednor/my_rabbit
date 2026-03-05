import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/models/game_config.dart';

class CandyComponent extends PositionComponent {
  late CandyType candyType;
  double fallSpeed = 0;
  double _wobble = 0;
  
  final Paint _glowPaint = Paint();
  TextPainter? _emojiPainter;
  String _cachedEmoji = '';
  
  CandyComponent() : super(size: Vector2(50, 50), anchor: Anchor.center);
  
  void reset({
    required Vector2 position,
    required CandyType candyType,
    required double fallSpeed,
  }) {
    this.position = position;
    this.candyType = candyType;
    this.fallSpeed = fallSpeed;
    _wobble = 0;
    _glowPaint.color = candyType.color.withOpacity(0.3);
    
    if (_cachedEmoji != candyType.emoji) {
      _cachedEmoji = candyType.emoji;
      _emojiPainter = TextPainter(
        text: TextSpan(text: candyType.emoji, style: const TextStyle(fontSize: 36)),
        textDirection: TextDirection.ltr,
      );
      _emojiPainter!.layout();
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    position.y += fallSpeed * dt;
    _wobble += dt * 5;
  }
  
  @override
  void render(Canvas canvas) {
    canvas.save();
    final wobbleOffset = 3 * ((_wobble % 6.28) < 3.14 ? 1 : -1) * ((_wobble % 3.14) / 3.14);
    canvas.translate(wobbleOffset, 0);
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x * 0.6, _glowPaint);
    _emojiPainter?.paint(canvas, Offset((size.x - _emojiPainter!.width) / 2, (size.y - _emojiPainter!.height) / 2));
    canvas.restore();
  }
}
