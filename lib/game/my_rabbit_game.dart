import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:my_rabbit/game/components/bunny_component.dart';
import 'package:my_rabbit/game/components/candy_component.dart';
import 'package:my_rabbit/game/components/obstacle_component.dart';
import 'package:my_rabbit/game/systems/object_pool.dart';
import 'package:my_rabbit/models/game_config.dart';
import 'package:my_rabbit/services/ad_service.dart';

class MyRabbitGame extends FlameGame with PanDetector, TapDetector, HasCollisionDetection {
  final int level;
  final Function onLevelComplete;
  final Function onLevelFailed;
  final Function(int score, int candies) onScoreUpdate;
  
  bool isPlaying = false;
  bool isPaused = false;
  int score = 0;
  int candiesCollected = 0;
  int candyGoal = 0;
  double timeRemaining = 0;
  int lives = 3;
  int growthProgress = 0;
  int bunnyLevel;
  
  AdRewardType? activeBoost;
  double boostTimeRemaining = 0;
  
  BunnyComponent? bunny;
  late GameWorld currentWorld;
  
  late ObjectPool<CandyComponent> candyPool;
  late ObjectPool<ObstacleComponent> obstaclePool;
  
  final List<CandyComponent> _activeCandies = [];
  final List<ObstacleComponent> _activeObstacles = [];
  
  double _candySpawnTimer = 0;
  double _obstacleSpawnTimer = 0;
  late double _speedMult;
  late double _spawnMult;
  final Random _random = Random();
  
  MyRabbitGame({
    required this.level,
    required this.onLevelComplete,
    required this.onLevelFailed,
    required this.onScoreUpdate,
    this.bunnyLevel = 1,
  });
  
  @override
  Color backgroundColor() => currentWorld.color1;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    currentWorld = Worlds.forLevel(level);
    candyGoal = GameConfig.candyGoal(level);
    timeRemaining = GameConfig.timeLimit(level).toDouble();
    _speedMult = GameConfig.speedMultiplier(level);
    _spawnMult = GameConfig.spawnMultiplier(level);
    
    candyPool = ObjectPool<CandyComponent>(create: () => CandyComponent(), initialSize: 20);
    obstaclePool = ObjectPool<ObstacleComponent>(create: () => ObstacleComponent(), initialSize: 10);
    
    // Create bunny at center bottom
    bunny = BunnyComponent(
      position: Vector2(size.x / 2, size.y * 0.75),
      bunnyLevel: bunnyLevel,
    );
    add(bunny!);
    
    // Start the game
    isPlaying = true;
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPlaying || isPaused || bunny == null) return;
    
    final cappedDt = dt.clamp(0.0, GameConfig.maxDeltaTime);
    
    // Update timer
    timeRemaining -= cappedDt;
    if (timeRemaining <= 0) {
      timeRemaining = 0;
      _endLevel();
      return;
    }
    
    // Spawn candies
    _spawnCandies(cappedDt);
    
    // Spawn obstacles (after level 3)
    if (level >= 3) {
      _spawnObstacles(cappedDt);
    }
    
    // Update and check collisions
    _updateEntities();
    _checkCollisions();
    
    // Update boost
    if (activeBoost != null) {
      boostTimeRemaining -= cappedDt;
      if (boostTimeRemaining <= 0) {
        activeBoost = null;
      }
    }
    
    // Check win condition
    if (candiesCollected >= candyGoal) {
      _endLevel();
    }
  }
  
  void _spawnCandies(double dt) {
    _candySpawnTimer += dt;
    final spawnInterval = GameConfig.baseCandySpawnInterval / _spawnMult;
    
    if (_candySpawnTimer >= spawnInterval && _activeCandies.length < GameConfig.maxCandiesOnScreen) {
      _candySpawnTimer = 0;
      final candy = candyPool.obtain();
      if (candy != null) {
        candy.reset(
          position: Vector2(_random.nextDouble() * (size.x - 80) + 40, -60),
          candyType: Candies.getNext(),
          fallSpeed: GameConfig.baseCandyFallSpeed * _speedMult,
        );
        _activeCandies.add(candy);
        add(candy);
      }
    }
  }
  
  void _spawnObstacles(double dt) {
    _obstacleSpawnTimer += dt;
    final spawnInterval = GameConfig.baseObstacleSpawnInterval / _spawnMult;
    
    if (_obstacleSpawnTimer >= spawnInterval && _activeObstacles.length < GameConfig.maxObstaclesOnScreen) {
      _obstacleSpawnTimer = 0;
      final obstacle = obstaclePool.obtain();
      if (obstacle != null) {
        final obstacleType = Obstacles.getForLevel(level);
        double speed = GameConfig.baseObstacleSpeed * _speedMult;
        if (activeBoost == AdRewardType.slowerObstacles) speed *= 0.5;
        
        obstacle.reset(
          position: Vector2(_random.nextDouble() * (size.x - 80) + 40, -60),
          obstacleType: obstacleType,
          fallSpeed: speed,
          horizontalMove: obstacleType.canMove && GameConfig.hasMovingObstacles(level),
          screenWidth: size.x,
        );
        _activeObstacles.add(obstacle);
        add(obstacle);
      }
    }
  }
  
  void _updateEntities() {
    for (int i = _activeCandies.length - 1; i >= 0; i--) {
      if (_activeCandies[i].position.y > size.y + 60) {
        _returnCandy(_activeCandies[i], i);
      }
    }
    for (int i = _activeObstacles.length - 1; i >= 0; i--) {
      if (_activeObstacles[i].position.y > size.y + 60) {
        _returnObstacle(_activeObstacles[i], i);
      }
    }
  }
  
  void _checkCollisions() {
    if (bunny == null) return;
    
    final bunnyPos = bunny!.position;
    double pickupRadius = GameConfig.basePickupRadius + (bunnyLevel * 4);
    if (activeBoost == AdRewardType.biggerRadius) {
      pickupRadius = GameConfig.boostedPickupRadius + (bunnyLevel * 6);
    }
    
    // Check candy collisions
    for (int i = _activeCandies.length - 1; i >= 0; i--) {
      if (bunnyPos.distanceTo(_activeCandies[i].position) < pickupRadius) {
        _collectCandy(_activeCandies[i], i);
      }
    }
    
    // Check obstacle collisions
    if (!bunny!.isJumping) {
      for (int i = _activeObstacles.length - 1; i >= 0; i--) {
        if (bunnyPos.distanceTo(_activeObstacles[i].position) < GameConfig.obstacleHitRadius + 10) {
          _hitObstacle(_activeObstacles[i], i);
        }
      }
    }
  }
  
  void _collectCandy(CandyComponent candy, int index) {
    int points = candy.candyType.points;
    if (activeBoost == AdRewardType.doublePoints) points *= 2;
    
    score += points;
    candiesCollected++;
    growthProgress += candy.candyType.growth;
    
    if (growthProgress >= GameConfig.candiesPerGrowth && bunnyLevel < GameConfig.maxBunnyLevel) {
      bunnyLevel++;
      growthProgress = 0;
      bunny?.levelUp(bunnyLevel);
    }
    
    onScoreUpdate(score, candiesCollected);
    _returnCandy(candy, index);
  }
  
  void _hitObstacle(ObstacleComponent obstacle, int index) {
    lives--;
    bunny?.hurt();
    _returnObstacle(obstacle, index);
    
    if (lives <= 0) {
      isPlaying = false;
      onLevelFailed();
    }
  }
  
  void _returnCandy(CandyComponent candy, int index) {
    _activeCandies.removeAt(index);
    remove(candy);
    candyPool.release(candy);
  }
  
  void _returnObstacle(ObstacleComponent obstacle, int index) {
    _activeObstacles.removeAt(index);
    remove(obstacle);
    obstaclePool.release(obstacle);
  }
  
  void _endLevel() {
    isPlaying = false;
    if (candiesCollected >= candyGoal) {
      onLevelComplete();
    } else {
      onLevelFailed();
    }
  }
  
  void applyBoost(AdRewardType type) {
    activeBoost = type;
    boostTimeRemaining = AdRewardTypeExt.boostDurationSeconds.toDouble();
  }
  
  void pause() => isPaused = true;
  void resume() => isPaused = false;
  
  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (isPlaying && !isPaused && bunny != null) {
      bunny!.moveHorizontal(info.delta.global.x);
    }
  }
  
  @override
  void onTapDown(TapDownInfo info) {
    if (isPlaying && !isPaused && bunny != null) {
      bunny!.jump();
    }
  }
}
