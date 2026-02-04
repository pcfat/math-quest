import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../data/game_state.dart';
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
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final question = gameState.currentQuestion;
    
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
                      
                      const SizedBox(height: 20),
                      
                      // 選項
                      ...List.generate(question.options.length, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
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
                child: Text('✕', style: TextStyle(
                  fontSize: 18,
                  color: PixelTheme.error,
                )),
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
                Text(
                  gameState.currentTopic?.icon ?? '',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(
                  gameState.currentTopic?.name ?? '',
                  style: PixelTheme.pixelText(size: 8),
                ),
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
                Text(
                  widget.timedMode ? '⏱️' : '🪙',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.timedMode 
                      ? '${gameState.timeRemaining}s'
                      : '${gameState.sessionScore}',
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
          const SizedBox(height: 8),
          PixelProgressBar(
            value: (gameState.currentQuestionIndex + 1) / gameState.totalQuestions,
            fillColor: PixelTheme.accent,
            height: 20,
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuestionCard(question) {
    return PixelCard(
      borderColor: PixelTheme.textLight,
      padding: const EdgeInsets.all(20),
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
                style: PixelTheme.pixelText(
                  size: 8,
                  color: _getDifficultyColor(question.difficulty),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 題目文字
          Text(
            question.question,
            style: PixelTheme.pixelText(size: 12, height: 2),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HINT',
                    style: PixelTheme.pixelText(size: 8, color: PixelTheme.accent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    explanation,
                    style: PixelTheme.pixelText(size: 9, height: 1.8),
                  ),
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
                  style: TextStyle(
                    fontSize: 20,
                    color: _isCorrect ? PixelTheme.success : PixelTheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isCorrect ? 'CORRECT!' : 'WRONG',
                      style: PixelTheme.pixelText(
                        size: 8,
                        color: _isCorrect ? PixelTheme.success : PixelTheme.error,
                      ),
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
            text: gameState.isLastQuestion ? 'RESULT' : 'NEXT',
            emoji: gameState.isLastQuestion ? '🏆' : '▶',
            color: PixelTheme.primary,
            width: 140,
            height: 50,
            fontSize: 10,
            onPressed: _nextQuestion,
          ),
        ],
      ),
    );
  }
  
  void _selectOption(int index) {
    final gameState = context.read<GameState>();
    
    setState(() {
      _selectedIndex = index;
      _hasAnswered = true;
      _isCorrect = gameState.answerQuestion(index);
    });
    
    if (!_isCorrect) {
      _shakeController.forward().then((_) => _shakeController.reset());
    }
  }
  
  void _nextQuestion() {
    final gameState = context.read<GameState>();
    
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
              Text(
                'Progress will be lost!',
                style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
              ),
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
