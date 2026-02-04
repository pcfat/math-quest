/// 題目模型
class Question {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final int difficulty; // 1-3

  const Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
    this.difficulty = 1,
  });

  bool checkAnswer(int selectedIndex) => selectedIndex == correctIndex;
  
  String get correctAnswer => options[correctIndex];
}

/// 課題模型
class Topic {
  final String id;
  final String name;
  final String nameEn;
  final String icon;
  final String grade; // 'junior' or 'senior'
  final List<Question> questions;
  final int color; // 顏色值

  const Topic({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.icon,
    required this.grade,
    required this.questions,
    this.color = 0xFF4CAF50,
  });

  int get totalQuestions => questions.length;
}

/// 用戶進度
class UserProgress {
  final Map<String, int> topicScores; // topicId -> best score
  final Map<String, int> topicBestScores; // topicId -> best score (alias)
  final Map<String, int> topicAttempts; // topicId -> attempts
  int totalScore;
  int streak; // 連續答對
  int quizzesCompleted;
  int dailyMissionsCompleted;
  
  UserProgress({
    Map<String, int>? topicScores,
    Map<String, int>? topicAttempts,
    this.totalScore = 0,
    this.streak = 0,
    this.quizzesCompleted = 0,
    this.dailyMissionsCompleted = 0,
  }) : topicScores = topicScores ?? {},
       topicBestScores = topicScores ?? {},
       topicAttempts = topicAttempts ?? {};

  void updateScore(String topicId, int score) {
    final current = topicScores[topicId] ?? 0;
    if (score > current) {
      topicScores[topicId] = score;
    }
    topicAttempts[topicId] = (topicAttempts[topicId] ?? 0) + 1;
    totalScore += score;
  }
}

/// 每日任務
class DailyMission {
  final String id;
  final String title;
  final String description;
  final String? targetTopicId;
  final int? targetScore;
  final int? targetCorrect;
  final int reward;
  final bool isCompleted;

  const DailyMission({
    required this.id,
    required this.title,
    required this.description,
    this.targetTopicId,
    this.targetScore,
    this.targetCorrect,
    required this.reward,
    required this.isCompleted,
  });

  DailyMission copyWith({
    String? id,
    String? title,
    String? description,
    String? targetTopicId,
    int? targetScore,
    int? targetCorrect,
    int? reward,
    bool? isCompleted,
  }) {
    return DailyMission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetTopicId: targetTopicId ?? this.targetTopicId,
      targetScore: targetScore ?? this.targetScore,
      targetCorrect: targetCorrect ?? this.targetCorrect,
      reward: reward ?? this.reward,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// 成就類型
enum AchievementType {
  quizComplete,
  streak,
  accuracy,
  totalScore,
  dailyMission,
  topicsPlayed,
  timedScore,
}

/// 成就
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requirement;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.type,
  });
}

/// 排行榜條目
class LeaderboardEntry {
  final int rank;
  final String name;
  final int score;
  final String avatar;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatar,
    this.isCurrentUser = false,
  });

  LeaderboardEntry copyWith({
    int? rank,
    String? name,
    int? score,
    String? avatar,
    bool? isCurrentUser,
  }) {
    return LeaderboardEntry(
      rank: rank ?? this.rank,
      name: name ?? this.name,
      score: score ?? this.score,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }
}
