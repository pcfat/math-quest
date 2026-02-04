import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
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
            PixelBadge(
              text: '⏱️ TIMED',
              color: PixelTheme.error,
              fontSize: 6,
            ),
        ],
      ),
    );
  }
  
  Widget _buildTopicCard(BuildContext context, topic, int attempts, int bestScore) {
    return GestureDetector(
      onTap: () => _startQuiz(context, topic),
      child: PixelCard(
        borderColor: Color(topic.color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 課題圖標
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Color(topic.color).withOpacity(0.2),
                    border: Border.all(color: Color(topic.color), width: 3),
                  ),
                  child: Center(
                    child: Text(topic.icon, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // 課題資訊
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.name,
                        style: PixelTheme.pixelText(
                          size: 12,
                          color: Color(topic.color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topic.nameEn.toUpperCase(),
                        style: PixelTheme.pixelText(
                          size: 8,
                          color: PixelTheme.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 進入箭頭
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Color(topic.color),
                    border: Border(
                      right: const BorderSide(color: Colors.black54, width: 3),
                      bottom: const BorderSide(color: Colors.black54, width: 3),
                    ),
                  ),
                  child: const Center(
                    child: Text('▶', style: TextStyle(
                      fontSize: 16,
                      color: PixelTheme.bgDark,
                    )),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 統計資料
            Row(
              children: [
                _buildStatItem('📊', '$attempts', '挑戰'),
                const SizedBox(width: 24),
                _buildStatItem('🏆', '$bestScore', '最高分'),
                const SizedBox(width: 24),
                _buildStatItem('📝', '${topic.questions.length}', '題目'),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // 進度條
            PixelProgressBar(
              value: attempts > 0 ? (bestScore / (topic.questions.length * 30)).clamp(0, 1) : 0,
              fillColor: Color(topic.color),
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String emoji, String value, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: PixelTheme.pixelText(size: 10)),
            Text(label, style: PixelTheme.pixelText(size: 6, color: PixelTheme.textDim)),
          ],
        ),
      ],
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
