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
  // 玩家位置 (格子座標)
  int _playerX = 7;
  int _playerY = 8;
  int _playerDirection = 0; // 0=下, 1=左, 2=右, 3=上
  
  // 地圖設定
  static const int _mapWidth = 15;
  static const int _mapHeight = 12;
  static const double _tileSize = 28;
  
  // 遭遇戰
  int _steps = 0;
  int _stepsToEncounter = 0;
  final math.Random _random = math.Random();
  
  // 動畫
  late AnimationController _walkController;
  late AnimationController _encounterController;
  late AnimationController _waterController;
  bool _showEncounter = false;
  bool _isMoving = false;
  
  // 地圖圖層 (更豐富的地圖)
  // 0=草地, 1=深草(可遇敵), 2=花, 3=樹, 4=水, 5=路, 6=建築, 7=門, 8=石頭, 9=草叢2
  final List<List<int>> _groundLayer = [
    [3, 3, 3, 3, 3, 8, 8, 7, 8, 8, 3, 3, 3, 3, 3],
    [3, 0, 2, 0, 0, 1, 1, 5, 1, 1, 0, 0, 2, 0, 3],
    [3, 0, 6, 6, 0, 1, 9, 5, 9, 1, 0, 6, 6, 0, 3],
    [3, 2, 6, 6, 0, 0, 0, 5, 0, 0, 0, 6, 6, 2, 3],
    [3, 0, 0, 0, 2, 0, 0, 5, 0, 0, 2, 0, 0, 0, 3],
    [3, 1, 9, 0, 5, 5, 5, 5, 5, 5, 5, 0, 9, 1, 3],
    [3, 1, 1, 0, 5, 0, 2, 0, 2, 0, 5, 0, 1, 1, 3],
    [3, 9, 0, 0, 5, 0, 4, 4, 4, 0, 5, 0, 0, 9, 3],
    [3, 0, 2, 0, 5, 0, 4, 4, 4, 0, 5, 0, 2, 0, 3],
    [3, 0, 0, 0, 5, 0, 4, 4, 4, 0, 5, 0, 0, 0, 3],
    [3, 2, 0, 2, 5, 5, 5, 5, 5, 5, 5, 2, 0, 2, 3],
    [3, 3, 3, 3, 3, 3, 8, 8, 8, 3, 3, 3, 3, 3, 3],
  ];
  
  // NPC 位置
  final List<Map<String, dynamic>> _npcs = [
    {'x': 3, 'y': 3, 'emoji': '👨‍🏫', 'name': '數學老師', 'dialog': '努力學習數學吧！'},
    {'x': 12, 'y': 3, 'emoji': '👩‍🔬', 'name': '科學老師', 'dialog': '科學和數學密不可分！'},
    {'x': 6, 'y': 6, 'emoji': '🧑‍🎓', 'name': '學生A', 'dialog': '這裡的草叢有怪物！'},
    {'x': 8, 'y': 6, 'emoji': '👧', 'name': '學生B', 'dialog': '小心深色草叢！'},
    {'x': 1, 'y': 5, 'emoji': '🐕', 'name': '小狗', 'dialog': '汪汪！'},
  ];
  
  // 怪物列表
  final List<Monster> _monsters = [
    Monster(name: '數字小妖', emoji: '👾', minLevel: 1, maxLevel: 3),
    Monster(name: '算式幽靈', emoji: '👻', minLevel: 2, maxLevel: 5),
    Monster(name: '分數惡魔', emoji: '😈', minLevel: 3, maxLevel: 6),
    Monster(name: '方程怪獸', emoji: '🐲', minLevel: 4, maxLevel: 8),
    Monster(name: '幾何巨人', emoji: '🗿', minLevel: 5, maxLevel: 10),
  ];
  
  // Tile 顏色和 emoji (更豐富)
  final Map<int, Color> _tileColors = {
    0: const Color(0xFF90c960), // 草地 (更亮)
    1: const Color(0xFF5a9a32), // 深草
    2: const Color(0xFF90c960), // 花 (草地底色)
    3: const Color(0xFF2d5a14), // 樹 (更深)
    4: const Color(0xFF4aa8d8), // 水 (更亮)
    5: const Color(0xFFd4b896), // 路 (更亮)
    6: const Color(0xFFa67c4a), // 建築 (更亮)
    7: const Color(0xFFd4b896), // 門
    8: const Color(0xFF7a7a7a), // 石頭
    9: const Color(0xFF6aaa42), // 草叢2 (中等綠)
  };
  
  final Map<int, String> _tileEmojis = {
    2: '🌸', // 花
    3: '🌲', // 樹
    8: '🪨', // 石頭
  };
  
  // 可通行的 tile
  final Set<int> _walkableTiles = {0, 1, 2, 5, 7, 9};

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _encounterController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _waterController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
    
    _resetEncounterSteps();
  }

  @override
  void dispose() {
    _walkController.dispose();
    _encounterController.dispose();
    _waterController.dispose();
    super.dispose();
  }
  
  void _resetEncounterSteps() {
    _stepsToEncounter = _random.nextInt(10) + 5; // 5-15 步遇敵
    _steps = 0;
  }
  
  bool _canWalk(int x, int y) {
    if (x < 0 || x >= _mapWidth || y < 0 || y >= _mapHeight) return false;
    final tile = _groundLayer[y][x];
    if (!_walkableTiles.contains(tile)) return false;
    // 檢查 NPC
    for (final npc in _npcs) {
      if (npc['x'] == x && npc['y'] == y) return false;
    }
    return true;
  }
  
  void _checkEncounter() {
    // 只有在深草 (1) 才會遇敵
    final currentTile = _groundLayer[_playerY][_playerX];
    if (currentTile == 1) {
      _steps++;
      if (_steps >= _stepsToEncounter) {
        _triggerEncounter();
      }
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
    if (_isMoving || _showEncounter) return;
    
    int newX = _playerX;
    int newY = _playerY;
    
    switch (direction) {
      case 0: newY += 1; break; // 下
      case 1: newX -= 1; break; // 左
      case 2: newX += 1; break; // 右
      case 3: newY -= 1; break; // 上
    }
    
    setState(() {
      _playerDirection = direction;
    });
    
    if (_canWalk(newX, newY)) {
      setState(() => _isMoving = true);
      _walkController.forward(from: 0).then((_) {
        setState(() {
          _playerX = newX;
          _playerY = newY;
          _isMoving = false;
        });
        _checkEncounter();
      });
    }
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
                      child: _buildTileMap(),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: PixelTheme.bgMid,
        border: const Border(bottom: BorderSide(color: PixelTheme.textDim, width: 3)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: PixelTheme.bgLight,
                border: Border.all(color: PixelTheme.textDim, width: 2),
              ),
              child: const Icon(Icons.arrow_back, color: PixelTheme.textLight, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          Text('🗺️', style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 6),
          Text(
            'ADVENTURE',
            style: PixelTheme.pixelTitle(size: 14, color: PixelTheme.secondary),
          ),
          const Spacer(),
          // 遇敵提示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PixelTheme.bgLight,
              border: Border.all(color: PixelTheme.textDim, width: 2),
            ),
            child: Row(
              children: [
                const Text('🌿', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '深草可遇敵',
                  style: PixelTheme.pixelText(size: 6, color: PixelTheme.textDim),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTileMap() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: PixelTheme.textDim, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: ClipRect(
        child: SizedBox(
          width: _mapWidth * _tileSize,
          height: _mapHeight * _tileSize,
          child: Stack(
            children: [
              // 地圖格子
              ...List.generate(_mapHeight, (y) {
                return List.generate(_mapWidth, (x) {
                  return Positioned(
                    left: x * _tileSize,
                    top: y * _tileSize,
                    child: _buildTile(x, y),
                  );
                });
              }).expand((e) => e),
              
              // NPC
              ..._npcs.map((npc) => Positioned(
                left: npc['x'] * _tileSize,
                top: npc['y'] * _tileSize,
                child: _buildNPC(npc),
              )),
              
              // 玩家
              AnimatedBuilder(
                animation: _walkController,
                builder: (context, child) {
                  double offsetX = 0;
                  double offsetY = 0;
                  
                  if (_isMoving) {
                    final progress = _walkController.value;
                    switch (_playerDirection) {
                      case 0: offsetY = progress * _tileSize; break;
                      case 1: offsetX = -progress * _tileSize; break;
                      case 2: offsetX = progress * _tileSize; break;
                      case 3: offsetY = -progress * _tileSize; break;
                    }
                  }
                  
                  return Positioned(
                    left: (_playerX * _tileSize) + offsetX - (_isMoving ? (_playerDirection == 2 ? _tileSize : (_playerDirection == 1 ? 0 : 0)) : 0),
                    top: (_playerY * _tileSize) + offsetY - (_isMoving ? (_playerDirection == 0 ? _tileSize : (_playerDirection == 3 ? 0 : 0)) : 0),
                    child: _buildPlayer(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildTile(int x, int y) {
    final tileType = _groundLayer[y][x];
    final color = _tileColors[tileType] ?? Colors.grey;
    final emoji = _tileEmojis[tileType];
    
    // 水波動畫
    if (tileType == 4) {
      return AnimatedBuilder(
        animation: _waterController,
        builder: (context, child) {
          final wave = math.sin(_waterController.value * math.pi * 2 + x + y) * 0.15;
          return Container(
            width: _tileSize,
            height: _tileSize,
            decoration: BoxDecoration(
              color: color.withOpacity(0.8 + wave),
              border: Border.all(color: color.withOpacity(0.5), width: 0.5),
            ),
            child: Center(
              child: Text('🌊', style: TextStyle(fontSize: _tileSize * 0.5)),
            ),
          );
        },
      );
    }
    
    // 深草擺動
    if (tileType == 1 || tileType == 9) {
      return Container(
        width: _tileSize,
        height: _tileSize,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: color.withOpacity(0.7), width: 0.5),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: _tileSize * 0.1,
              child: Text('🌿', style: TextStyle(fontSize: _tileSize * 0.4)),
            ),
            Positioned(
              bottom: 0,
              right: _tileSize * 0.1,
              child: Text('🌱', style: TextStyle(fontSize: _tileSize * 0.35)),
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: _tileSize,
      height: _tileSize,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: color.withOpacity(0.7), width: 0.5),
      ),
      child: emoji != null 
          ? Center(child: Text(emoji, style: TextStyle(fontSize: _tileSize * 0.6)))
          : null,
    );
  }
  
  Widget _buildNPC(Map<String, dynamic> npc) {
    return Container(
      width: _tileSize,
      height: _tileSize,
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: Text(
          npc['emoji'],
          style: TextStyle(fontSize: _tileSize * 0.7),
        ),
      ),
    );
  }
  
  Widget _buildPlayer() {
    final gameState = context.read<GameState>();
    final petEmoji = gameState.activePet?.emoji ?? '🧑';
    
    // 方向對應的旋轉/翻轉
    double rotation = 0;
    bool flipX = false;
    
    return Container(
      width: _tileSize,
      height: _tileSize,
      decoration: BoxDecoration(
        color: PixelTheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: PixelTheme.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: PixelTheme.primary.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          petEmoji,
          style: TextStyle(fontSize: _tileSize * 0.65),
        ),
      ),
    );
  }
  
  Widget _buildController() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 搖杆
          _buildJoystick(),
          
          // 右邊資訊 + A/B 按鈕
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 資訊
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PixelTheme.bgMid,
                  border: Border.all(color: PixelTheme.textDim, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '座標: ($_playerX, $_playerY)',
                      style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
                    ),
                    if (_groundLayer[_playerY][_playerX] == 1)
                      Text(
                        '⚠️ 深草區域！',
                        style: PixelTheme.pixelText(size: 7, color: PixelTheme.warning),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // A/B 按鈕
              Row(
                children: [
                  _buildActionButton('B', PixelTheme.error, () => Navigator.pop(context)),
                  const SizedBox(width: 12),
                  _buildActionButton('A', PixelTheme.primary, () {}),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 搖杆狀態
  Offset _joystickPosition = Offset.zero;
  bool _joystickActive = false;
  
  Widget _buildJoystick() {
    const double joystickSize = 130;
    const double knobSize = 50;
    const double maxDistance = (joystickSize - knobSize) / 2;
    
    return GestureDetector(
      onPanStart: (details) {
        setState(() => _joystickActive = true);
      },
      onPanUpdate: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final center = Offset(joystickSize / 2, joystickSize / 2);
        final localPosition = details.localPosition - center;
        
        // 限制在圓形範圍內
        final distance = localPosition.distance;
        final clampedDistance = distance.clamp(0.0, maxDistance);
        final direction = distance > 0 ? localPosition / distance : Offset.zero;
        
        setState(() {
          _joystickPosition = direction * clampedDistance;
        });
        
        // 根據方向移動
        _handleJoystickMove();
      },
      onPanEnd: (details) {
        setState(() {
          _joystickPosition = Offset.zero;
          _joystickActive = false;
        });
      },
      child: Container(
        width: joystickSize,
        height: joystickSize,
        decoration: BoxDecoration(
          color: PixelTheme.bgMid,
          shape: BoxShape.circle,
          border: Border.all(color: PixelTheme.accent, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 背景指示線
            CustomPaint(
              size: Size(joystickSize, joystickSize),
              painter: _JoystickBackgroundPainter(),
            ),
            // 搖杆頭
            Transform.translate(
              offset: _joystickPosition,
              child: Container(
                width: knobSize,
                height: knobSize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      PixelTheme.accent,
                      PixelTheme.accent.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: PixelTheme.accent.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  DateTime? _lastMoveTime;
  
  void _handleJoystickMove() {
    // 限制移動頻率
    final now = DateTime.now();
    if (_lastMoveTime != null && 
        now.difference(_lastMoveTime!).inMilliseconds < 150) {
      return;
    }
    
    // 計算方向
    if (_joystickPosition.distance < 15) return; // 死區
    
    final angle = _joystickPosition.direction;
    int direction;
    
    if (angle > -0.785 && angle <= 0.785) {
      direction = 2; // 右
    } else if (angle > 0.785 && angle <= 2.356) {
      direction = 0; // 下
    } else if (angle > -2.356 && angle <= -0.785) {
      direction = 3; // 上
    } else {
      direction = 1; // 左
    }
    
    _move(direction);
    _lastMoveTime = now;
  }
  
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              color,
              color.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: PixelTheme.pixelText(size: 16, color: Colors.white),
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
          color: Colors.black.withOpacity(_encounterController.value * 0.9),
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⚔️', style: TextStyle(fontSize: 80)),
                  const SizedBox(height: 16),
                  Text(
                    'WILD ENCOUNTER!',
                    style: PixelTheme.pixelTitle(size: 24, color: PixelTheme.error),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '野生怪物出現了！',
                    style: PixelTheme.pixelText(size: 12, color: PixelTheme.secondary),
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

// 搖杆背景繪製器
class _JoystickBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = PixelTheme.textDim.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // 畫十字線
    canvas.drawLine(
      Offset(center.dx, 15),
      Offset(center.dx, size.height - 15),
      paint,
    );
    canvas.drawLine(
      Offset(15, center.dy),
      Offset(size.width - 15, center.dy),
      paint,
    );
    
    // 畫內圈
    canvas.drawCircle(center, 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
