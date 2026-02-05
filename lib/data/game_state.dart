import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../models/pet_models.dart';
import 'questions_data.dart';
import 'dart:convert';
import 'dart:math';

class GameState extends ChangeNotifier {
  UserProgress _progress = UserProgress();
  Topic? _currentTopic;
  int _currentQuestionIndex = 0;
  int _sessionScore = 0;
  int _sessionCorrect = 0;
  bool _isQuizActive = false;
  
  // Phase 2: 限時挑戰
  bool _isTimedMode = false;
  int _timeRemaining = 60;
  bool _timerActive = false;
  
  // Phase 2: 每日任務
  DailyMission? _dailyMission;
  DateTime? _lastMissionDate;
  
  // Phase 2: 成就系統
  List<Achievement> _achievements = [];
  List<String> _unlockedAchievements = [];
  
  // Phase 3: 用戶系統
  String _username = '玩家';
  String _avatarEmoji = '😊';
  int _level = 1;
  int _experience = 0;
  String _userGrade = '';  // 用戶年級
  String _questionLanguage = 'zh';  // 題目語言 (zh/en)
  bool _hasChosenGrade = false;
  
  // Phase 4: 寵物系統
  Pet? _activePet;
  List<String> _ownedPetIds = [];
  bool _hasChosenStarterPet = false;
  BattleState? _battleState;
  
  // Getters
  UserProgress get progress => _progress;
  Topic? get currentTopic => _currentTopic;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get sessionScore => _sessionScore;
  int get sessionCorrect => _sessionCorrect;
  bool get isQuizActive => _isQuizActive;
  bool get isTimedMode => _isTimedMode;
  int get timeRemaining => _timeRemaining;
  bool get timerActive => _timerActive;
  DailyMission? get dailyMission => _dailyMission;
  List<Achievement> get achievements => _achievements;
  List<String> get unlockedAchievements => _unlockedAchievements;
  String get username => _username;
  String get avatarEmoji => _avatarEmoji;
  int get level => _level;
  int get experience => _experience;
  int get experienceForNextLevel => level * 100;
  double get levelProgress => experience / experienceForNextLevel;
  String get userGrade => _userGrade;
  String get questionLanguage => _questionLanguage;
  bool get hasChosenGrade => _hasChosenGrade;
  
  // 寵物 Getters
  Pet? get activePet => _activePet;
  List<String> get ownedPetIds => _ownedPetIds;
  bool get hasChosenStarterPet => _hasChosenStarterPet;
  BattleState? get battleState => _battleState;
  
  List<Pet> get ownedPets {
    return PetsData.allPets.where((p) => _ownedPetIds.contains(p.id)).toList();
  }
  
  List<Pet> get lockedPets {
    return PetsData.unlockablePets.where((p) => !_ownedPetIds.contains(p.id)).toList();
  }
  
  Question? get currentQuestion {
    if (_currentTopic == null) return null;
    if (_currentQuestionIndex >= _currentTopic!.questions.length) return null;
    return _currentTopic!.questions[_currentQuestionIndex];
  }
  
  int get totalQuestions => _currentTopic?.questions.length ?? 0;
  bool get isLastQuestion => _currentQuestionIndex >= totalQuestions - 1;
  
  GameState() {
    _initAchievements();
    _loadProgress();
  }
  
  // 選擇初始寵物
  void chooseStarterPet(Pet pet) {
    _activePet = pet;
    _ownedPetIds.add(pet.id);
    _hasChosenStarterPet = true;
    _saveProgress();
    notifyListeners();
  }
  
  // 設置用戶年級
  void setUserGrade(String grade) {
    _userGrade = grade;
    _hasChosenGrade = true;
    _saveProgress();
    notifyListeners();
  }
  
  // 設置題目語言
  void setQuestionLanguage(String language) {
    _questionLanguage = language;
    _saveProgress();
    notifyListeners();
  }
  
  // 設置當前寵物
  void setActivePet(Pet pet) {
    if (_ownedPetIds.contains(pet.id)) {
      _activePet = pet;
      _saveProgress();
      notifyListeners();
    }
  }
  
  // 解鎖寵物
  void unlockPet(String petId) {
    if (!_ownedPetIds.contains(petId)) {
      _ownedPetIds.add(petId);
      _saveProgress();
      notifyListeners();
    }
  }
  
  // 檢查並解鎖寵物
  void _checkPetUnlocks() {
    // 完成 10 次每日任務 -> 不死鳳凰
    if (_progress.dailyMissionsCompleted >= 10) {
      unlockPet('phoenix');
    }
    // 累積 1000 分 -> 獨角獸
    if (_progress.totalScore >= 1000) {
      unlockPet('unicorn');
    }
    // 完成所有課題 -> 幽靈小鬼
    if (_progress.topicAttempts.length >= 6) {
      unlockPet('ghost');
    }
    // 累積 10000 分 -> 黃金神龍
    if (_progress.totalScore >= 10000) {
      unlockPet('golden_dragon');
    }
  }
  
  // 初始化成就
  void _initAchievements() {
    _achievements = [
      Achievement(
        id: 'first_quiz',
        name: '初試啼聲',
        description: '完成第一次測驗',
        icon: '🎯',
        requirement: 1,
        type: AchievementType.quizComplete,
      ),
      Achievement(
        id: 'streak_5',
        name: '連續答對 5 題',
        description: '一次測驗中連續答對 5 題',
        icon: '🔥',
        requirement: 5,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'streak_10',
        name: '十連勝',
        description: '一次測驗中連續答對 10 題',
        icon: '💪',
        requirement: 10,
        type: AchievementType.streak,
      ),
      Achievement(
        id: 'perfect_score',
        name: '完美表現',
        description: '一次測驗全部答對',
        icon: '⭐',
        requirement: 100,
        type: AchievementType.accuracy,
      ),
      Achievement(
        id: 'score_500',
        name: '積分達人',
        description: '累積 500 分',
        icon: '🏆',
        requirement: 500,
        type: AchievementType.totalScore,
      ),
      Achievement(
        id: 'score_1000',
        name: '數學高手',
        description: '累積 1000 分',
        icon: '👑',
        requirement: 1000,
        type: AchievementType.totalScore,
      ),
      Achievement(
        id: 'score_5000',
        name: '數學大師',
        description: '累積 5000 分',
        icon: '🌟',
        requirement: 5000,
        type: AchievementType.totalScore,
      ),
      Achievement(
        id: 'daily_3',
        name: '勤力學習',
        description: '完成 3 次每日任務',
        icon: '📅',
        requirement: 3,
        type: AchievementType.dailyMission,
      ),
      Achievement(
        id: 'all_topics',
        name: '全能選手',
        description: '嘗試所有課題',
        icon: '📚',
        requirement: 6,
        type: AchievementType.topicsPlayed,
      ),
      Achievement(
        id: 'speed_demon',
        name: '閃電快手',
        description: '限時模式得分超過 100',
        icon: '⚡',
        requirement: 100,
        type: AchievementType.timedScore,
      ),
    ];
  }
  
  // 載入進度
  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    _username = prefs.getString('username') ?? '玩家';
    _avatarEmoji = prefs.getString('avatar') ?? '😊';
    _level = prefs.getInt('level') ?? 1;
    _experience = prefs.getInt('experience') ?? 0;
    
    // 載入年級數據
    _hasChosenGrade = prefs.getBool('hasChosenGrade') ?? false;
    _userGrade = prefs.getString('userGrade') ?? '';
    _questionLanguage = prefs.getString('questionLanguage') ?? 'zh';
    
    // 載入寵物數據
    _hasChosenStarterPet = prefs.getBool('hasChosenStarterPet') ?? false;
    _ownedPetIds = prefs.getStringList('ownedPets') ?? [];
    final activePetId = prefs.getString('activePetId');
    if (activePetId != null) {
      _activePet = PetsData.allPets.firstWhere(
        (p) => p.id == activePetId,
        orElse: () => PetsData.starterPets.first,
      );
    }
    
    final progressJson = prefs.getString('progress');
    if (progressJson != null) {
      final data = jsonDecode(progressJson);
      _progress = UserProgress(
        topicScores: Map<String, int>.from(data['topicScores'] ?? {}),
        topicAttempts: Map<String, int>.from(data['topicAttempts'] ?? {}),
        totalScore: data['totalScore'] ?? 0,
        streak: data['streak'] ?? 0,
        quizzesCompleted: data['quizzesCompleted'] ?? 0,
        dailyMissionsCompleted: data['dailyMissionsCompleted'] ?? 0,
      );
    }
    
    _unlockedAchievements = prefs.getStringList('achievements') ?? [];
    
    // 檢查每日任務
    final lastMission = prefs.getString('lastMissionDate');
    if (lastMission != null) {
      _lastMissionDate = DateTime.parse(lastMission);
    }
    _generateDailyMission();
    
    notifyListeners();
  }
  
  // 儲存進度
  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    prefs.setString('username', _username);
    prefs.setString('avatar', _avatarEmoji);
    prefs.setInt('level', _level);
    prefs.setInt('experience', _experience);
    
    // 儲存年級數據
    prefs.setBool('hasChosenGrade', _hasChosenGrade);
    prefs.setString('userGrade', _userGrade);
    prefs.setString('questionLanguage', _questionLanguage);
    
    // 儲存寵物數據
    prefs.setBool('hasChosenStarterPet', _hasChosenStarterPet);
    prefs.setStringList('ownedPets', _ownedPetIds);
    if (_activePet != null) {
      prefs.setString('activePetId', _activePet!.id);
    }
    
    final progressData = {
      'topicScores': _progress.topicScores,
      'topicAttempts': _progress.topicAttempts,
      'totalScore': _progress.totalScore,
      'streak': _progress.streak,
      'quizzesCompleted': _progress.quizzesCompleted,
      'dailyMissionsCompleted': _progress.dailyMissionsCompleted,
    };
    prefs.setString('progress', jsonEncode(progressData));
    
    prefs.setStringList('achievements', _unlockedAchievements);
    
    if (_lastMissionDate != null) {
      prefs.setString('lastMissionDate', _lastMissionDate!.toIso8601String());
    }
  }
  
  // 生成每日任務
  void _generateDailyMission() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastMissionDate != null) {
      final lastDate = DateTime(_lastMissionDate!.year, _lastMissionDate!.month, _lastMissionDate!.day);
      if (lastDate == today && _dailyMission != null) {
        return; // 今日已有任務
      }
    }
    
    final random = Random(today.millisecondsSinceEpoch);
    final topics = QuestionsData.allTopics;
    final selectedTopic = topics[random.nextInt(topics.length)];
    
    final missionTypes = [
      DailyMission(
        id: 'daily_${today.millisecondsSinceEpoch}',
        title: '完成 ${selectedTopic.name} 測驗',
        description: '完成一次 ${selectedTopic.name} 測驗',
        targetTopicId: selectedTopic.id,
        targetScore: 0,
        reward: 50,
        isCompleted: false,
      ),
      DailyMission(
        id: 'daily_${today.millisecondsSinceEpoch}',
        title: '獲得 30 分',
        description: '在任何測驗中獲得至少 30 分',
        targetScore: 30,
        reward: 30,
        isCompleted: false,
      ),
      DailyMission(
        id: 'daily_${today.millisecondsSinceEpoch}',
        title: '答對 3 題',
        description: '在一次測驗中答對至少 3 題',
        targetCorrect: 3,
        reward: 25,
        isCompleted: false,
      ),
    ];
    
    _dailyMission = missionTypes[random.nextInt(missionTypes.length)];
    _lastMissionDate = today;
    _saveProgress();
  }
  
  // 設定用戶資料
  void setUsername(String name) {
    _username = name;
    _saveProgress();
    notifyListeners();
  }
  
  void setAvatar(String emoji) {
    _avatarEmoji = emoji;
    _saveProgress();
    notifyListeners();
  }
  
  // 增加經驗值 (公開方法)
  void addExperience(int exp) {
    _addExperience(exp);
    notifyListeners();
  }
  
  // 增加經驗值 (內部方法)
  void _addExperience(int exp) {
    _experience += exp;
    while (_experience >= experienceForNextLevel) {
      _experience -= experienceForNextLevel;
      _level++;
    }
    _saveProgress();
  }
  
  // 開始測驗 (帶戰鬥系統)
  void startQuiz(Topic topic, {bool timed = false}) {
    // 隨機化題目順序和答案順序
    _currentTopic = topic.shuffled();
    _currentQuestionIndex = 0;
    _sessionScore = 0;
    _sessionCorrect = 0;
    _isQuizActive = true;
    _isTimedMode = timed;
    _timeRemaining = timed ? 60 : 0;
    _timerActive = timed;
    
    // 初始化戰鬥
    if (_activePet != null) {
      final monster = MonstersData.getMonsterForTopic(topic.id);
      _battleState = BattleState(
        pet: _activePet!,
        monster: monster,
        playerHp: 100,
        playerMaxHp: 100,
      );
    }
    
    notifyListeners();
  }
  
  // 更新計時器
  void updateTimer() {
    if (_timerActive && _timeRemaining > 0) {
      _timeRemaining--;
      notifyListeners();
      
      if (_timeRemaining <= 0) {
        _timerActive = false;
        finishQuiz();
      }
    }
  }
  
  // 回答問題 (帶戰鬥)
  bool answerQuestion(int selectedIndex) {
    if (currentQuestion == null) return false;
    
    final isCorrect = currentQuestion!.checkAnswer(selectedIndex);
    if (isCorrect) {
      int points = 10 * currentQuestion!.difficulty;
      if (_isTimedMode) {
        points = (points * 1.5).round();
      }
      _sessionScore += points;
      _sessionCorrect++;
      _progress.streak++;
      
      // 戰鬥：攻擊怪物
      if (_battleState != null) {
        final damage = 10 + currentQuestion!.difficulty * 5 + (_activePet?.attack ?? 0);
        _battleState!.attackMonster(damage);
      }
      
      _checkAchievement(AchievementType.streak, _progress.streak);
    } else {
      _progress.streak = 0;
      
      // 戰鬥：怪物攻擊玩家
      if (_battleState != null) {
        _battleState!.attackPlayer();
      }
    }
    
    notifyListeners();
    return isCorrect;
  }
  
  // 檢查是否戰敗
  bool get isBattleLost => _battleState != null && !_battleState!.isPlayerAlive;
  bool get isBattleWon => _battleState != null && !_battleState!.isMonsterAlive;
  
  // 下一題
  void nextQuestion() {
    _currentQuestionIndex++;
    notifyListeners();
  }
  
  // 完成測驗
  void finishQuiz() {
    if (_currentTopic != null) {
      _progress.updateScore(_currentTopic!.id, _sessionScore);
      _progress.quizzesCompleted++;
      
      _addExperience(_sessionScore ~/ 2);
      
      _checkAchievement(AchievementType.quizComplete, _progress.quizzesCompleted);
      _checkAchievement(AchievementType.totalScore, _progress.totalScore);
      _checkAchievement(AchievementType.topicsPlayed, _progress.topicAttempts.length);
      
      if (_sessionCorrect == totalQuestions && totalQuestions > 0) {
        _checkAchievement(AchievementType.accuracy, 100);
      }
      
      if (_isTimedMode) {
        _checkAchievement(AchievementType.timedScore, _sessionScore);
      }
      
      _checkDailyMission();
      _checkPetUnlocks();
      
      _saveProgress();
    }
    _isQuizActive = false;
    _timerActive = false;
    notifyListeners();
  }
  
  // 檢查每日任務
  void _checkDailyMission() {
    if (_dailyMission == null || _dailyMission!.isCompleted) return;
    
    bool completed = false;
    
    if (_dailyMission!.targetTopicId != null) {
      completed = _currentTopic?.id == _dailyMission!.targetTopicId;
    } else if (_dailyMission!.targetScore != null && _dailyMission!.targetScore! > 0) {
      completed = _sessionScore >= _dailyMission!.targetScore!;
    } else if (_dailyMission!.targetCorrect != null) {
      completed = _sessionCorrect >= _dailyMission!.targetCorrect!;
    }
    
    if (completed) {
      _dailyMission = _dailyMission!.copyWith(isCompleted: true);
      _progress.totalScore += _dailyMission!.reward;
      _progress.dailyMissionsCompleted++;
      _addExperience(_dailyMission!.reward);
      _checkAchievement(AchievementType.dailyMission, _progress.dailyMissionsCompleted);
    }
  }
  
  // 檢查成就
  void _checkAchievement(AchievementType type, int value) {
    for (final achievement in _achievements) {
      if (achievement.type == type && 
          value >= achievement.requirement &&
          !_unlockedAchievements.contains(achievement.id)) {
        _unlockedAchievements.add(achievement.id);
        _addExperience(50);
      }
    }
  }
  
  // 重置測驗
  void resetQuiz() {
    _currentTopic = null;
    _currentQuestionIndex = 0;
    _sessionScore = 0;
    _sessionCorrect = 0;
    _isQuizActive = false;
    _isTimedMode = false;
    _timerActive = false;
    _battleState = null;
    notifyListeners();
  }
  
  // 獲取所有課題
  List<Topic> get allTopics => QuestionsData.allTopics;
  List<Topic> get juniorTopics => QuestionsData.juniorTopics;
  List<Topic> get seniorTopics => QuestionsData.seniorTopics;
  
  // 排行榜數據 (模擬)
  List<LeaderboardEntry> get leaderboard {
    final entries = [
      LeaderboardEntry(rank: 1, name: '數學王子', score: 9999, avatar: '👑'),
      LeaderboardEntry(rank: 2, name: '計算達人', score: 8888, avatar: '🧮'),
      LeaderboardEntry(rank: 3, name: '公式大師', score: 7777, avatar: '📐'),
      LeaderboardEntry(rank: 4, name: '邏輯高手', score: 6666, avatar: '🧠'),
      LeaderboardEntry(rank: 5, name: '數字精靈', score: 5555, avatar: '✨'),
    ];
    
    int playerRank = 6;
    for (int i = 0; i < entries.length; i++) {
      if (_progress.totalScore > entries[i].score) {
        playerRank = i + 1;
        break;
      }
    }
    
    entries.insert(
      playerRank - 1,
      LeaderboardEntry(
        rank: playerRank,
        name: _username,
        score: _progress.totalScore,
        avatar: _avatarEmoji,
        isCurrentUser: true,
      ),
    );
    
    for (int i = 0; i < entries.length; i++) {
      entries[i] = entries[i].copyWith(rank: i + 1);
    }
    
    return entries.take(10).toList();
  }
}
