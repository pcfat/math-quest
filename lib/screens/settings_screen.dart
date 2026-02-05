import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _selectedGrade;
  String? _selectedLanguage;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.textLight),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              
              // 選擇內容
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // 年級選擇
                      _buildSectionHeader('選擇年級', 'SELECT GRADE'),
                      const SizedBox(height: 12),
                      _buildGradeGrid(),
                      
                      const SizedBox(height: 28),
                      
                      // 語言選擇
                      _buildSectionHeader('題目語言', 'QUESTION LANGUAGE'),
                      const SizedBox(height: 12),
                      _buildLanguageSelection(),
                      
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
                  height: 56,
                  fontSize: 10,
                  onPressed: () => _saveSettings(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          color: PixelTheme.secondary,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: PixelTheme.pixelText(size: 12, color: PixelTheme.textLight)),
            Text(subtitle, style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim)),
          ],
        ),
      ],
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
          boxShadow: isSelected ? [
            BoxShadow(
              color: PixelTheme.primary.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: Column(
          children: [
            Text(grade['icon'], style: const TextStyle(fontSize: 26)),
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
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: PixelTheme.accent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ] : null,
              ),
              child: Column(
                children: [
                  Text(lang['icon'], style: const TextStyle(fontSize: 36)),
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
  
  void _saveSettings(BuildContext context) {
    final gameState = context.read<GameState>();
    
    if (_selectedGrade != null) {
      gameState.setUserGrade(_selectedGrade!);
    }
    if (_selectedLanguage != null) {
      gameState.setQuestionLanguage(_selectedLanguage!);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '設定已儲存！',
          style: PixelTheme.pixelText(size: 10, color: Colors.white),
        ),
        backgroundColor: PixelTheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    
    Navigator.pop(context);
  }
}
