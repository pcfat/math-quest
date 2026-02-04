import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final leaderboard = gameState.leaderboard;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context),
              
              // Top 3 podium
              if (leaderboard.length >= 3)
                _buildPodium(leaderboard),
              
              // Rest of the list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index + 3];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildRankItem(entry),
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
          const Text('🏆', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text('RANKING', style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.secondary)),
        ],
      ),
    );
  }
  
  Widget _buildPodium(List<dynamic> leaderboard) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          _buildPodiumPlace(leaderboard[1], 2, 100),
          const SizedBox(width: 8),
          // 1st place
          _buildPodiumPlace(leaderboard[0], 1, 130),
          const SizedBox(width: 8),
          // 3rd place
          _buildPodiumPlace(leaderboard[2], 3, 80),
        ],
      ),
    );
  }
  
  Widget _buildPodiumPlace(dynamic entry, int rank, double height) {
    final colors = {
      1: PixelTheme.secondary,
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};
    
    return Column(
      children: [
        // Avatar
        Container(
          width: rank == 1 ? 64 : 52,
          height: rank == 1 ? 64 : 52,
          decoration: BoxDecoration(
            color: PixelTheme.bgMid,
            border: Border.all(color: colors[rank]!, width: 3),
          ),
          child: Center(
            child: Text(entry.avatar, style: TextStyle(fontSize: rank == 1 ? 32 : 24)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          entry.name,
          style: PixelTheme.pixelText(size: 7),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${entry.score}',
          style: PixelTheme.pixelText(size: 8, color: colors[rank]!),
        ),
        const SizedBox(height: 4),
        // Podium
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [colors[rank]!, colors[rank]!.withOpacity(0.6)],
            ),
            border: Border.all(color: Colors.black54, width: 3),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Text(medals[rank]!, style: const TextStyle(fontSize: 24)),
              Text(
                '$rank',
                style: PixelTheme.pixelText(size: 16, color: PixelTheme.bgDark),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildRankItem(dynamic entry) {
    return PixelCard(
      borderColor: entry.isCurrentUser ? PixelTheme.primary : PixelTheme.textDim,
      bgColor: entry.isCurrentUser ? PixelTheme.primary.withOpacity(0.1) : null,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: PixelTheme.bgLight,
              border: Border.all(color: PixelTheme.textDim, width: 2),
            ),
            child: Center(
              child: Text(
                '${entry.rank}',
                style: PixelTheme.pixelText(size: 10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PixelTheme.bgLight,
              border: Border.all(color: PixelTheme.textDim, width: 2),
            ),
            child: Center(
              child: Text(entry.avatar, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: PixelTheme.pixelText(size: 9),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 8),
                      PixelBadge(text: 'YOU', fontSize: 5, color: PixelTheme.primary),
                    ],
                  ],
                ),
                Text(
                  '${entry.score} pts',
                  style: PixelTheme.pixelText(size: 7, color: PixelTheme.secondary),
                ),
              ],
            ),
          ),
          const Text('🏆', style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
