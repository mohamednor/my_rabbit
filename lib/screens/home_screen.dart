import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_rabbit/services/game_state_service.dart';
import 'package:my_rabbit/services/audio_service.dart';
import 'package:my_rabbit/screens/world_select_screen.dart';
import 'package:my_rabbit/screens/shop_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _bunnyController;
  late AnimationController _candyController;
  late Animation<double> _bunnyBounce;
  late Animation<double> _candyFloat;
  bool _playedIntro = false;

  @override
  void initState() {
    super.initState();
    
    // Bunny bounce animation
    _bunnyController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat(reverse: true);
    
    _bunnyBounce = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _bunnyController, curve: Curves.easeInOut),
    );
    
    // Candy float animation
    _candyController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _candyFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _candyController, curve: Curves.easeInOut),
    );
    
    // Play intro sound after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_playedIntro) {
        _playedIntro = true;
        context.read<AudioService>().playWin();
      }
    });
  }

  @override
  void dispose() {
    _bunnyController.dispose();
    _candyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameStateService>();
    final audioService = context.read<AudioService>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1), Color(0xFFFFF0F5), Color(0xFFE6E6FA)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Floating candies background
              ...List.generate(8, (i) => _buildFloatingCandy(i)),
              
              // Main content
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Bouncing bunny
                      AnimatedBuilder(
                        animation: _bunnyBounce,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _bunnyBounce.value),
                            child: _buildBunnyWithCandy(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Title with glow effect
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF1493), Color(0xFFFF69B4), Color(0xFFFF1493)],
                        ).createShader(bounds),
                        child: const Text(
                          'My Rabbit',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(color: Colors.white, offset: Offset(0, 0), blurRadius: 20),
                            ],
                          ),
                        ),
                      ),
                      const Text('🍬 Candy Adventure 🍬', style: TextStyle(fontSize: 22, color: Colors.pink)),
                      const SizedBox(height: 25),
                      
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatBadge('🪙', '${gameState.coins}'),
                          const SizedBox(width: 16),
                          _buildStatBadge('🐰', 'Lv.${gameState.bunnySize}'),
                          const SizedBox(width: 16),
                          _buildStatBadge('⭐', '${gameState.totalStars}'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      
                      // Play button with animation
                      _buildPlayButton(audioService),
                      const SizedBox(height: 16),
                      
                      _buildButton(context, '🛍️ SHOP', const Color(0xFF98FB98), () {
                        audioService.playClick();
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ShopScreen()));
                      }),
                      const SizedBox(height: 30),
                      
                      // Progress info
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Level ${gameState.highestLevel} • ${gameState.completedLevels}/50 completed',
                              style: const TextStyle(fontSize: 14, color: Colors.pink),
                            ),
                            if (gameState.highestLevel > 50)
                              const Text(
                                '🎉 CHASE MODE UNLOCKED! 🐭',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBunnyWithCandy() {
    return SizedBox(
      width: 150,
      height: 150,
      child: CustomPaint(
        painter: BunnyHomePainter(),
      ),
    );
  }
  
  Widget _buildFloatingCandy(int index) {
    final candies = ['🍬', '🍭', '🍫', '🍩', '🧁', '🍪', '🍰', '🍦'];
    final positions = [
      const Offset(30, 100),
      const Offset(320, 150),
      const Offset(50, 300),
      const Offset(300, 350),
      const Offset(40, 500),
      const Offset(330, 480),
      const Offset(60, 650),
      const Offset(310, 620),
    ];
    
    return AnimatedBuilder(
      animation: _candyFloat,
      builder: (context, child) {
        return Positioned(
          left: positions[index % positions.length].dx,
          top: positions[index % positions.length].dy + _candyFloat.value + (index * 5),
          child: Opacity(
            opacity: 0.6,
            child: Text(
              candies[index % candies.length],
              style: const TextStyle(fontSize: 30),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildPlayButton(AudioService audioService) {
    return GestureDetector(
      onTap: () {
        audioService.playClick();
        audioService.playJump();
        Navigator.push(context, MaterialPageRoute(builder: (_) => const WorldSelectScreen()));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(color: Colors.orange.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 8)),
            const BoxShadow(color: Colors.white, blurRadius: 2, offset: Offset(0, -2)),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎮', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text('PLAY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatBadge(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF69B4))),
        ],
      ),
    );
  }
  
  Widget _buildButton(BuildContext context, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}

// Custom painter for animated bunny
class BunnyHomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pink = Paint()..color = const Color(0xFFFFB6C1);
    final white = Paint()..color = Colors.white;
    final black = Paint()..color = Colors.black;
    
    final cx = size.width / 2;
    final cy = size.height / 2;
    
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, size.height - 15), width: 80, height: 20),
      Paint()..color = Colors.black.withOpacity(0.2),
    );
    
    // Ears
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy - 45), width: 22, height: 50), pink);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy - 45), width: 22, height: 50), pink);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy - 45), width: 12, height: 35), Paint()..color = const Color(0xFFFFDAB9));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy - 45), width: 12, height: 35), Paint()..color = const Color(0xFFFFDAB9));
    
    // Body
    canvas.drawCircle(Offset(cx, cy), 45, pink);
    
    // Face
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 8), width: 55, height: 42), white);
    
    // Eyes
    canvas.drawCircle(Offset(cx - 15, cy - 5), 8, black);
    canvas.drawCircle(Offset(cx + 15, cy - 5), 8, black);
    canvas.drawCircle(Offset(cx - 17, cy - 8), 3, white);
    canvas.drawCircle(Offset(cx + 13, cy - 8), 3, white);
    
    // Nose
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 12), width: 12, height: 8), Paint()..color = Colors.pink);
    
    // Mouth (smile)
    final smilePaint = Paint()..color = Colors.pink.shade300..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 22), width: 20, height: 12), 0.2, 2.7, false, smilePaint);
    
    // Cheeks
    canvas.drawCircle(Offset(cx - 35, cy + 5), 10, Paint()..color = Colors.pink.shade200.withOpacity(0.6));
    canvas.drawCircle(Offset(cx + 35, cy + 5), 10, Paint()..color = Colors.pink.shade200.withOpacity(0.6));
    
    // Candy in hand
    final candyX = cx + 50;
    final candyY = cy + 30;
    canvas.drawOval(Rect.fromCenter(center: Offset(candyX, candyY), width: 25, height: 18), Paint()..color = Colors.red);
    canvas.drawOval(Rect.fromCenter(center: Offset(candyX - 18, candyY), width: 12, height: 15), Paint()..color = Colors.red.shade300);
    canvas.drawOval(Rect.fromCenter(center: Offset(candyX + 18, candyY), width: 12, height: 15), Paint()..color = Colors.red.shade300);
    // Candy stripes
    canvas.drawLine(Offset(candyX - 5, candyY - 7), Offset(candyX - 5, candyY + 7), Paint()..color = Colors.white..str
