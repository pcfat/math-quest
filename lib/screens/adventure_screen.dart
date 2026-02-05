import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../data/game_state.dart';
import '../theme/pixel_theme.dart';
import 'adventure_battle_screen.dart';

class AdventureScreen extends StatefulWidget {
  const AdventureScreen({super.key});

  @override
  State<AdventureScreen> createState() => _AdventureScreenState();
}

class _AdventureScreenState extends State<AdventureScreen>
    with TickerProviderStateMixin {
  // 玩家位置
  double _playerX = 150;
  double _playerY = 200;
  int _playerDirection = 0; // 0=下, 1=左, 2=右, 3=上
  bool _isMoving = false;
  
  // 地圖設定
  final double _mapWidth = 400;
  final double _mapHeight = 500;
  final double _playerSize = 40;
  final double _moveSpeed = 5;
  
  // 遭遇戰
  int _steps = 0;
  int _stepsToEncounter = 0;
  final math.Random _random = math.Random();
  
  // 動畫
  late AnimationController _walkController;
  late AnimationController _encounterController;
  bool _showEncounter = false;
  
  // 地圖區域
  final List<MapArea> _areas = [
    MapArea(name: '操場', emoji: '🏃', x: 50, y: 50, width: 120, height: 100, color: Color(0xFF4a7c59)),
    MapArea(name: '課室A', emoji: '📚', x: 200, y: 50, width: 80, height: 80, color: Color(0xFF8b7355)),
    MapArea(name: '課室B', emoji: '📖', x: 300, y: 50, width: 80, height: 80, color: Color(0xFF8b7355)),
    MapArea(name: '圖書館', emoji: '📕', x: 50, y: 180, width: 100, height: 80, color: Color(0xFF6b5344)),
    MapArea(name: '食堂', emoji: '🍜', x: 200, y: 180, width: 100, height: 80, color: Color(0xFFc4a35a)),
    MapArea(name: '實驗室', emoji: '🔬', x: 50, y: 300, width: 100, height: 80, color: Color(0xFF5a7a8a)),
    MapArea(name: '禮堂', emoji: '🎭', x: 180, y: 300, width: 140, height: 100, color: Color(0xFF7a5a6a)),
    MapArea(name: '校門', emoji: '🚪', x: 150, y: 420, width: 100, height: 60, color: Color(0xFF555555)),
  ];
  
  // 怪物列表
  final List<Monster> _monsters = [
    Monster(name: '數字小妖', emoji: '👾', minLevel: 1, maxLevel: 3),
    Monster(name: '算式幽靈', emoji: '👻', minLevel: 2, maxLevel: 5),
    Monster(name: '分數惡魔', emoji: '😈', minLevel: 3, maxLevel: 6),
    Monster(name: '方程怪獸', emoji: '🐲', minLevel: 4, maxLevel: 8),
    Monster(name: '幾何巨人', emoji: '🗿', minLevel: 5, maxLevel: 10),
  ];

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..repeat(reverse: true);
    
    _encounterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _resetEncounterSteps();
  }

  @override
  void dispose() {
    _walkController.dispose();
    _encounterController.dispose();
    super.dispose();
  }
  
  void _resetEncounterSteps() {
    _stepsToEncounter = _random.nextInt(15) + 10; // 10-25 步遇敵
    _steps = 0;
  }
  
  void _checkEncounter() {
    if (_steps >= _stepsToEncounter) {
      _triggerEncounter();
    }
  }
  
  void _triggerEncounter() {
    setState(() => _showEncounter = true);
    _encounterController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final monster = _monsters[_random.nextInt(_monsters.length)];
        final level = _random.nextInt(monster.maxLevel - monster.minLevel + 1) + monster.minLevel;
        
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AdventureBattleScreen(
              monster: monster,
              level: level,
            ),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        ).then((_) {
          setState(() => _showEncounter = false);
          _resetEncounterSteps();
        });
      }
    });
  }
  
  void _move(int direction) {
    setState(() {
      _playerDirection = direction;
      _isMoving = true;
      
      double newX = _playerX;
      double newY = _playerY;
      
      switch (direction) {
        case 0: newY += _moveSpeed; break; // 下
        case 1: newX -= _moveSpeed; break; // 左
        case 2: newX += _moveSpeed; break; // 右
        case 3: newY -= _moveSpeed; break; // 上
      }
      
      // 邊界檢查
      if (newX >= 0 && newX <= _mapWidth - _playerSize) _playerX = newX;
      if (newY >= 0 && newY <= _mapHeight - _playerSize) _playerY = newY;
      
      _steps++;
      _checkEncounter();
    });
  }
  
  void _stopMoving() {
    setState(() => _isMoving = false);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // 頂部資訊欄
                  _buildTopBar(gameState),
                  
                  // 地圖區域
                  Expanded(
                    child: Center(
                      child: _buildMap(),
                    ),
                  ),
                  
                  // 控制器
                  _buildController(),
                ],
              ),
              
              // 遭遇效果
              if (_showEncounter) _buildEncounterEffect(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTopBar(GameState gameState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PixelTheme.bgMid,
        border: const Border(bottom: BorderSide(color: PixelTheme.textDim, width: 3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.textDim, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: PixelTheme.textLight, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Text('🗺️', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Text(
            'ADVENTURE',
            style: PixelTheme.pixelTitle(size: 16, color: PixelTheme.secondary),
          ),
          const Spacer(),
          // 寵物顯示
          if (gameState.activePet != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.primary, width: 2),
              ),
              child: Row(
                children: [
                  Text(gameState.activePet!.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(
                    'Lv.${gameState.level}',
                    style: PixelTheme.pixelText(size: 8, color: PixelTheme.primary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildMap() {
    return Container(
      width: _mapWidth,
      height: _mapHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF3d5a3d),
        border: Border.all(color: PixelTheme.textDim, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 地圖區域
          ..._areas.map((area) => Positioned(
            left: area.x,
            top: area.y,
            child: _buildArea(area),
          )),
          
          // 玩家
          AnimatedPositioned(
            left: _playerX,
            top: _playerY,
            duration: const Duration(milliseconds: 100),
            child: _buildPlayer(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildArea(MapArea area) {
    return Container(
      width: area.width,
      height: area.height,
      decoration: BoxDecoration(
        color: area.color,
        border: Border.all(color: Colors.black.withOpacity(0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(area.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(
            area.name,
            style: PixelTheme.pixelText(size: 6, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlayer() {
    final gameState = context.read<GameState>();
    final petEmoji = gameState.activePet?.emoji ?? '🧑';
    
    return AnimatedBuilder(
      animation: _walkController,
      builder: (context, child) {
        final bounce = _isMoving ? math.sin(_walkController.value * math.pi * 2) * 3 : 0.0;
        return Transform.translate(
          offset: Offset(0, bounce),
          child: child,
        );
      },
      child: Container(
        width: _playerSize,
        height: _playerSize,
        decoration: BoxDecoration(
          color: PixelTheme.bgMid,
          border: Border.all(color: PixelTheme.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: PixelTheme.primary.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(petEmoji, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
  
  Widget _buildController() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 提示
          Text(
            '步數: $_steps / $_stepsToEncounter',
            style: PixelTheme.pixelText(size: 8, color: PixelTheme.textDim),
          ),
          const SizedBox(height: 16),
          
          // 方向鍵
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 70),
              _buildDPadButton('▲', 3),
              const SizedBox(width: 70),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDPadButton('◀', 1),
              const SizedBox(width: 50),
              _buildDPadButton('▶', 2),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 70),
              _buildDPadButton('▼', 0),
              const SizedBox(width: 70),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDPadButton(String label, int direction) {
    return GestureDetector(
      onTapDown: (_) => _move(direction),
      onTapUp: (_) => _stopMoving(),
      onTapCancel: _stopMoving,
      onLongPress: () {
        // 長按連續移動
        Future.doWhile(() async {
          if (!mounted) return false;
          _move(direction);
          await Future.delayed(const Duration(milliseconds: 100));
          return _isMoving;
        });
      },
      onLongPressEnd: (_) => _stopMoving(),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: PixelTheme.bgMid,
          border: Border.all(color: PixelTheme.accent, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: PixelTheme.accent.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: PixelTheme.pixelText(size: 20, color: PixelTheme.accent),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEncounterEffect() {
    return AnimatedBuilder(
      animation: _encounterController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withOpacity(_encounterController.value * 0.8),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('⚔️', style: const TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'ENCOUNTER!',
                    style: PixelTheme.pixelTitle(size: 28, color: PixelTheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '遭遇怪物！',
                    style: PixelTheme.pixelText(size: 14, color: PixelTheme.secondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class MapArea {
  final String name;
  final String emoji;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  
  MapArea({
    required this.name,
    required this.emoji,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.color,
  });
}

class Monster {
  final String name;
  final String emoji;
  final int minLevel;
  final int maxLevel;
  
  Monster({
    required this.name,
    required this.emoji,
    required this.minLevel,
    required this.maxLevel,
  });
}
