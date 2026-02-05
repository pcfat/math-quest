import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/pixel_theme.dart';
import 'grade_selection_screen.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    
    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // 延遲顯示按鈕
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startGame() {
    final gameState = context.read<GameState>();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => gameState.hasChosenGrade 
            ? const HomeScreen() 
            : const GradeSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                // 浮動 Logo
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final offset = math.sin(_floatController.value * math.pi) * 12;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text(
                        '📐',
                        style: TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 遊戲標題
                Text(
                  'MATH QUEST',
                  style: PixelTheme.pixelTitle(size: 32, color: PixelTheme.primary),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  '數學大冒險',
                  style: PixelTheme.pixelText(size: 20, color: PixelTheme.secondary),
                ),
                
                const Spacer(flex: 2),
                
                // 開始按鈕
                FadeTransition(
                  opacity: _fadeController,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.05);
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: PixelButton(
                        text: 'START GAME',
                        emoji: '🎮',
                        color: PixelTheme.primary,
                        height: 64,
                        fontSize: 12,
                        onPressed: _startGame,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 提示文字
                FadeTransition(
                  opacity: _fadeController,
                  child: Text(
                    '點擊開始遊戲',
                    style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
                  ),
                ),
                
                const Spacer(flex: 1),
                
                // 版本號
                Text(
                  'v1.0.0',
                  style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
