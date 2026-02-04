import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import 'topic_list_screen.dart';

class DailyMissionScreen extends StatelessWidget {
  const DailyMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final mission = gameState.dailyMission;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Date banner
                      _buildDateBanner(),
                      
                      const SizedBox(height: 24),
                      
                      // Mission card
                      if (mission != null)
                        _buildMissionCard(context, gameState, mission),
                      
                      const SizedBox(height: 24),
                      
                      // Stats
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
          const Text('📋', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text('DAILY', style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.secondary)),
        ],
      ),
    );
  }
  
  Widget _buildDateBanner() {
    final now = DateTime.now();
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    
    return PixelCard(
      borderColor: PixelTheme.accent,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}',
                style: PixelTheme.pixelText(size: 12),
              ),
              Text(
                weekdays[now.weekday - 1],
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildMissionCard(BuildContext context, GameState gameState, dynamic mission) {
    return PixelCard(
      borderColor: mission.isCompleted ? PixelTheme.primary : PixelTheme.secondary,
      child: Column(
        children: [
          // Status icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: mission.isCompleted
                    ? [PixelTheme.primary, PixelTheme.primary.withOpacity(0.6)]
                    : [PixelTheme.secondary, PixelTheme.secondary.withOpacity(0.6)],
              ),
              border: Border.all(color: Colors.black54, width: 3),
            ),
            child: Center(
              child: Text(
                mission.isCompleted ? '✓' : '🎯',
                style: const TextStyle(fontSize: 40),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Mission title
          Text(
            mission.title,
            style: PixelTheme.pixelText(size: 12),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            mission.description,
            style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 20),
          
          // Reward
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: PixelTheme.secondary.withOpacity(0.2),
              border: Border.all(color: PixelTheme.secondary, width: 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '+${mission.reward}',
                  style: PixelTheme.pixelText(size: 12, color: PixelTheme.secondary),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action button
          if (mission.isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: PixelTheme.primary.withOpacity(0.2),
                border: Border.all(color: PixelTheme.primary, width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('✓', style: TextStyle(fontSize: 20, color: PixelTheme.primary)),
                  const SizedBox(width: 8),
                  Text(
                    'COMPLETED',
                    style: PixelTheme.pixelText(size: 10, color: PixelTheme.primary),
                  ),
                ],
              ),
            )
          else
            PixelButton(
              text: 'START',
              emoji: '▶',
              color: PixelTheme.primary,
              width: 180,
              height: 50,
              fontSize: 10,
              onPressed: () => _goToQuiz(context, gameState),
            ),
        ],
      ),
    );
  }
  
  Widget _buildStatsCard(GameState gameState) {
    return PixelCard(
      borderColor: PixelTheme.accent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('📅', '${gameState.progress.dailyMissionsCompleted}', 'TOTAL'),
          Container(
            width: 2,
            height: 50,
            color: PixelTheme.textDim,
          ),
          _buildStatItem('🔥', '${gameState.progress.streak}', 'STREAK'),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(value, style: PixelTheme.pixelText(size: 16)),
        Text(label, style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim)),
      ],
    );
  }
  
  void _goToQuiz(BuildContext context, GameState gameState) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TopicListScreen(grade: 'junior'),
      ),
    );
  }
}
