import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'grade_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  bool _isTypingComplete = false;
  String _displayedText = '';
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  final List<Map<String, String>> _dialogues = [
    {
      'text': '你好！我係你嘅數學冒險夥伴！🎮',
      'emoji': '🤖',
    },
    {
      'text': '喺呢度，你可以透過做數學題嚟升級同收集寵物！',
      'emoji': '🎮',
    },
    {
      'text': '每日完成任務可以獲得經驗值同金幣 💰',
      'emoji': '✨',
    },
    {
      'text': '準備好開始你嘅數學冒險之旅了嗎？🚀',
      'emoji': '🚀',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeController.forward();
    _startTyping();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _startTyping() async {
    setState(() {
      _isTypingComplete = false;
      _displayedText = '';
    });

    final text = _dialogues[_currentStep]['text']!;
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _displayedText = text.substring(0, i);
        });
      }
    }

    if (mounted) {
      setState(() {
        _isTypingComplete = true;
      });
      _scaleController.forward();
    }
  }

  void _nextStep() async {
    if (_currentStep < _dialogues.length - 1) {
      _scaleController.reset();
      await _fadeController.reverse();
      
      if (mounted) {
        setState(() {
          _currentStep++;
        });
        await _fadeController.forward();
        _startTyping();
      }
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const GradeSelectionScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / _dialogues.length;
    final currentDialogue = _dialogues[_currentStep];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部進度條和 Skip 按鈕
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 進度條
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_currentStep + 1}/${_dialogues.length}',
                            style: PixelTheme.pixelText(
                              size: 8,
                              color: PixelTheme.textDim,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: PixelTheme.bgLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        PixelTheme.accent,
                                        PixelTheme.primary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: PixelTheme.accent.withOpacity(0.5),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Skip 按鈕
                    GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: PixelTheme.bgMid,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: PixelTheme.textMuted.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: PixelTheme.pixelText(
                            size: 8,
                            color: PixelTheme.textDim,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(flex: 2),
              
              // 中央角色
              FadeTransition(
                opacity: _fadeController,
                child: AnimatedBuilder(
                  animation: _scaleController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_scaleController.value * 0.1),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          PixelTheme.primary.withOpacity(0.2),
                          PixelTheme.accent.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PixelTheme.primary.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        currentDialogue['emoji']!,
                        style: const TextStyle(fontSize: 80),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 對話氣泡
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    children: [
                      // 向上箭頭
                      CustomPaint(
                        size: const Size(24, 12),
                        painter: _TrianglePainter(
                          color: PixelTheme.bgCard,
                        ),
                      ),
                      
                      // 對話框
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 120),
                        padding: const EdgeInsets.all(24),
                        decoration: PixelTheme.codedexCard(
                          borderColor: PixelTheme.primary.withOpacity(0.3),
                          borderRadius: 20,
                          withGlow: true,
                        ),
                        child: Center(
                          child: Text(
                            _displayedText,
                            textAlign: TextAlign.center,
                            style: PixelTheme.modernText(
                              size: 18,
                              color: PixelTheme.textLight,
                              weight: FontWeight.w500,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // Continue 按鈕
              AnimatedOpacity(
                opacity: _isTypingComplete ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedScale(
                  scale: _isTypingComplete ? 1.0 : 0.8,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GlowButton(
                      text: _currentStep < _dialogues.length - 1
                          ? 'CONTINUE'
                          : 'START',
                      emoji: _currentStep < _dialogues.length - 1 ? '▶️' : '🚀',
                      color: PixelTheme.cyan,
                      height: 60,
                      fontSize: 12,
                      onPressed: _isTypingComplete ? _nextStep : () {},
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// 自定義三角形畫筆（對話氣泡指示）
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
