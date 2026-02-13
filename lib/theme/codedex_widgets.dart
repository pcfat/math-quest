import 'package:flutter/material.dart';
import 'pixel_theme.dart';

/// Quest 課題選擇卡片
class QuestCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final double progress; // 0.0 - 1.0
  final int earnedStars;
  final int totalStars;
  final Color accentColor;
  final VoidCallback? onTap;
  final bool isLocked;

  const QuestCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.progress = 0.0,
    this.earnedStars = 0,
    this.totalStars = 3,
    this.accentColor = PixelTheme.primary,
    this.onTap,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: PixelTheme.questCard(
          accentColor: accentColor,
          isCompleted: progress >= 1.0,
          isLocked: isLocked,
        ),
        child: Row(
          children: [
            // 左側: 圓角 emoji 圖標框
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isLocked 
                    ? [PixelTheme.bgLight, PixelTheme.bgMid]
                    : [accentColor.withOpacity(0.2), accentColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLocked ? PixelTheme.textMuted : accentColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  isLocked ? '🔒' : emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // 中間: 標題 + 副標題 + 進度條
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: PixelTheme.pixelText(
                      size: 10,
                      color: isLocked ? PixelTheme.textDim : PixelTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: PixelTheme.modernText(
                      size: 12,
                      color: PixelTheme.textDim,
                    ),
                  ),
                  if (!isLocked) ...[
                    const SizedBox(height: 8),
                    // 進度條
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: PixelTheme.bgLight,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 右側: 星星評級
            if (!isLocked)
              Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(totalStars, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1),
                        child: Text(
                          i < earnedStars ? '★' : '☆',
                          style: TextStyle(
                            fontSize: 16,
                            color: i < earnedStars 
                              ? PixelTheme.secondary 
                              : PixelTheme.textMuted,
                            shadows: i < earnedStars ? [
                              Shadow(
                                color: PixelTheme.secondary.withOpacity(0.6),
                                blurRadius: 8,
                              ),
                            ] : null,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: PixelTheme.modernText(
                      size: 10,
                      color: PixelTheme.textDim,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// 統計數字徽章
class StatBadge extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final Color? glowColor;

  const StatBadge({
    super.key,
    required this.emoji,
    required this.value,
    this.label = '',
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [PixelTheme.bgCard, PixelTheme.bgMid],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (glowColor ?? PixelTheme.textMuted).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: glowColor != null ? [
          BoxShadow(
            color: glowColor!.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: PixelTheme.pixelText(
                  size: 10,
                  color: PixelTheme.textLight,
                ),
              ),
              if (label.isNotEmpty)
                Text(
                  label,
                  style: PixelTheme.modernText(
                    size: 8,
                    color: PixelTheme.textDim,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// XP 經驗值進度條
class XpProgressBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpToNextLevel;
  final Color levelColor;

  const XpProgressBar({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpToNextLevel,
    this.levelColor = PixelTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpToNextLevel > 0 ? currentXp / xpToNextLevel : 1.0;
    
    return Row(
      children: [
        // 左側等級徽章
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                levelColor,
                levelColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: levelColor.withOpacity(0.5),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LV',
                style: PixelTheme.pixelText(
                  size: 6,
                  color: Colors.white,
                ),
              ),
              Text(
                '$level',
                style: PixelTheme.pixelText(
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // 右側進度條
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EXPERIENCE',
                    style: PixelTheme.pixelText(
                      size: 8,
                      color: PixelTheme.textDim,
                    ),
                  ),
                  Text(
                    '$currentXp / $xpToNextLevel XP',
                    style: PixelTheme.modernText(
                      size: 10,
                      color: levelColor,
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: PixelTheme.bgLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [levelColor, levelColor.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: levelColor.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 連續天數火焰標記
class StreakBadge extends StatelessWidget {
  final int days;
  final bool isActive;

  const StreakBadge({
    super.key,
    required this.days,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: isActive
          ? const LinearGradient(
              colors: [PixelTheme.pink, PixelTheme.orange],
            )
          : const LinearGradient(
              colors: [PixelTheme.bgMid, PixelTheme.bgLight],
            ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? [
          BoxShadow(
            color: PixelTheme.orange.withOpacity(0.5),
            blurRadius: 16,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isActive ? '🔥' : '💨',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            '$days',
            style: PixelTheme.pixelText(
              size: 12,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'DAY${days != 1 ? 'S' : ''}',
            style: PixelTheme.pixelText(
              size: 6,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
