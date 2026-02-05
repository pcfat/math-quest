import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  String? _selectedGrade;
  String? _selectedLanguage;
  late AnimationController _fadeController;

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

  @override
  void initState() {
    super.initState();
    final gameState = context.read<GameState>();
    _selectedGrade = gameState.userGrade;
    _selectedLanguage = gameState.questionLanguage;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
                // Custom App Bar
                _buildAppBar(),
                
                const SizedBox(height: 16),
                
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
                        
                        const SizedBox(height: 32),
                        
                        // 其他設定
                        _buildSectionHeader('其他', 'OTHER OPTIONS', '⚙️'),
                        const SizedBox(height: 16),
                        _buildOtherSettings(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                
                // 儲存按鈕
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: PixelButton(
                    text: 'SAVE',
                    emoji: '💾',
                    color: PixelTheme.primary,
                    height: 60,
                    fontSize: 12,
                    onPressed: () => _saveSettings(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PixelTheme.bgMid,
        border: const Border(
          bottom: BorderSide(color: PixelTheme.textDim, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.textDim, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: PixelTheme.textLight, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text('⚙️', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [PixelTheme.secondary, PixelTheme.accent],
            ).createShader(bounds),
            child: Text(
              'SETTINGS',
              style: PixelTheme.pixelTitle(size: 18, color: Colors.white),
            ),
          ),
        ],
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
      children: _grades.map((grade) => _buildGradeCard(grade)).toList(),
    );
  }
  
  Widget _buildGradeCard(Map<String, dynamic> grade) {
    final isSelected = _selectedGrade == grade['id'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedGrade = grade['id']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected 
              ? PixelTheme.primary.withOpacity(0.2)
              : PixelTheme.bgMid,
          border: Border.all(
            color: isSelected ? PixelTheme.primary : PixelTheme.textDim,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? PixelTheme.primary.withOpacity(0.4)
                  : Colors.black.withOpacity(0.3),
              blurRadius: isSelected ? 15 : 5,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            AnimatedScale(
              scale: isSelected ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Text(grade['icon'], style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 6),
            Text(
              grade['name'],
              style: PixelTheme.pixelText(
                size: 10,
                color: isSelected ? PixelTheme.primary : PixelTheme.textLight,
              ),
            ),
            Text(
              grade['nameEn'],
              style: PixelTheme.pixelText(size: 6, color: PixelTheme.textDim),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLanguageSelection() {
    return Row(
      children: _languages.map((lang) {
        final isSelected = _selectedLanguage == lang['id'];
        
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedLanguage = lang['id']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                left: lang['id'] == 'en' ? 8 : 0,
                right: lang['id'] == 'zh' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: isSelected 
                    ? PixelTheme.accent.withOpacity(0.2)
                    : PixelTheme.bgMid,
                border: Border.all(
                  color: isSelected ? PixelTheme.accent : PixelTheme.textDim,
                  width: isSelected ? 4 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? PixelTheme.accent.withOpacity(0.4)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: isSelected ? 15 : 5,
                    spreadRadius: isSelected ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedScale(
                    scale: isSelected ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(lang['icon'], style: const TextStyle(fontSize: 36)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lang['name'],
                    style: PixelTheme.pixelText(
                      size: 12,
                      color: isSelected ? PixelTheme.accent : PixelTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildOtherSettings() {
    return PixelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSettingRow('🔊', '音效', true),
          const SizedBox(height: 12),
          Divider(color: PixelTheme.textDim.withOpacity(0.3), height: 1),
          const SizedBox(height: 12),
          _buildSettingRow('🎵', '背景音樂', true),
          const SizedBox(height: 12),
          Divider(color: PixelTheme.textDim.withOpacity(0.3), height: 1),
          const SizedBox(height: 12),
          _buildSettingRow('📳', '震動', true),
        ],
      ),
    );
  }
  
  Widget _buildSettingRow(String emoji, String label, bool enabled) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: PixelTheme.pixelText(size: 10, color: PixelTheme.textLight),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: enabled ? PixelTheme.primary.withOpacity(0.2) : PixelTheme.bgLight,
            border: Border.all(
              color: enabled ? PixelTheme.primary : PixelTheme.textDim,
              width: 2,
            ),
          ),
          child: Text(
            enabled ? 'ON' : 'OFF',
            style: PixelTheme.pixelText(
              size: 8,
              color: enabled ? PixelTheme.primary : PixelTheme.textDim,
            ),
          ),
        ),
      ],
    );
  }
  
  void _saveSettings(BuildContext context) {
    final gameState = context.read<GameState>();
    
    if (_selectedGrade != null) {
      gameState.setUserGrade(_selectedGrade!);
    }
    if (_selectedLanguage != null) {
      gameState.setQuestionLanguage(_selectedLanguage!);
    }
    
    // 顯示成功動畫
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
    
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context); // 關閉 dialog
      Navigator.pop(context); // 返回主頁
    });
  }
  
  Widget _buildSuccessDialog() {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: PixelCard(
          padding: const EdgeInsets.all(32),
          borderColor: PixelTheme.primary,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('✅', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text(
                'SAVED!',
                style: PixelTheme.pixelTitle(size: 20, color: PixelTheme.primary),
              ),
              const SizedBox(height: 8),
              Text(
                '設定已儲存',
                style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
