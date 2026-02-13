import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/pixel_theme.dart';
import 'grade_selection_screen.dart';
import 'home_screen.dart';
import 'pet_selection_screen.dart';
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
  late AnimationController _starController;

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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _starController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();
    
    // 延遲顯示元素
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _starController.dispose();
    super.dispose();
  }

  void _startGame() {
    final gameState = context.read<GameState>();
    
    Widget destination;
    if (!gameState.hasChosenGrade) {
      destination = const GradeSelectionScreen();
    } else if (!gameState.hasChosenStarterPet) {
      destination = const PetSelectionScreen();
    } else {
      destination = const HomeScreen();
    }
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
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
        child: Stack(
          children: [
            // 背景星星
            ...List.generate(20, (i) => _buildStar(i)),
            
            // 主內容
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    
                    // 浮動 Logo
                    FadeTransition(
                      opacity: _fadeController,
                      child: AnimatedBuilder(
                        animation: _floatController,
                        builder: (context, child) {
                          final offset = math.sin(_floatController.value * math.pi) * 12;
                          final rotate = math.sin(_floatController.value * math.pi * 2) * 0.02;
                          return Transform.translate(
                            offset: Offset(0, offset),
                            child: Transform.rotate(
                              angle: rotate,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: PixelTheme.primary.withOpacity(0.6),
                                blurRadius: 80,
                                spreadRadius: 30,
                              ),
                              BoxShadow(
                                color: PixelTheme.primary.withOpacity(0.4),
                                blurRadius: 120,
                                spreadRadius: 50,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              decoration: BoxDecoration(
                                color: PixelTheme.bgMid,
                                border: Border.all(color: PixelTheme.primary, width: 4),
                              ),
                              child: const Center(
                                child: Text('📐', style: TextStyle(fontSize: 80)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 遊戲標題
                    FadeTransition(
                      opacity: _fadeController,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [PixelTheme.primary, PixelTheme.accent],
                        ).createShader(bounds),
                        child: Text(
                          'MATH QUEST',
                          style: PixelTheme.pixelTitle(size: 36, color: Colors.white),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    FadeTransition(
                      opacity: _fadeController,
                      child: Text(
                        '數學大冒險',
                        style: PixelTheme.pixelText(size: 22, color: PixelTheme.secondary),
                      ),
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
                          child: GlowButton(
                            text: 'START GAME',
                            emoji: '🎮',
                            color: PixelTheme.primary,
                            height: 70,
                            fontSize: 14,
                            onPressed: _startGame,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // 閃爍提示文字
                    FadeTransition(
                      opacity: _fadeController,
                      child: BlinkingText(
                        text: '- PRESS START -',
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildStar(int index) {
    final random = math.Random(index);
    final size = random.nextDouble() * 3 + 1;
    final left = random.nextDouble() * 400;
    final top = random.nextDouble() * 800;
    final delay = random.nextDouble();
    
    return Positioned(
      left: left,
      top: top,
      child: AnimatedBuilder(
        animation: _starController,
        builder: (context, child) {
          final opacity = (math.sin((_starController.value + delay) * math.pi * 2) + 1) / 2;
          return Opacity(
            opacity: opacity * 0.8,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: size * 2,
                    spreadRadius: size / 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
