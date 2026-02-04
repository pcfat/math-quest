import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final achievements = gameState.achievements;
    final unlocked = gameState.unlockedAchievements;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, unlocked.length, achievements.length),
              
              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PixelProgressBar(
                  value: achievements.isEmpty ? 0 : unlocked.length / achievements.length,
                  fillColor: PixelTheme.secondary,
                  height: 20,
                  label: 'PROGRESS',
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Achievements list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    final isUnlocked = unlocked.contains(achievement.id);
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAchievementCard(achievement, isUnlocked),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, int unlocked, int total) {
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
          const Text('🎖️', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text('BADGES', style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.accent)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PixelTheme.secondary.withOpacity(0.2),
              border: Border.all(color: PixelTheme.secondary, width: 2),
            ),
            child: Text(
              '$unlocked / $total',
              style: PixelTheme.pixelText(size: 10, color: PixelTheme.secondary),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementCard(dynamic achievement, bool isUnlocked) {
    return PixelCard(
      borderColor: isUnlocked ? PixelTheme.secondary : PixelTheme.textDim,
      bgColor: isUnlocked ? PixelTheme.secondary.withOpacity(0.1) : PixelTheme.bgMid.withOpacity(0.5),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? PixelTheme.secondary.withOpacity(0.3)
                  : PixelTheme.bgLight,
              border: Border.all(
                color: isUnlocked ? PixelTheme.secondary : PixelTheme.textDim,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                isUnlocked ? achievement.icon : '🔒',
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked ? null : PixelTheme.textDim,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: PixelTheme.pixelText(
                    size: 10,
                    color: isUnlocked ? PixelTheme.textLight : PixelTheme.textDim,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: PixelTheme.pixelText(
                    size: 7,
                    color: isUnlocked ? PixelTheme.textDim : PixelTheme.bgLight,
                  ),
                ),
              ],
            ),
          ),
          
          // Status
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PixelTheme.primary.withOpacity(0.2),
                border: Border.all(color: PixelTheme.primary, width: 2),
              ),
              child: const Text('✓', style: TextStyle(
                fontSize: 16,
                color: PixelTheme.primary,
              )),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.textDim, width: 2),
              ),
              child: Text('?', style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim)),
            ),
        ],
      ),
    );
  }
}
