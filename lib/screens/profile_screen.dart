import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  
  final List<String> _avatars = [
    '😊', '😎', '🤓', '🧑‍🎓', '👨‍💻', '👩‍🏫', '🦸', '🧙',
    '🐱', '🐶', '🦊', '🐼', '🐨', '🦁', '🐯', '🐮',
    '👾', '🤖', '👻', '💀', '🎮', '🕹️', '🎯', '🏆',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<GameState>().username;
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部欄
              _buildHeader(context),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 頭像卡片
                      _buildAvatarCard(gameState),
                      
                      const SizedBox(height: 16),
                      
                      // 經驗值進度
                      _buildExpCard(gameState),
                      
                      const SizedBox(height: 16),
                      
                      // 統計
                      _buildStatsCard(gameState),
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
  
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PixelTheme.bgCard, PixelTheme.bgMid],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: PixelTheme.textMuted.withOpacity(0.5), width: 2),
              ),
              child: const Center(
                child: Text('←', style: TextStyle(
                  fontFamily: PixelTheme.pixelFont,
                  fontSize: 16,
                  color: PixelTheme.textLight,
                )),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text('PROFILE', style: PixelTheme.pixelTitle(size: 16)),
        ],
      ),
    );
  }
  
  Widget _buildAvatarCard(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PixelTheme.codedexCard(
        borderColor: PixelTheme.secondary.withOpacity(0.5),
        withGlow: true,
      ),
      child: Column(
        children: [
          // 頭像
          GestureDetector(
            onTap: () => _showAvatarPicker(context),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [PixelTheme.secondary, PixelTheme.secondaryGlow],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: PixelTheme.secondary.withOpacity(0.5), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: PixelTheme.secondary.withOpacity(0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(gameState.avatarEmoji, style: const TextStyle(fontSize: 40)),
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: PixelTheme.accent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: const Center(
                    child: Text('✎', style: TextStyle(fontSize: 14)),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 名稱
          GestureDetector(
            onTap: () => _showNameDialog(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameState.username,
                  style: PixelTheme.pixelText(size: 14),
                ),
                const SizedBox(width: 8),
                const Text('✎', style: TextStyle(fontSize: 14, color: PixelTheme.accent)),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 等級
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PixelTheme.secondary, PixelTheme.secondaryGlow],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: PixelTheme.secondary.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              'LEVEL ${gameState.level}',
              style: PixelTheme.pixelText(size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpCard(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PixelTheme.codedexCard(
        borderColor: PixelTheme.primary.withOpacity(0.5),
        withGlow: true,
      ),
      child: XpProgressBar(
        level: gameState.level,
        currentXp: gameState.experience,
        xpToNextLevel: gameState.experienceForNextLevel,
        levelColor: PixelTheme.primary,
      ),
    );
  }
  
  Widget _buildStatsCard(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: PixelTheme.codedexCard(
        borderColor: PixelTheme.accent.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATISTICS', style: PixelTheme.pixelText(size: 10, color: PixelTheme.accent)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatBadge(
                emoji: '🏆',
                value: '${gameState.progress.totalScore}',
                label: 'SCORE',
                glowColor: PixelTheme.secondary,
              ),
              StatBadge(
                emoji: '📚',
                value: '${gameState.progress.quizzesCompleted}',
                label: 'QUIZZES',
              ),
              StatBadge(
                emoji: '🔥',
                value: '${gameState.progress.streak}',
                label: 'STREAK',
                glowColor: PixelTheme.orange,
              ),
              StatBadge(
                emoji: '📅',
                value: '${gameState.progress.dailyMissionsCompleted}',
                label: 'MISSIONS',
              ),
              StatBadge(
                emoji: '🎖️',
                value: '${gameState.unlockedAchievements.length}',
                label: 'BADGES',
                glowColor: PixelTheme.primary,
              ),
              StatBadge(
                emoji: '📖',
                value: '${gameState.progress.topicAttempts.length}',
                label: 'TOPICS',
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showAvatarPicker(BuildContext context) {
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
            Text('SELECT AVATAR', style: PixelTheme.pixelTitle(size: 12)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _avatars.map((emoji) {
                final isSelected = context.read<GameState>().avatarEmoji == emoji;
                return GestureDetector(
                  onTap: () {
                    context.read<GameState>().setAvatar(emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? PixelTheme.accent.withOpacity(0.3) : PixelTheme.bgLight,
                      border: Border.all(
                        color: isSelected ? PixelTheme.accent : PixelTheme.textDim,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  void _showNameDialog(BuildContext context) {
    _nameController.text = context.read<GameState>().username;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelCard(
          borderColor: PixelTheme.accent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('CHANGE NAME', style: PixelTheme.pixelTitle(size: 12)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: PixelTheme.pixelText(size: 12),
                decoration: InputDecoration(
                  hintText: 'Enter name',
                  hintStyle: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim),
                  filled: true,
                  fillColor: PixelTheme.bgLight,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: PixelTheme.textDim, width: 3),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: PixelTheme.textDim, width: 3),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                    borderSide: BorderSide(color: PixelTheme.accent, width: 3),
                  ),
                ),
                maxLength: 10,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      text: 'CANCEL',
                      color: PixelTheme.error,
                      height: 44,
                      fontSize: 8,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PixelButton(
                      text: 'OK',
                      color: PixelTheme.primary,
                      height: 44,
                      fontSize: 8,
                      onPressed: () {
                        if (_nameController.text.trim().isNotEmpty) {
                          context.read<GameState>().setUsername(_nameController.text.trim());
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
