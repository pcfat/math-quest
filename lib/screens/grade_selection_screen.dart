import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'pet_selection_screen.dart';

class GradeSelectionScreen extends StatefulWidget {
  const GradeSelectionScreen({super.key});

  @override
  State<GradeSelectionScreen> createState() => _GradeSelectionScreenState();
}

class _GradeSelectionScreenState extends State<GradeSelectionScreen>
    with TickerProviderStateMixin {
  String? _selectedGrade;
  String? _selectedLanguage;
  late AnimationController _fadeController;
  late AnimationController _bounceController;

  final List<Map<String, dynamic>> _grades = [
    {'id': 's1', 'name': '中一', 'nameEn': 'Form 1', 'icon': '📕'},
    {'id': 's2', 'name': '中二', 'nameEn': 'Form 2', 'icon': '📓'},
    {'id': 's3', 'name': '中三', 'nameEn': 'Form 3', 'icon': '📔'},
    {'id': 's4', 'name': '中四', 'nameEn': 'Form 4', 'icon': '📒'},
    {'id': 's5', 'name': '中五', 'nameEn': 'Form 5', 'icon': '📚'},
    {'id': 's6', 'name': '中六', 'nameEn': 'Form 6', 'icon': '🎓'},
  ];

  final List<Map<String, dynamic>> _languages = [
    {'id': 'zh', 'name': '中文', 'icon': '🇭🇰'},
    {'id': 'en', 'name': 'English', 'icon': '🇬🇧'},
  ];

  bool get _canContinue => _selectedGrade != null && _selectedLanguage != null;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeController,
            child: Column(
              children: [
                const SizedBox(height: 30),
                
                // Logo with glow
                AnimatedBuilder(
                  animation: _bounceController,
                  builder: (context, child) {
                    final offset = math.sin(_bounceController.value * math.pi) * 5;
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: PixelTheme.primary.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Text('📐', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 標題
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [PixelTheme.secondary, PixelTheme.accent],
                  ).createShader(bounds),
                  child: Text(
                    'WELCOME!',
                    style: PixelTheme.pixelTitle(size: 28, color: Colors.white),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  '歡迎來到數學大冒險',
                  style: PixelTheme.pixelText(size: 12, color: PixelTheme.textDim),
                ),
                
                const SizedBox(height: 12),
                
                // 提示 badge
                PixelBadge(
                  text: '💡 稍後可在設定中更改',
                  color: PixelTheme.bgLight,
                  fontSize: 7,
                ),
                
                const SizedBox(height: 24),
                
                // 選擇內容
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // 年級選擇
                        _buildSectionHeader('選擇年級', 'SELECT GRADE', '📚'),
                        const SizedBox(height: 16),
                        _buildGradeGrid(),
                        
                        const SizedBox(height: 32),
                        
                        // 語言選擇
                        _buildSectionHeader('題目語言', 'QUESTION LANGUAGE', '🌐'),
                        const SizedBox(height: 16),
                        _buildLanguageSelection(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                
                // 確認按鈕
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedOpacity(
                    opacity: _canContinue ? 1.0 : 0.5,
                    duration: const Duration(milliseconds: 300),
                    child: PixelButton(
                      text: 'CONTINUE',
                      emoji: '▶️',
                      color: _canContinue ? PixelTheme.primary : PixelTheme.textDim,
                      height: 60,
                      fontSize: 12,
                      onPressed: _canContinue ? () => _confirmSelection(context) : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, String subtitle, String emoji) {
    return PixelCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: PixelTheme.accent,
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: PixelTheme.pixelText(size: 12, color: PixelTheme.textLight)),
              Text(subtitle, style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim)),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGradeGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _grades.asMap().entries.map((entry) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + entry.key * 100),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildGradeCard(entry.value),
        );
      }).toList(),
    );
  }
  
  Widget _buildGradeCard(Map<String, dynamic> grade) {
    final isSelected = _selectedGrade == grade['id'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedGrade = grade['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: PixelTheme.codedexCard(
          color: isSelected 
              ? PixelTheme.primary.withOpacity(0.2)
              : null,
          borderColor: isSelected ? PixelTheme.primary : PixelTheme.textMuted,
          borderRadius: 12,
          withGlow: isSelected,
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(grade['icon'], style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(height: 8),
            Text(
              grade['name'],
              style: PixelTheme.pixelText(
                size: 11,
                color: isSelected ? PixelTheme.primary : PixelTheme.textLight,
              ),
            ),
            Text(
              grade['nameEn'],
              style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSelection() {
    return Row(
      children: _languages.asMap().entries.map((entry) {
        final lang = entry.value;
        final isSelected = _selectedLanguage == lang['id'];
        
        return Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 500 + entry.key * 200),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () => setState(() => _selectedLanguage = lang['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(
                  left: lang['id'] == 'en' ? 8 : 0,
                  right: lang['id'] == 'zh' ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: PixelTheme.codedexCard(
                  color: isSelected 
                      ? PixelTheme.accent.withOpacity(0.2)
                      : null,
                  borderColor: isSelected ? PixelTheme.accent : PixelTheme.textMuted,
                  borderRadius: 12,
                  withGlow: isSelected,
                ),
                child: Column(
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(lang['icon'], style: const TextStyle(fontSize: 40)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lang['name'],
                      style: PixelTheme.pixelText(
                        size: 14,
                        color: isSelected ? PixelTheme.accent : PixelTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  void _confirmSelection(BuildContext context) {
    final gameState = context.read<GameState>();
    gameState.setUserGrade(_selectedGrade!);
    gameState.setQuestionLanguage(_selectedLanguage!);
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PetSelectionScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
