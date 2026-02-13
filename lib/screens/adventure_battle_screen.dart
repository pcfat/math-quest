import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../data/questions_data.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'adventure_screen.dart';

class AdventureBattleScreen extends StatefulWidget {
  final Monster monster;
  final int level;
  
  const AdventureBattleScreen({
    super.key,
    required this.monster,
    required this.level,
  });

  @override
  State<AdventureBattleScreen> createState() => _AdventureBattleScreenState();
}

class _AdventureBattleScreenState extends State<AdventureBattleScreen>
    with TickerProviderStateMixin {
  // 戰鬥狀態
  int _monsterHp = 0;
  int _monsterMaxHp = 0;
  int _playerHp = 100;
  int _playerMaxHp = 100;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 3;
  
  // 當前題目
  Map<String, dynamic>? _currentQuestion;
  int? _selectedAnswer;
  bool _showResult = false;
  bool _isCorrect = false;
  bool _battleEnded = false;
  bool _playerWon = false;
  
  // 動畫
  late AnimationController _shakeController;
  late AnimationController _attackController;
  late AnimationController _bounceController;
  bool _monsterShaking = false;
  bool _playerShaking = false;
  
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _attackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    
    _initBattle();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _attackController.dispose();
    _bounceController.dispose();
    super.dispose();
  }
  
  void _initBattle() {
    _monsterMaxHp = widget.level * 30 + 20;
    _monsterHp = _monsterMaxHp;
    _totalQuestions = math.min(3 + widget.level ~/ 2, 5);
    _loadQuestion();
  }
  
  void _loadQuestion() {
    // 隨機選題
    final topics = QuestionsData.allTopics;
    if (topics.isEmpty) return;
    
    final topic = topics[_random.nextInt(topics.length)];
    if (topic.questions.isEmpty) return;
    
    final question = topic.questions[_random.nextInt(topic.questions.length)];
    
    setState(() {
      _currentQuestion = {
        'question': question.question,
        'options': question.options,
        'correctIndex': question.correctIndex,
      };
      _selectedAnswer = null;
      _showResult = false;
    });
  }
  
  void _selectAnswer(int index) {
    if (_showResult || _battleEnded) return;
    
    setState(() {
      _selectedAnswer = index;
    });
  }
  
  void _confirmAnswer() {
    if (_selectedAnswer == null || _showResult || _battleEnded) return;
    
    final correct = _selectedAnswer == _currentQuestion!['correctIndex'];
    
    setState(() {
      _showResult = true;
      _isCorrect = correct;
      
      if (correct) {
        _correctAnswers++;
        // 攻擊怪物
        _monsterShaking = true;
        final damage = 20 + _random.nextInt(15);
        _monsterHp = math.max(0, _monsterHp - damage);
      } else {
        // 怪物攻擊玩家
        _playerShaking = true;
        final damage = 10 + widget.level * 3 + _random.nextInt(10);
        _playerHp = math.max(0, _playerHp - damage);
      }
    });
    
    _shakeController.repeat(reverse: true);
    
    Future.delayed(const Duration(milliseconds: 300), () {
      _shakeController.stop();
      setState(() {
        _monsterShaking = false;
        _playerShaking = false;
      });
    });
    
    // 檢查戰鬥結束
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      if (_monsterHp <= 0) {
        _endBattle(true);
      } else if (_playerHp <= 0) {
        _endBattle(false);
      } else {
        _currentQuestionIndex++;
        if (_currentQuestionIndex >= _totalQuestions) {
          // 題目用完，根據血量判定
          _endBattle(_monsterHp < _monsterMaxHp * 0.5);
        } else {
          _loadQuestion();
        }
      }
    });
  }
  
  void _endBattle(bool won) {
    setState(() {
      _battleEnded = true;
      _playerWon = won;
    });
    
    if (won) {
      // 給予獎勵
      final gameState = context.read<GameState>();
      final expGain = widget.level * 10 + _correctAnswers * 5;
      gameState.addExperience(expGain);
    }
  }
  
  void _exitBattle() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: _battleEnded ? _buildBattleResult() : _buildBattle(),
        ),
      ),
    );
  }
  
  Widget _buildBattle() {
    return Column(
      children: [
        // 怪物區域
        Expanded(
          flex: 2,
          child: _buildMonsterArea(),
        ),
        
        // 題目區域
        Expanded(
          flex: 3,
          child: _buildQuestionArea(),
        ),
        
        // 玩家狀態
        _buildPlayerStatus(),
      ],
    );
  }
  
  Widget _buildMonsterArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 怪物資訊
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.monster.name} Lv.${widget.level}',
                style: PixelTheme.pixelText(size: 12, color: PixelTheme.error),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // 怪物血條
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _buildGradientHealthBar(
              current: _monsterHp,
              max: _monsterMaxHp,
              color: PixelTheme.error,
              emoji: '💀',
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 怪物
          AnimatedBuilder(
            animation: _bounceController,
            builder: (context, child) {
              final bounce = math.sin(_bounceController.value * math.pi) * 5;
              final shake = _monsterShaking 
                  ? math.sin(_shakeController.value * math.pi * 8) * 10 
                  : 0.0;
              return Transform.translate(
                offset: Offset(shake, bounce),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: PixelTheme.codedexCard(
                borderColor: PixelTheme.error,
                borderRadius: 20,
                withGlow: true,
              ),
              child: Text(
                widget.monster.emoji,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionArea() {
    if (_currentQuestion == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 題目
          Container(
            padding: const EdgeInsets.all(16),
            decoration: PixelTheme.codedexCard(
              borderColor: PixelTheme.accent,
            ),
            child: Text(
              _currentQuestion!['question'],
              style: PixelTheme.questionText(size: 18),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 選項
          Expanded(
            child: ListView.builder(
              itemCount: (_currentQuestion!['options'] as List).length,
              itemBuilder: (context, index) {
                final option = _currentQuestion!['options'][index];
                final isSelected = _selectedAnswer == index;
                final isCorrect = index == _currentQuestion!['correctIndex'];
                
                Color borderColor = PixelTheme.textDim;
                Color bgColor = PixelTheme.bgMid;
                
                if (_showResult) {
                  if (isCorrect) {
                    borderColor = PixelTheme.success;
                    bgColor = PixelTheme.success.withOpacity(0.2);
                  } else if (isSelected && !isCorrect) {
                    borderColor = PixelTheme.error;
                    bgColor = PixelTheme.error.withOpacity(0.2);
                  }
                } else if (isSelected) {
                  borderColor = PixelTheme.accent;
                  bgColor = PixelTheme.accent.withOpacity(0.2);
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _selectAnswer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: PixelTheme.codedexCard(
                        color: bgColor,
                        borderColor: borderColor,
                        borderRadius: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: borderColor,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: PixelTheme.pixelText(size: 12, color: PixelTheme.bgDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              option,
                              style: PixelTheme.questionText(size: 16),
                            ),
                          ),
                          if (_showResult && isCorrect)
                            const Text('✓', style: TextStyle(fontSize: 24, color: PixelTheme.success)),
                          if (_showResult && isSelected && !isCorrect)
                            const Text('✗', style: TextStyle(fontSize: 24, color: PixelTheme.error)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // 確認按鈕
          if (!_showResult && _selectedAnswer != null)
            PixelButton(
              text: 'ATTACK!',
              emoji: '⚔️',
              color: PixelTheme.primary,
              onPressed: _confirmAnswer,
            ),
          
          if (_showResult)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _isCorrect ? '✨ 攻擊成功！' : '💥 被反擊了！',
                style: PixelTheme.pixelText(
                  size: 12,
                  color: _isCorrect ? PixelTheme.success : PixelTheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildPlayerStatus() {
    final gameState = context.watch<GameState>();
    
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = _playerShaking 
            ? math.sin(_shakeController.value * math.pi * 8) * 5 
            : 0.0;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PixelTheme.bgMid,
          border: const Border(top: BorderSide(color: PixelTheme.textDim, width: 3)),
        ),
        child: Row(
          children: [
            // 寵物
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PixelTheme.primary, width: 2),
              ),
              child: Text(
                gameState.activePet?.emoji ?? '🧑',
                style: const TextStyle(fontSize: 32),
              ),
            ),
            const SizedBox(width: 12),
            
            // 血量
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gameState.activePet?.name ?? '玩家',
                    style: PixelTheme.pixelText(size: 10, color: PixelTheme.textLight),
                  ),
                  const SizedBox(height: 4),
                  _buildGradientHealthBar(
                    current: _playerHp,
                    max: _playerMaxHp,
                    color: PixelTheme.primary,
                    emoji: '❤️',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBattleResult() {
    final gameState = context.read<GameState>();
    final expGain = _playerWon ? widget.level * 10 + _correctAnswers * 5 : 0;
    
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: PixelTheme.codedexCard(
            borderColor: _playerWon ? PixelTheme.success : PixelTheme.error,
            withGlow: true,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _playerWon ? '🎉' : '💀',
                style: const TextStyle(fontSize: 64),
              ),
              const SizedBox(height: 16),
              Text(
                _playerWon ? 'VICTORY!' : 'DEFEATED',
                style: PixelTheme.pixelTitle(
                  size: 24,
                  color: _playerWon ? PixelTheme.success : PixelTheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _playerWon ? '戰鬥勝利！' : '戰鬥失敗...',
                style: PixelTheme.pixelText(size: 12, color: PixelTheme.textDim),
              ),
              const SizedBox(height: 24),
              
              // 戰鬥統計
              Container(
                padding: const EdgeInsets.all(16),
                decoration: PixelTheme.codedexCard(
                  borderColor: PixelTheme.textDim,
                  borderRadius: 12,
                ),
                child: Column(
                  children: [
                    _buildStatRow('答對題數', '$_correctAnswers / $_totalQuestions'),
                    const SizedBox(height: 8),
                    _buildStatRow('獲得經驗', '+$expGain EXP'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              PixelButton(
                text: 'CONTINUE',
                emoji: '▶️',
                color: PixelTheme.primary,
                onPressed: _exitBattle,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: PixelTheme.pixelText(size: 10, color: PixelTheme.textDim)),
        Text(value, style: PixelTheme.pixelText(size: 10, color: PixelTheme.secondary)),
      ],
    );
  }
  
  Widget _buildGradientHealthBar({
    required int current,
    required int max,
    required Color color,
    required String emoji,
  }) {
    final progress = max > 0 ? current / max : 0.0;
    
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 20,
            decoration: BoxDecoration(
              color: PixelTheme.bgLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.3), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
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
        ),
        const SizedBox(width: 8),
        Text(
          '$current/$max',
          style: PixelTheme.pixelText(size: 8, color: color),
        ),
      ],
    );
  }
}
