import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../data/game_state.dart';
import '../models/pet_models.dart';
import '../theme/pixel_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final bool timedMode;
  
  const QuizScreen({super.key, this.timedMode = false});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int? _selectedIndex;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  Timer? _timer;
  late AnimationController _shakeController;
  late AnimationController _attackController;
  bool _showDamage = false;
  int _lastDamage = 0;
  bool _playerTookDamage = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _attackController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    if (widget.timedMode) {
      _startTimer();
    }
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      context.read<GameState>().updateTimer();
      
      final gameState = context.read<GameState>();
      if (gameState.timeRemaining <= 0) {
        timer.cancel();
        _goToResult();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _attackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final question = gameState.currentQuestion;
    final battle = gameState.battleState;
    
    // 檢查戰敗
    if (battle != null && !battle.isPlayerAlive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDefeatDialog();
      });
    }
    
    if (question == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
          child: Center(
            child: Text('NO QUESTIONS', style: PixelTheme.pixelTitle()),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部資訊列
              _buildTopBar(context, gameState),
              
              // 戰鬥區域
              if (battle != null) _buildBattleArea(battle),
              
              // 進度條
              _buildProgressBar(gameState),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 題目卡片
                      _buildQuestionCard(question),
                      
                      const SizedBox(height: 16),
                      
                      // 選項
                      ...List.generate(question.options.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PixelOptionButton(
                            label: ['A', 'B', 'C', 'D'][index],
                            text: question.options[index],
                            isSelected: _selectedIndex == index,
                            isCorrect: question.correctIndex == index,
                            isWrong: _selectedIndex == index && question.correctIndex != index,
                            showResult: _hasAnswered,
                            onTap: _hasAnswered ? null : () => _selectOption(index),
                          ),
                        );
                      }),
                      
                      // 解釋
                      if (_hasAnswered && question.explanation != null) 
                        _buildExplanation(question.explanation!),
                    ],
                  ),
                ),
              ),
              
              // 底部按鈕
              if (_hasAnswered) _buildBottomButton(gameState),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildBattleArea(BattleState battle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PixelTheme.bgMid,
        border: Border.all(color: PixelTheme.textDim, width: 3),
      ),
      child: Row(
        children: [
          // 玩家寵物
          Expanded(
            child: _buildFighter(
              emoji: battle.pet.emoji,
              name: battle.pet.name,
              hp: battle.playerHp,
              maxHp: battle.playerMaxHp,
              isPlayer: true,
              showDamage: _showDamage && _playerTookDamage,
              damage: _lastDamage,
            ),
          ),
          
          // VS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                Text('⚔️', style: const TextStyle(fontSize: 24)),
                Text('VS', style: PixelTheme.pixelText(size: 8, color: PixelTheme.error)),
                if (battle.combo > 0)
                  PixelBadge(
                    text: '${battle.combo}x',
                    color: PixelTheme.secondary,
                    fontSize: 6,
                  ),
              ],
            ),
          ),
          
          // 怪物
          Expanded(
            child: _buildFighter(
              emoji: battle.monster.emoji,
              name: battle.monster.name,
              hp: battle.monsterHp,
              maxHp: battle.monsterMaxHp,
              isPlayer: false,
              showDamage: _showDamage && !_playerTookDamage,
              damage: _lastDamage,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFighter({
    required String emoji,
    required String name,
    required int hp,
    required int maxHp,
    required bool isPlayer,
    required bool showDamage,
    required int damage,
  }) {
    final hpPercent = maxHp > 0 ? hp / maxHp : 0.0;
    final hpColor = hpPercent > 0.5 
        ? PixelTheme.primary 
        : hpPercent > 0.25 
            ? PixelTheme.secondary 
            : PixelTheme.error;
    
    return Column(
      children: [
        // 名稱
        Text(
          name,
          style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // 角色
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _attackController,
              builder: (context, child) {
                final shake = showDamage ? _shakeController.value * 5 : 0.0;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isPlayer 
                      ? PixelTheme.accent.withOpacity(0.2)
                      : PixelTheme.error.withOpacity(0.2),
                  border: Border.all(
                    color: isPlayer ? PixelTheme.accent : PixelTheme.error,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 32)),
                ),
              ),
            ),
            // 傷害數字
            if (showDamage)
              Positioned(
                top: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: -20),
                  duration: const Duration(milliseconds: 500),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: Opacity(
                        opacity: (1 + value / 20).clamp(0, 1),
                        child: Text(
                          '-$damage',
                          style: PixelTheme.pixelText(size: 12, color: PixelTheme.error),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 4),
        
        // HP Bar
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('HP', style: PixelTheme.pixelText(size: 6, color: hpColor)),
                Text('$hp/$maxHp', style: PixelTheme.pixelText(size: 6, color: PixelTheme.textDim)),
              ],
            ),
            const SizedBox(height: 2),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.textDim, width: 1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: hpPercent.clamp(0, 1),
                child: Container(color: hpColor),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTopBar(BuildContext context, GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // 返回按鈕
          GestureDetector(
            onTap: () => _showExitDialog(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PixelTheme.bgMid,
                border: Border.all(color: PixelTheme.error, width: 3),
              ),
              child: const Center(
                child: Text('✕', style: TextStyle(fontSize: 18, color: PixelTheme.error)),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 課題名稱
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: PixelTheme.bgMid,
              border: Border.all(color: PixelTheme.textDim, width: 2),
            ),
            child: Row(
              children: [
                Text(gameState.currentTopic?.icon ?? '', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(gameState.currentTopic?.name ?? '', style: PixelTheme.pixelText(size: 8)),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 計時器 或 分數
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.timedMode ? PixelTheme.error.withOpacity(0.2) : PixelTheme.secondary.withOpacity(0.2),
              border: Border.all(
                color: widget.timedMode ? PixelTheme.error : PixelTheme.secondary,
                width: 3,
              ),
            ),
            child: Row(
              children: [
                Text(widget.timedMode ? '⏱️' : '🪙', style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  widget.timedMode ? '${gameState.timeRemaining}s' : '${gameState.sessionScore}',
                  style: PixelTheme.pixelText(
                    size: 12,
                    color: widget.timedMode ? PixelTheme.error : PixelTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressBar(GameState gameState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STAGE ${gameState.currentQuestionIndex + 1}',
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.accent),
              ),
              Text(
                '${gameState.currentQuestionIndex + 1} / ${gameState.totalQuestions}',
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PixelProgressBar(
            value: (gameState.currentQuestionIndex + 1) / gameState.totalQuestions,
            fillColor: PixelTheme.accent,
            height: 16,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard(question) {
    return PixelCard(
      borderColor: PixelTheme.textLight,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 難度星星
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PixelStars(count: question.difficulty, max: 3),
              const SizedBox(width: 8),
              Text(
                _getDifficultyText(question.difficulty),
                style: PixelTheme.pixelText(size: 8, color: _getDifficultyColor(question.difficulty)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: PixelTheme.pixelText(size: 11, height: 1.8),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Color _getDifficultyColor(int difficulty) {
    switch (difficulty) {
      case 1: return PixelTheme.primary;
      case 2: return PixelTheme.secondary;
      case 3: return PixelTheme.error;
      default: return PixelTheme.textDim;
    }
  }
  
  String _getDifficultyText(int difficulty) {
    switch (difficulty) {
      case 1: return 'EASY';
      case 2: return 'NORMAL';
      case 3: return 'HARD';
      default: return '';
    }
  }
  
  Widget _buildExplanation(String explanation) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: PixelCard(
        borderColor: PixelTheme.accent,
        bgColor: PixelTheme.accent.withOpacity(0.1),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('HINT', style: PixelTheme.pixelText(size: 7, color: PixelTheme.accent)),
                  const SizedBox(height: 6),
                  Text(explanation, style: PixelTheme.pixelText(size: 8, height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBottomButton(GameState gameState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: PixelTheme.bgMid,
        border: Border(top: BorderSide(color: PixelTheme.textDim, width: 3)),
      ),
      child: Row(
        children: [
          // 結果提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _isCorrect ? PixelTheme.success.withOpacity(0.2) : PixelTheme.error.withOpacity(0.2),
              border: Border.all(
                color: _isCorrect ? PixelTheme.success : PixelTheme.error,
                width: 3,
              ),
            ),
            child: Row(
              children: [
                Text(
                  _isCorrect ? '✓' : '✕',
                  style: TextStyle(fontSize: 20, color: _isCorrect ? PixelTheme.success : PixelTheme.error),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCorrect ? 'HIT!' : 'MISS',
                      style: PixelTheme.pixelText(size: 8, color: _isCorrect ? PixelTheme.success : PixelTheme.error),
                    ),
                    if (_isCorrect)
                      Text(
                        '+${10 * (context.read<GameState>().currentQuestion?.difficulty ?? 1)} pts',
                        style: PixelTheme.pixelText(size: 6, color: PixelTheme.secondary),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // 下一題按鈕
          PixelButton(
            text: gameState.isLastQuestion ? 'FINISH' : 'NEXT',
            emoji: gameState.isLastQuestion ? '🏆' : '▶',
            color: PixelTheme.primary,
            width: 130,
            height: 48,
            fontSize: 10,
            onPressed: _nextQuestion,
          ),
        ],
      ),
    );
  }
  
  void _selectOption(int index) {
    final gameState = context.read<GameState>();
    final battle = gameState.battleState;
    
    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
      _isCorrect = gameState.answerQuestion(index);
      
      // 顯示傷害動畫
      if (battle != null) {
        _showDamage = true;
        _playerTookDamage = !_isCorrect;
        _lastDamage = _isCorrect 
            ? (10 + (gameState.currentQuestion?.difficulty ?? 1) * 5 + (gameState.activePet?.attack ?? 0))
            : battle.monster.attack;
        
        _shakeController.forward().then((_) {
          _shakeController.reset();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _showDamage = false);
            }
          });
        });
      }
    });
  }
  
  void _nextQuestion() {
    final gameState = context.read<GameState>();
    
    // 檢查是否戰敗
    if (gameState.isBattleLost) {
      _showDefeatDialog();
      return;
    }
    
    // 檢查是否勝利（怪物血量歸零）
    if (gameState.isBattleWon) {
      gameState.finishQuiz();
      _goToResult();
      return;
    }
    
    if (gameState.isLastQuestion) {
      gameState.finishQuiz();
      _goToResult();
    } else {
      gameState.nextQuestion();
      setState(() {
        _selectedIndex = null;
        _hasAnswered = false;
        _isCorrect = false;
      });
    }
  }
  
  void _goToResult() {
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }
  
  void _showDefeatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelCard(
          borderColor: PixelTheme.error,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('💀', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              Text('DEFEATED', style: PixelTheme.pixelTitle(size: 18, color: PixelTheme.error)),
              const SizedBox(height: 8),
              Text(
                '你的寵物已經倒下...',
                style: PixelTheme.pixelText(size: 9, color: PixelTheme.textDim),
              ),
              const SizedBox(height: 24),
              PixelButton(
                text: 'RETURN',
                color: PixelTheme.error,
                height: 48,
                fontSize: 10,
                onPressed: () {
                  context.read<GameState>().resetQuiz();
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PixelCard(
          borderColor: PixelTheme.error,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EXIT GAME?', style: PixelTheme.pixelTitle(size: 14)),
              const SizedBox(height: 16),
              Text('Progress will be lost!', style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: PixelButton(
                      text: 'STAY',
                      color: PixelTheme.primary,
                      height: 44,
                      fontSize: 8,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PixelButton(
                      text: 'EXIT',
                      color: PixelTheme.error,
                      height: 44,
                      fontSize: 8,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        this.context.read<GameState>().resetQuiz();
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
