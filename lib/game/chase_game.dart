import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/services/audio_service.dart';

// ==================== RUNNER BUNNY ====================
class RunnerBunny extends PositionComponent {
  double laneY;
  int currentLane = 1; // 0, 1, 2 (top, middle, bottom)
  bool isJumping = false;
  double jumpTime = 0;
  int level;
  
  RunnerBunny(this.laneY, this.level) 
    : super(position: Vector2(80, laneY), size: Vector2(70, 70), anchor: Anchor.center);
  
  @override
  void render(Canvas canvas) {
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    
    // Running animation effect
    final runOffset = sin(jumpTime * 15) * 3;
    
    canvas.save();
    canvas.translate(0, runOffset);
    
    // Ears (tilted back for running)
    canvas.drawOval(Rect.fromCenter(center: const Offset(25, 5), width: 14, height: 30), pink);
    canvas.drawOval(Rect.fromCenter(center: const Offset(45, 5), width: 14, height: 30), pink);
    
    // Body
    canvas.drawOval(Rect.fromCenter(center: const Offset(35, 40), width: 50, height: 45), pink);
    
    // Face
    canvas.drawOval(Rect.fromCenter(center: const Offset(35, 42), width: 35, height: 28), white);
    
    // Eyes (determined look)
    canvas.drawCircle(const Offset(28, 38), 5, black);
    canvas.drawCircle(const Offset(42, 38), 5, black);
    canvas.drawCircle(const Offset(26, 36), 2, white);
    canvas.drawCircle(const Offset(40, 36), 2, white);
    
    // Nose
    canvas.drawOval(Rect.fromCenter(center: const Offset(35, 48), width: 8, height: 5), Paint()..color = Colors.pink);
    
    // Legs (running)
    final legPaint = Paint()..color = pink..strokeWidth = 8..strokeCap = StrokeCap.round;
    final legOffset = sin(jumpTime * 20) * 8;
    canvas.drawLine(Offset(25, 60 + legOffset), Offset(20, 70 + legOffset), legPaint);
    canvas.drawLine(Offset(45, 60 - legOffset), Offset(50, 70 - legOffset), legPaint);
    
    canvas.restore();
  }
  
  @override
  void update(double dt) {
    jumpTime += dt;
    
    if (isJumping) {
      // Already handled in changeLane
    }
  }
  
  void changeLane(int newLane, double screenHeight) {
    if (newLane < 0 || newLane > 2 || newLane == currentLane) return;
    currentLane = newLane;
    final lanes = [screenHeight * 0.3, screenHeight * 0.5, screenHeight * 0.7];
    position.y = lanes[currentLane];
    laneY = lanes[currentLane];
  }
}

// ==================== MOUSE ====================
class ChaseMouse extends PositionComponent {
  double speed;
  double baseX;
  double wobbleTime = 0;
  
  ChaseMouse(Vector2 pos, this.speed) 
    : baseX = pos.x, super(position: pos, size: Vector2(50, 50), anchor: Anchor.center);
  
  @override
  void render(Canvas canvas) {
    final gray = Paint()..color = Colors.grey.shade600;
    final pink = Paint()..color = Colors.pink.shade200;
    final black = Paint()..color = Colors.black;
    
    // Body
    canvas.drawOval(Rect.fromCenter(center: const Offset(25, 28), width: 35, height: 28), gray);
    
    // Head
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 25), width: 22, height: 20), gray);
    
    // Ears
    canvas.drawCircle(const Offset(35, 12), 8, gray);
    canvas.drawCircle(const Offset(48, 12), 8, gray);
    canvas.drawCircle(const Offset(35, 12), 5, pink);
    canvas.drawCircle(const Offset(48, 12), 5, pink);
    
    // Eyes
    canvas.drawCircle(const Offset(38, 22), 3, black);
    canvas.drawCircle(const Offset(46, 22), 3, black);
    
    // Nose
    canvas.drawCircle(const Offset(50, 26), 3, pink);
    
    // Tail
    final tailPaint = Paint()..color = gray..strokeWidth = 3..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final tailPath = Path()..moveTo(8, 28)..quadraticBezierTo(-5, 20, -8, 35);
    canvas.drawPath(tailPath, tailPaint);
    
    // Cheese indicator
    canvas.drawPath(
      Path()..moveTo(52, 8)..lineTo(62, 15)..lineTo(52, 15)..close(),
      Paint()..color = Colors.amber,
    );
  }
  
  @override
  void update(double dt) {
    wobbleTime += dt;
    position.x += speed * dt;
    position.y += sin(wobbleTime * 3) * 0.5;
  }
}

// ==================== OBSTACLE ====================
class ChaseObstacle extends PositionComponent {
  final String type;
  double speed;
  late TextPainter tp;
  
  ChaseObstacle(Vector2 pos, this.type, this.speed) 
    : super(position: pos, size: Vector2(60, 60), anchor: Anchor.center) {
    final emoji = type == 'rock' ? '🪨' : type == 'log' ? '🪵' : '🌳';
    tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 45)),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  
  @override
  void render(Canvas canvas) {
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
  
  @override
  void update(double dt) {
    position.x -= speed * dt;
  }
}

// ==================== CARROT COLLECTIBLE ====================
class ChaseCarrot extends PositionComponent {
  double speed;
  late TextPainter tp;
  
  ChaseCarrot(Vector2 pos, this.speed) 
    : super(position: pos, size: Vector2(45, 45), anchor: Anchor.center) {
    tp = TextPainter(
      text: const TextSpan(text: '🥕', style: TextStyle(fontSize: 35)),
      textDirection: TextDirection.ltr,
    )..layout();
  }
  
  @override
  void render(Canvas canvas) {
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
  
  @override
  void update(double dt) {
    position.x -= speed * dt;
  }
}

// ==================== CHASE GAME ====================
class ChaseGame extends FlameGame with TapDetector, VerticalDragDetector {
  final int level;
  final Function onLevelComplete;
  final Function onLevelFailed;
  final Function(int, int) onScoreUpdate;
  final AudioService audioService;
  
  late RunnerBunny bunny;
  ChaseMouse? mouse;
  List<ChaseObstacle> obstacles = [];
  List<ChaseCarrot> carrots = [];
  Random rnd = Random();
  
  int score = 0;
  int carrotsCollected = 0;
  int carrotGoal = 20;
  double timeRemaining = 90;
  double distanceToMouse = 300;
  int lives = 3;
  bool isPlaying = true;
  bool isPaused = false;
  
  double obstacleTimer = 0;
  double carrotTimer = 0;
  double gameSpeed = 200;
  
  final obstacleTypes = ['rock', 'log', 'tree'];
  
  ChaseGame({
    required this.level,
    required this.onLevelComplete,
    required this.onLevelFailed,
    required this.onScoreUpdate,
    required this.audioService,
  }) {
    carrotGoal = 15 + (level - 50) * 2;
    timeRemaining = 120 - (level - 50) * 2;
    if (timeRemaining < 60) timeRemaining = 60;
    gameSpeed = 200 + (level - 50) * 10;
  }
  
  @override
  Color backgroundColor() => const Color(0xFF87CEEB);
  
  @override
  Future<void> onLoad() async {
    // Create bunny
    bunny = RunnerBunny(size.y * 0.5, level - 50);
    bunny.laneY = size.y * 0.5;
    bunny.currentLane = 1;
    add(bunny);
    
    // Create mouse ahead
    mouse = ChaseMouse(Vector2(size.x - 100, size.y * 0.5), 0);
    add(mouse!);
  }
  
  @override
  void render(Canvas canvas) {
    // Sky gradient
    final skyRect = Rect.fromLTWH(0, 0, size.x, size.y * 0.6);
    canvas.drawRect(skyRect, Paint()..shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF87CEEB), Color(0xFFB0E0E6)],
    ).createShader(skyRect));
    
    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * 0.6, size.x, size.y * 0.4),
      Paint()..color = const Color(0xFF90EE90),
    );
    
    // Lanes
    final lanePaint = Paint()..color = Colors.green.shade700..strokeWidth = 2;
    canvas.drawLine(Offset(0, size.y * 0.4), Offset(size.x, size.y * 0.4), lanePaint);
    canvas.drawLine(Offset(0, size.y * 0.6), Offset(size.x, size.y * 0.6), lanePaint);
    
    // Grass details
    final grassPaint = Paint()..color = Colors.green.shade600;
    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.x;
      canvas.drawLine(Offset(x, size.y * 0.85), Offset(x - 5, size.y * 0.8), grassPaint);
      canvas.drawLine(Offset(x, size.y * 0.85), Offset(x + 5, size.y * 0.8), grassPaint);
    }
    
    super.render(canvas);
    
    // Distance indicator
    _drawDistanceIndicator(canvas);
  }
  
  void _drawDistanceIndicator(Canvas canvas) {
    final barWidth = size.x - 40;
    final progress = 1 - (distanceToMouse / 300).clamp(0.0, 1.0);
    
    // Background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, barWidth, 15), const Radius.circular(8)),
      Paint()..color = Colors.white.withOpacity(0.5),
    );
    
    // Progress
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(20, 20, barWidth * progress, 15), const Radius.circular(8)),
      Paint()..color = Colors.orange,
    );
    
    // Mouse icon at end
    final mouseTP = TextPainter(
      text: const TextSpan(text: '🐭', style: TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    )..layout();
    mouseTP.paint(canvas, Offset(size.x - 35, 12));
    
    // Bunny icon at progress
    final bunnyTP = TextPainter(
      text: const TextSpan(text: '🐰', style: TextStyle(fontSize: 20)),
      textDirection: TextDirection.ltr,
    )..layout();
    bunnyTP.paint(canvas, Offset(20 + barWidth * progress - 10, 12));
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || isPaused) return;
    
    final cappedDt = dt.clamp(0.0, 0.05);
    
    // Timer
    timeRemaining -= cappedDt;
    if (timeRemaining <= 0) {
      isPlaying = false;
      audioService.playLose();
      onLevelFailed();
      return;
    }
    
    // Spawn obstacles
    obstacleTimer += cappedDt;
    if (obstacleTimer >= 1.5 && obstacles.length < 5) {
      obstacleTimer = 0;
      _spawnObstacle();
    }
    
    // Spawn carrots
    carrotTimer += cappedDt;
    if (carrotTimer >= 0.8 && carrots.length < 8) {
      carrotTimer = 0;
      _spawnCarrot();
    }
    
    // Update and check collisions
    _updateObstacles();
    _updateCarrots();
    
    // Update distance to mouse
    if (carrotsCollected > 0 && carrotsCollected % 5 == 0) {
      distanceToMouse -= cappedDt * 30;
    }
    
    // Check if caught mouse
    if (distanceToMouse <= 0) {
      isPlaying = false;
      audioService.playWin();
      onLevelComplete();
      return;
    }
    
    // Update mouse position visual
    if (mouse != null) {
      mouse!.position.x = size.x - 50 - (300 - distanceToMouse) * 0.5;
    }
  }
  
  void _spawnObstacle() {
    final lane = rnd.nextInt(3);
    final lanes = [size.y * 0.3, size.y * 0.5, size.y * 0.7];
    final type = obstacleTypes[rnd.nextInt(obstacleTypes.length)];
    
    final obs = ChaseObstacle(
      Vector2(size.x + 50, lanes[lane]),
      type,
      gameSpeed,
    );
    obstacles.add(obs);
    add(obs);
  }
  
  void _spawnCarrot() {
    final lane = rnd.nextInt(3);
    final lanes = [size.y * 0.3, size.y * 0.5, size.y * 0.7];
    
    final carrot = ChaseCarrot(
      Vector2(size.x + 50, lanes[lane]),
      gameSpeed,
    );
    carrots.add(carrot);
    add(carrot);
  }
  
  void _updateObstacles() {
    for (int i = obstacles.length - 1; i >= 0; i--) {
      final obs = obstacles[i];
      
      // Remove if off screen
      if (obs.position.x < -60) {
        remove(obs);
        obstacles.removeAt(i);
        continue;
      }
      
      // Check collision
      if ((obs.position - bunny.position).length < 45) {
        audioService.playHurt();
        lives--;
        remove(obs);
        obstacles.removeAt(i);
        distanceToMouse += 50; // Mouse gets further
        if (distanceToMouse > 300) distanceToMouse = 300;
        
        if (lives <= 0) {
          isPlaying = false;
          audioService.playLose();
          onLevelFailed();
          return;
        }
      }
    }
  }
  
  void _updateCarrots() {
    for (int i = carrots.length - 1; i >= 0; i--) {
      final carrot = carrots[i];
      
      if (carrot.position.x < -50) {
        remove(carrot);
        carrots.removeAt(i);
        continue;
      }
      
      if ((carrot.position - bunny.position).length < 40) {
        audioService.playCollect();
        score += 15;
        carrotsCollected++;
        distanceToMouse -= 10;
        if (distanceToMouse < 0) distanceToMouse = 0;
        onScoreUpdate(score, carrotsCollected);
        remove(carrot);
        carrots.removeAt(i);
      }
    }
  }
  
  @override
  void onTapDown(TapDownInfo info) {
    if (!isPlaying || isPaused) return;
    audioService.playJump();
    
    // Change lane based on tap position
    final tapY = info.eventPosition.global.y;
    if (tapY < size.y * 0.4) {
      bunny.changeLane(0, size.y);
    } else if (tapY > size.y * 0.6) {
      bunny.changeLane(2, size.y);
    } else {
      bunny.changeLane(1, size.y);
    }
  }
  
  @override
  void onVerticalDragEnd(DragEndInfo info) {
    if (!isPlaying || isPaused) return;
    audioService.playJump();
    
    final velocity = info.velocity.global.y;
    if (velocity < -100) {
      // Swipe up
      bunny.changeLane(bunny.currentLane - 1, size.y);
    } else if (velocity > 100) {
      // Swipe down
      bunny.changeLane(bunny.currentLane + 1, size.y);
    }
  }
  
  void pause() => isPaused = true;
  void resume() => isPaused = false;
}
