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
  bool _showEncounter = false;
  bool _isMoving = false;
  
  // 地圖圖層
  // 0=草地, 1=深草(可遇敵), 2=花, 3=樹, 4=水, 5=路, 6=建築, 7=門, 8=柵欄
  final List<List<int>> _groundLayer = [
    [3, 3, 3, 3, 3, 3, 3, 7, 3, 3, 3, 3, 3, 3, 3],
    [3, 0, 0, 0, 0, 1, 1, 5, 1, 1, 0, 0, 2, 0, 3],
    [3, 0, 6, 6, 0, 1, 1, 5, 1, 1, 0, 6, 6, 0, 3],
    [3, 0, 6, 6, 0, 0, 0, 5, 0, 0, 0, 6, 6, 0, 3],
    [3, 0, 0, 0, 0, 2, 0, 5, 0, 2, 0, 0, 0, 0, 3],
    [3, 1, 1, 0, 5, 5, 5, 5, 5, 5, 5, 0, 1, 1, 3],
    [3, 1, 1, 0, 5, 0, 0, 0, 0, 0, 5, 0, 1, 1, 3],
    [3, 0, 0, 0, 5, 0, 4, 4, 4, 0, 5, 0, 0, 0, 3],
    [3, 2, 0, 0, 5, 0, 4, 4, 4, 0, 5, 0, 0, 2, 3],
    [3, 0, 0, 0, 5, 0, 0, 0, 0, 0, 5, 0, 0, 0, 3],
    [3, 0, 2, 0, 5, 5, 5, 5, 5, 5, 5, 0, 2, 0, 3],
    [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3],
  ];
  
  // NPC 位置
  final List<Map<String, dynamic>> _npcs = [
    {'x': 3, 'y': 4, 'emoji': '👨‍🏫', 'name': '數學老師'},
    {'x': 11, 'y': 4, 'emoji': '👩‍🔬', 'name': '科學老師'},
    {'x': 6, 'y': 9, 'emoji': '🧑‍🎓', 'name': '學生'},
    {'x': 9, 'y': 6, 'emoji': '👧', 'name': '同學'},
  ];
  
  // 怪物列表
  final List<Monster> _monsters = [
    Monster(name: '數字小妖', emoji: '👾', minLevel: 1, maxLevel: 3),
    Monster(name: '算式幽靈', emoji: '👻', minLevel: 2, maxLevel: 5),
    Monster(name: '分數惡魔', emoji: '😈', minLevel: 3, maxLevel: 6),
    Monster(name: '方程怪獸', emoji: '🐲', minLevel: 4, maxLevel: 8),
    Monster(name: '幾何巨人', emoji: '🗿', minLevel: 5, maxLevel: 10),
  ];
  
  // Tile 顏色和 emoji
  final Map<int, Color> _tileColors = {
    0: const Color(0xFF7ec850), // 草地
    1: const Color(0xFF5a9a32), // 深草
    2: const Color(0xFF7ec850), // 花 (草地底色)
    3: const Color(0xFF3d6e24), // 樹
    4: const Color(0xFF3498db), // 水
    5: const Color(0xFFc4a574), // 路
    6: const Color(0xFF8b6914), // 建築
    7: const Color(0xFFc4a574), // 門
    8: const Color(0xFF6b4423), // 柵欄
  };
  
  final Map<int, String> _tileEmoji = {
    2: '🌸', // 花
    3: '🌲', // 樹
    4: '🌊', // 水 (動畫用)
  };
  
  // 可通行的 tile
  final Set<int> _walkableTiles = {0, 1, 2, 5, 7};

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
    
    _resetEncounterSteps();
  }

  @override
  void dispose() {
    _walkController.dispose();
    _encounterController.dispose();
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
    final emoji = _tileEmoji[tileType];
    
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 左邊資訊
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '座標: ($_playerX, $_playerY)',
                  style: PixelTheme.pixelText(size: 7, color: PixelTheme.textDim),
                ),
                const SizedBox(height: 4),
                if (_groundLayer[_playerY][_playerX] == 1)
                  Text(
                    '⚠️ 深草區域！',
                    style: PixelTheme.pixelText(size: 7, color: PixelTheme.warning),
                  ),
              ],
            ),
          ),
          
          // D-Pad
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 上
                Positioned(
                  top: 0,
                  child: _buildDPadButton('▲', 3),
                ),
                // 下
                Positioned(
                  bottom: 0,
                  child: _buildDPadButton('▼', 0),
                ),
                // 左
                Positioned(
                  left: 0,
                  child: _buildDPadButton('◀', 1),
                ),
                // 右
                Positioned(
                  right: 0,
                  child: _buildDPadButton('▶', 2),
                ),
                // 中心
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: PixelTheme.bgMid,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PixelTheme.textDim, width: 2),
                  ),
                ),
              ],
            ),
          ),
          
          // 右邊 A/B 按鈕
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildActionButton('A', PixelTheme.primary, () {}),
                const SizedBox(height: 8),
                _buildActionButton('B', PixelTheme.error, () => Navigator.pop(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDPadButton(String label, int direction) {
    return GestureDetector(
      onTap: () => _move(direction),
      onLongPress: () async {
        while (mounted && !_showEncounter) {
          _move(direction);
          await Future.delayed(const Duration(milliseconds: 150));
        }
      },
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: PixelTheme.bgMid,
          border: Border.all(color: PixelTheme.accent, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: PixelTheme.pixelText(size: 16, color: PixelTheme.accent),
          ),
        ),
      ),
    );
  }
  
  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: PixelTheme.pixelText(size: 14, color: Colors.white),
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
