import 'dart:ui';

class GameConfig {
  static const double maxDeltaTime = 0.05;
  static const double baseCandySpawnInterval = 0.35;
  static const double baseObstacleSpawnInterval = 1.8;
  static const int maxCandiesOnScreen = 35;
  static const int maxObstaclesOnScreen = 10;
  static const double baseCandyFallSpeed = 180.0;
  static const double baseObstacleSpeed = 140.0;
  static const double bunnyMoveSpeed = 450.0;
  static const double bunnyJumpHeight = 120.0;
  static const double bunnyJumpDuration = 0.5;
  static const double basePickupRadius = 35.0;
  static const double obstacleHitRadius = 22.0;
  static const double boostedPickupRadius = 60.0;
  static const int candiesPerGrowth = 40;
  static const int maxBunnyLevel = 10;
  static const int totalLevels = 50;
  
  static double speedMultiplier(int level) => 1.0 + (level - 1) * 0.10;
  static double spawnMultiplier(int level) => 1.0 + (level - 1) * 0.08;
  static int candyGoal(int level) => 12 + (level * 3);
  static int timeLimit(int level) => (50 - (level ~/ 4)).clamp(20, 50);
  static bool hasMovingObstacles(int level) => level >= 8;
}

class CandyType {
  final String id;
  final String emoji;
  final int points;
  final int growth;
  final Color color;
  
  const CandyType(this.id, this.emoji, this.points, this.growth, this.color);
}

class Candies {
  static const List<CandyType> all = [
    CandyType('candy', '🍬', 10, 1, Color(0xFFFF69B4)),
    CandyType('lollipop', '🍭', 15, 1, Color(0xFFFF1493)),
    CandyType('chocolate', '🍫', 20, 2, Color(0xFF8B4513)),
    CandyType('donut', '🍩', 25, 2, Color(0xFFDEB887)),
    CandyType('cupcake', '🧁', 30, 3, Color(0xFFFFB6C1)),
    CandyType('cookie', '🍪', 15, 1, Color(0xFFD2691E)),
    CandyType('cake', '🍰', 35, 3, Color(0xFFFFF0F5)),
    CandyType('birthday', '🎂', 50, 5, Color(0xFFFFD700)),
    CandyType('icecream', '🍦', 30, 3, Color(0xFFFFDAB9)),
  ];
  
  static int _index = 0;
  static CandyType getNext() {
    _index = (_index + 1) % all.length;
    return all[_index];
  }
}

class ObstacleType {
  final String id;
  final String emoji;
  final bool canMove;
  
  const ObstacleType(this.id, this.emoji, [this.canMove = false]);
}

class Obstacles {
  static const List<ObstacleType> all = [
    ObstacleType('hedgehog', '🦔', true),
    ObstacleType('cactus', '🌵'),
    ObstacleType('wind', '💨', true),
    ObstacleType('fire', '🔥'),
  ];
  
  static int _index = 0;
  static ObstacleType getForLevel(int level) {
    final maxIdx = ((level / 8) + 2).clamp(2, all.length).toInt();
    _index = (_index + 1) % maxIdx;
    return all[_index];
  }
}

class GameWorld {
  final String id;
  final String name;
  final String emoji;
  final Color color1;
  final Color color2;
  final Color color3;
  final int unlockLevel;
  
  const GameWorld(this.id, this.name, this.emoji, this.color1, this.color2, this.color3, this.unlockLevel);
}

class Worlds {
  static const List<GameWorld> all = [
    GameWorld('lollipop', 'Lollipop Forest', '🍭', Color(0xFFFF69B4), Color(0xFFFFB6C1), Color(0xFF98FB98), 1),
    GameWorld('chocolate', 'Chocolate River', '🍫', Color(0xFF8B4513), Color(0xFFD2691E), Color(0xFFDEB887), 11),
    GameWorld('cookie', 'Cookie Village', '🍪', Color(0xFFF4A460), Color(0xFFFFDAB9), Color(0xFFFFE4B5), 21),
    GameWorld('icecream', 'Ice Cream Mountains', '🍦', Color(0xFFE0FFFF), Color(0xFFAFEEEE), Color(0xFFFFB6C1), 31),
    GameWorld('rainbow', 'Rainbow Candy City', '🌈', Color(0xFFFF6B6B), Color(0xFFFFE66D), Color(0xFF4ECDC4), 41),
  ];
  
  static GameWorld forLevel(int level) {
    for (int i = all.length - 1; i >= 0; i--) {
      if (level >= all[i].unlockLevel) return all[i];
    }
    return all[0];
  }
}

class HatItem {
  final String id;
  final String name;
  final String emoji;
  final int cost;
  
  const HatItem(this.id, this.name, this.emoji, this.cost);
}

class Hats {
  static const List<HatItem> all = [
    HatItem('none', 'None', '', 0),
    HatItem('crown', 'Crown', '👑', 100),
    HatItem('tophat', 'Top Hat', '🎩', 150),
    HatItem('party', 'Party', '🥳', 80),
    HatItem('bow', 'Bow', '🎀', 90),
    HatItem('star', 'Star', '⭐', 200),
  ];
}

class OutfitItem {
  final String id;
  final String name;
  final Color color;
  final int cost;
  
  const OutfitItem(this.id, this.name, this.color, this.cost);
}

class Outfits {
  static const List<OutfitItem> all = [
    OutfitItem('pink', 'Pink', Color(0xFFFFB6C1), 0),
    OutfitItem('gold', 'Gold', Color(0xFFFFD700), 200),
    OutfitItem('purple', 'Purple', Color(0xFFDDA0DD), 150),
    OutfitItem('mint', 'Mint', Color(0xFF98FB98), 150),
  ];
}
