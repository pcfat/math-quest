import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

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
                color: PixelTheme.bgMid,
                border: Border.all(color: PixelTheme.textDim, width: 3),
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
    return PixelCard(
      borderColor: PixelTheme.secondary,
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
                    color: PixelTheme.bgLight,
                    border: Border.all(color: PixelTheme.secondary, width: 4),
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
                    border: Border.all(color: Colors.black, width: 2),
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
              color: PixelTheme.secondary,
              border: const Border(
                bottom: BorderSide(color: Color(0xFFb8860b), width: 4),
              ),
            ),
            child: Text(
              'LEVEL ${gameState.level}',
              style: PixelTheme.pixelText(size: 10, color: PixelTheme.bgDark),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpCard(GameState gameState) {
    return PixelCard(
      borderColor: PixelTheme.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('EXPERIENCE', style: PixelTheme.pixelText(size: 10, color: PixelTheme.accent)),
              Text(
                '${gameState.experience} / ${gameState.experienceForNextLevel}',
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PixelProgressBar(
            value: gameState.levelProgress,
            fillColor: PixelTheme.accent,
            height: 24,
          ),
          const SizedBox(height: 8),
          Text(
            'Need ${gameState.experienceForNextLevel - gameState.experience} more to level up!',
            style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard(GameState gameState) {
    return PixelCard(
      borderColor: PixelTheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STATISTICS', style: PixelTheme.pixelText(size: 10, color: PixelTheme.primary)),
          const SizedBox(height: 16),
          _buildStatRow('🏆', 'Total Score', '${gameState.progress.totalScore}'),
          _buildStatRow('📚', 'Quizzes', '${gameState.progress.quizzesCompleted}'),
          _buildStatRow('🔥', 'Best Streak', '${gameState.progress.streak}'),
          _buildStatRow('📅', 'Daily Missions', '${gameState.progress.dailyMissionsCompleted}'),
          _buildStatRow('🎖️', 'Achievements', '${gameState.unlockedAchievements.length}/${gameState.achievements.length}'),
          _buildStatRow('📖', 'Topics Tried', '${gameState.progress.topicAttempts.length}/${gameState.allTopics.length}'),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: PixelTheme.pixelText(size: 9)),
          ),
          Text(value, style: PixelTheme.pixelText(size: 10, color: PixelTheme.secondary)),
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
