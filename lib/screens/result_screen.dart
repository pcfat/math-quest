import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late AnimationController _starsController;
  late AnimationController _confettiController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _starsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    final gameState = context.read<GameState>();
    _scoreAnimation = Tween<double>(
      begin: 0,
      end: gameState.sessionScore.toDouble(),
    ).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOutCubic,
    ));
    
    // 動畫序列
    _scoreController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _starsController.forward();
    });
    if (gameState.sessionCorrect / gameState.totalQuestions >= 0.6) {
      _confettiController.repeat();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _starsController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final totalQuestions = gameState.totalQuestions;
    final correctCount = gameState.sessionCorrect;
    final percentage = totalQuestions > 0 
        ? (correctCount / totalQuestions * 100).round() 
        : 0;
    
    final grade = _getGrade(percentage);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: Stack(
          children: [
            // 像素 Confetti 效果
            if (percentage >= 60)
              AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: PixelConfettiPainter(_confettiController.value),
                  );
                },
              ),
            
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  
                  // 結果標題
                  Text(
                    grade.title,
                    style: PixelTheme.pixelTitle(size: 20, color: grade.color),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 大表情
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: grade.color.withOpacity(0.2),
                            border: Border.all(color: grade.color, width: 4),
                          ),
                          child: Center(
                            child: Text(grade.emoji, style: const TextStyle(fontSize: 60)),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    grade.message,
                    style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 分數卡片
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: PixelCard(
                      borderColor: grade.color,
                      child: Column(
                        children: [
                          // 課題名稱
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                gameState.currentTopic?.icon ?? '',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                gameState.currentTopic?.name ?? 'QUIZ',
                                style: PixelTheme.pixelText(size: 10),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 動態分數
                          AnimatedBuilder(
                            animation: _scoreAnimation,
                            builder: (context, child) {
                              return Column(
                                children: [
                                  Text(
                                    'SCORE',
                                    style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_scoreAnimation.value.round()}',
                                    style: PixelTheme.pixelTitle(size: 40, color: PixelTheme.secondary),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // 統計
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: PixelTheme.bgLight.withOpacity(0.5),
                              border: Border.all(color: PixelTheme.textDim, width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem('✓', '$correctCount/$totalQuestions', 'CORRECT'),
                                _buildStatItem('📊', '$percentage%', 'ACCURACY'),
                                _buildStatItem('🔥', '${gameState.progress.streak}', 'STREAK'),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 經驗值
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: PixelTheme.accent.withOpacity(0.2),
                              border: Border.all(color: PixelTheme.accent, width: 2),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('⭐', style: TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Text(
                                  '+${gameState.sessionScore ~/ 2} EXP',
                                  style: PixelTheme.pixelText(size: 10, color: PixelTheme.accent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const Spacer(flex: 2),
                  
                  // 按鈕
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        PixelButton(
                          text: 'RETRY',
                          emoji: '🔄',
                          color: PixelTheme.primary,
                          height: 56,
                          fontSize: 12,
                          onPressed: () => _retryQuiz(context),
                        ),
                        const SizedBox(height: 12),
                        PixelButton(
                          text: 'HOME',
                          emoji: '🏠',
                          color: PixelTheme.accent,
                          height: 56,
                          fontSize: 12,
                          onPressed: () => _goHome(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value, style: PixelTheme.pixelText(size: 12)),
        Text(label, style: PixelTheme.pixelText(size: 6, color: PixelTheme.textDim)),
      ],
    );
  }
  
  _Grade _getGrade(int percentage) {
    if (percentage >= 80) {
      return _Grade('EXCELLENT!', '🏆', 'You are a math genius!', PixelTheme.secondary);
    } else if (percentage >= 60) {
      return _Grade('GREAT!', '👍', 'Keep up the good work!', PixelTheme.primary);
    } else if (percentage >= 40) {
      return _Grade('GOOD TRY', '💪', 'Practice makes perfect!', PixelTheme.accent);
    } else {
      return _Grade('KEEP GOING', '📚', 'Don\'t give up!', PixelTheme.error);
    }
  }
  
  void _retryQuiz(BuildContext context) {
    final gameState = context.read<GameState>();
    final topic = gameState.currentTopic;
    final wasTimed = gameState.isTimedMode;
    
    if (topic != null) {
      gameState.startQuiz(topic, timed: wasTimed);
      Navigator.pop(context);
    }
  }
  
  void _goHome(BuildContext context) {
    context.read<GameState>().resetQuiz();
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class _Grade {
  final String title;
  final String emoji;
  final String message;
  final Color color;
  
  const _Grade(this.title, this.emoji, this.message, this.color);
}

/// 像素風格 Confetti
class PixelConfettiPainter extends CustomPainter {
  final double progress;
  final List<_PixelConfetti> confettis;
  
  PixelConfettiPainter(this.progress) : confettis = List.generate(30, (i) => _PixelConfetti(i));
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    for (final c in confettis) {
      paint.color = c.color;
      
      final x = (c.x * size.width + progress * c.speedX * 100) % size.width;
      final y = (c.y + progress * c.speedY) * size.height % size.height;
      
      // 像素方塊
      canvas.drawRect(
        Rect.fromLTWH(x, y, c.size, c.size),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PixelConfetti {
  final double x;
  final double y;
  final double size;
  final double speedX;
  final double speedY;
  final Color color;
  
  _PixelConfetti(int seed) :
    x = math.Random(seed).nextDouble(),
    y = math.Random(seed + 1).nextDouble(),
    size = (math.Random(seed + 2).nextDouble() * 6 + 4).roundToDouble(),
    speedX = math.Random(seed + 3).nextDouble() * 2 - 1,
    speedY = math.Random(seed + 4).nextDouble() * 2 + 1,
    color = [
      PixelTheme.primary,
      PixelTheme.secondary,
      PixelTheme.accent,
      PixelTheme.error,
      const Color(0xFFa855f7),
    ][seed % 5];
}
