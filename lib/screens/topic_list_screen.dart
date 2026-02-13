import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'quiz_screen.dart';

class TopicListScreen extends StatelessWidget {
  final String grade;
  final bool timedMode;
  
  const TopicListScreen({
    super.key, 
    required this.grade,
    this.timedMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final topics = grade == 'junior' 
        ? gameState.juniorTopics 
        : gameState.seniorTopics;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部欄
              _buildHeader(context),
              
              // 課題列表
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final attempts = gameState.progress.topicAttempts[topic.id] ?? 0;
                    final bestScore = gameState.progress.topicBestScores[topic.id] ?? 0;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildTopicCard(context, topic, attempts, bestScore),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade == 'junior' ? 'JUNIOR' : 'SENIOR',
                  style: PixelTheme.pixelTitle(
                    size: 16,
                    color: grade == 'junior' ? PixelTheme.primary : PixelTheme.accent,
                  ),
                ),
                Text(
                  grade == 'junior' ? '初中數學' : '高中數學',
                  style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
                ),
              ],
            ),
          ),
          if (timedMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PixelTheme.error, Color(0xFFFF4444)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: PixelTheme.error.withOpacity(0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Text(
                '⏱️ TIMED',
                style: PixelTheme.pixelText(size: 6, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildTopicCard(BuildContext context, topic, int attempts, int bestScore) {
    final maxScore = topic.questions.length * 30;
    final progress = attempts > 0 ? (bestScore / maxScore).clamp(0.0, 1.0) : 0.0;
    final earnedStars = bestScore >= maxScore * 0.9 ? 3 
                      : bestScore >= maxScore * 0.7 ? 2
                      : bestScore > 0 ? 1 : 0;
    
    return QuestCard(
      emoji: topic.icon,
      title: topic.name,
      subtitle: '${topic.nameEn.toUpperCase()} • ${topic.questions.length} 題目',
      progress: progress,
      earnedStars: earnedStars,
      totalStars: 3,
      accentColor: Color(topic.color),
      onTap: () => _startQuiz(context, topic),
    );
  }
  
  void _startQuiz(BuildContext context, topic) {
    context.read<GameState>().startQuiz(topic, timed: timedMode);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(timedMode: timedMode),
      ),
    );
  }
}
