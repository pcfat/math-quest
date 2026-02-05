import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import 'topic_list_screen.dart';
import 'profile_screen.dart';
import 'daily_mission_screen.dart';
import 'leaderboard_screen.dart';
import 'achievements_screen.dart';
import 'pet_collection_screen.dart';
import 'settings_screen.dart';
import 'adventure_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _starController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _starController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: Stack(
          children: [
            // 星星背景
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: StarfieldPainter(_starController.value),
                );
              },
            ),
            
            SafeArea(
              child: Column(
                children: [
                  // 頂部狀態欄
                  _buildStatusBar(gameState),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          
                          // Logo 動畫
                          _buildLogo(),
                          
                          const SizedBox(height: 40),
                          
                          // 主選單按鈕
                          _buildMainMenu(context),
                          
                          const SizedBox(height: 24),
                          
                          // 快捷功能
                          _buildQuickActions(context),
                          
                          const SizedBox(height: 24),
                          
                          // 每日任務提示
                          if (gameState.dailyMission?.isCompleted == false)
                            _buildDailyMissionHint(context, gameState),
                        ],
                      ),
                    ),
                  ),
                  
                  // 底部導航
                  _buildBottomNav(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // 寵物顯示
          if (gameState.activePet != null)
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PetCollectionScreen()),
              ),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: PixelTheme.accent.withOpacity(0.2),
                  border: Border.all(color: PixelTheme.accent, width: 3),
                ),
                child: Center(
                  child: Text(gameState.activePet!.emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
            ),
          
          const SizedBox(width: 8),
          
          // 玩家頭像和等級
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: PixelTheme.bgMid,
                    border: Border.all(color: PixelTheme.secondary, width: 3),
                  ),
                  child: Center(
                    child: Text(gameState.avatarEmoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gameState.username,
                      style: PixelTheme.pixelText(size: 10),
                    ),
                    PixelBadge(text: 'LV ${gameState.level}', fontSize: 6),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 金幣
          _buildStatChip('🪙', '${gameState.progress.totalScore}'),
          
          const SizedBox(width: 12),
          
          // 連勝
          _buildStatChip('🔥', '${gameState.progress.streak}'),
        ],
      ),
    );
  }
  
  Widget _buildStatChip(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PixelTheme.bgMid,
        border: Border.all(color: PixelTheme.textDim, width: 2),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: PixelTheme.pixelText(size: 10)),
        ],
      ),
    );
  }
  
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final offset = math.sin(_floatController.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(0, offset),
          child: child,
        );
      },
      child: Column(
        children: [
          // 遊戲圖標 - 使用自定義 logo
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 40,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image fails to load
                  return Container(
                    decoration: BoxDecoration(
                      color: PixelTheme.bgMid,
                      border: Border.all(color: PixelTheme.primary, width: 4),
                    ),
                    child: const Center(
                      child: Text('📐', style: TextStyle(fontSize: 60)),
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 遊戲標題
          Text(
            'MATH QUEST',
            style: PixelTheme.pixelTitle(size: 24, color: PixelTheme.primary),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '數學大冒險',
            style: PixelTheme.pixelText(size: 18, color: PixelTheme.secondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainMenu(BuildContext context) {
    return Column(
      children: [
        // 開始遊戲
        PixelButton(
          text: 'START GAME',
          emoji: '🎮',
          color: PixelTheme.primary,
          height: 64,
          fontSize: 12,
          onPressed: () => _showGradeSelection(context),
        ),
        
        const SizedBox(height: 16),
        
        // 冒險模式
        PixelButton(
          text: 'ADVENTURE',
          emoji: '🗺️',
          color: PixelTheme.secondary,
          height: 56,
          fontSize: 10,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdventureScreen()),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 計時挑戰
        PixelButton(
          text: 'TIME ATTACK',
          emoji: '⏱️',
          color: PixelTheme.error,
          height: 56,
          fontSize: 10,
          onPressed: () => _showGradeSelection(context, timed: true),
        ),
      ],
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            emoji: '📋',
            label: 'DAILY',
            color: PixelTheme.secondary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DailyMissionScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickButton(
            emoji: '🏆',
            label: 'RANK',
            color: PixelTheme.accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickButton(
            emoji: '🎖️',
            label: 'BADGE',
            color: const Color(0xFFa855f7),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AchievementsScreen()),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuickButton({
    required String emoji,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: PixelCard(
        borderColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(label, style: PixelTheme.pixelText(size: 8, color: color)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyMissionHint(BuildContext context, GameState gameState) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DailyMissionScreen()),
      ),
      child: PixelCard(
        borderColor: PixelTheme.secondary,
        child: Row(
          children: [
            const Text('📋', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '每日任務',
                    style: PixelTheme.pixelText(size: 10, color: PixelTheme.secondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameState.dailyMission?.title ?? '完成任務獲得獎勵！',
                    style: PixelTheme.pixelText(size: 8),
                  ),
                ],
              ),
            ),
            BlinkingText(
              text: 'GO!',
              style: PixelTheme.pixelText(size: 10, color: PixelTheme.primary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PixelTheme.bgMid,
        border: Border(top: BorderSide(color: PixelTheme.textDim, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem('🏠', 'HOME', true, () {}),
          _buildNavItem('📚', 'TOPICS', false, () => _showGradeSelection(context)),
          _buildNavItem('👤', 'PROFILE', false, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          }),
          _buildNavItem('⚙️', 'SETTINGS', false, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(String emoji, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            label,
            style: PixelTheme.pixelText(
              size: 6,
              color: isActive ? PixelTheme.primary : PixelTheme.textDim,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showGradeSelection(BuildContext context, {bool timed = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: PixelTheme.bgMid,
          border: Border(top: BorderSide(color: PixelTheme.textDim, width: 4)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SELECT LEVEL',
              style: PixelTheme.pixelTitle(size: 14),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: PixelButton(
                    text: 'JUNIOR',
                    emoji: '📗',
                    color: PixelTheme.primary,
                    fontSize: 10,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicListScreen(grade: 'junior', timedMode: timed),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: PixelButton(
                    text: 'SENIOR',
                    emoji: '📕',
                    color: PixelTheme.accent,
                    fontSize: 10,
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TopicListScreen(grade: 'senior', timedMode: timed),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              timed ? '⏱️ TIME ATTACK MODE' : '🎮 NORMAL MODE',
              style: PixelTheme.pixelText(
                size: 8,
                color: timed ? PixelTheme.error : PixelTheme.textDim,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 星空背景畫家
class StarfieldPainter extends CustomPainter {
  final double progress;
  final List<_Star> stars;
  
  StarfieldPainter(this.progress) : stars = List.generate(50, (i) => _Star(i));
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final star in stars) {
      final twinkle = (math.sin((progress * math.pi * 2) + star.offset) + 1) / 2;
      paint.color = PixelTheme.textLight.withOpacity(0.2 + twinkle * 0.5);
      
      final x = (star.x * size.width + progress * star.speed * 50) % size.width;
      final y = star.y * size.height;
      
      // 像素風格的星星 (2x2 方塊)
      canvas.drawRect(
        Rect.fromLTWH(x, y, star.size, star.size),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double offset;
  
  _Star(int seed) :
    x = math.Random(seed).nextDouble(),
    y = math.Random(seed + 1).nextDouble(),
    size = (math.Random(seed + 2).nextDouble() * 3 + 1).roundToDouble(),
    speed = math.Random(seed + 3).nextDouble() * 0.5,
    offset = math.Random(seed + 4).nextDouble() * math.pi * 2;
}
