import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/avatar_data.dart';
import '../widgets/avatar_widget.dart';
import '../theme/pixel_theme.dart';
import '../theme/codedex_widgets.dart';
import 'grade_selection_screen.dart';

class AvatarBuilderScreen extends StatefulWidget {
  final bool isEditMode; // 是否為編輯模式（從設置進入）

  const AvatarBuilderScreen({
    super.key,
    this.isEditMode = false,
  });

  @override
  State<AvatarBuilderScreen> createState() => _AvatarBuilderScreenState();
}

class _AvatarBuilderScreenState extends State<AvatarBuilderScreen>
    with SingleTickerProviderStateMixin {
  AvatarData _currentAvatar = AvatarData.defaultAvatar;
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final avatarJson = prefs.getString('user_avatar');
    
    setState(() {
      if (avatarJson != null) {
        _currentAvatar = AvatarData.fromJsonString(avatarJson);
      } else {
        _currentAvatar = AvatarData.defaultAvatar;
      }
    });
  }

  Future<void> _saveAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', _currentAvatar.toJsonString());
    
    if (!mounted) return;
    
    if (widget.isEditMode) {
      // 編輯模式：返回上一頁
      Navigator.pop(context, true);
    } else {
      // 首次設置：導航到年級選擇
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const GradeSelectionScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _randomizeAvatar() {
    setState(() {
      _currentAvatar = AvatarData.randomAvatar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: PixelTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // 頂部對話氣泡
              _buildTopBubble(),
              
              const SizedBox(height: 20),
              
              // 主內容區域
              Expanded(
                child: isSmallScreen
                    ? _buildVerticalLayout()
                    : _buildHorizontalLayout(),
              ),
              
              // 底部儲存按鈕
              _buildSaveButton(),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: PixelTheme.codedexCard(
          borderColor: PixelTheme.primary.withOpacity(0.3),
          borderRadius: 20,
          withGlow: true,
        ),
        child: Row(
          children: [
            const Text('✨', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.isEditMode 
                    ? '更改你嘅角色外觀！'
                    : '首先，設計你嘅專屬角色！之後可以隨時更改 ✨',
                style: PixelTheme.modernText(
                  size: 14,
                  color: PixelTheme.textLight,
                  weight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 角色預覽
          _buildPreviewSection(),
          
          const SizedBox(height: 24),
          
          // 自訂選項
          _buildCustomizationSection(),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout() {
    return Row(
      children: [
        // 左側：角色預覽
        Expanded(
          flex: 2,
          child: _buildPreviewSection(),
        ),
        
        const SizedBox(width: 16),
        
        // 右側：自訂選項
        Expanded(
          flex: 3,
          child: _buildCustomizationSection(),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 大型預覽框
          Container(
            width: 250,
            height: 250,
            decoration: PixelTheme.codedexCard(
              borderColor: PixelTheme.accent.withOpacity(0.3),
              borderRadius: 24,
            ),
            child: Center(
              child: AvatarWidget(
                data: _currentAvatar,
                size: 180,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Random 按鈕
          GestureDetector(
            onTap: _randomizeAvatar,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: PixelTheme.codedexCard(
                borderColor: PixelTheme.textDim.withOpacity(0.3),
                borderRadius: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔄', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    'RANDOM',
                    style: PixelTheme.pixelText(
                      size: 10,
                      color: PixelTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Tab Bar
          Container(
            decoration: PixelTheme.codedexCard(
              borderColor: PixelTheme.textMuted.withOpacity(0.3),
              borderRadius: 16,
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PixelTheme.primary.withOpacity(0.3),
                    PixelTheme.accent.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PixelTheme.primary.withOpacity(0.5),
                  width: 2,
                ),
              ),
              labelColor: PixelTheme.textLight,
              unselectedLabelColor: PixelTheme.textDim,
              tabs: const [
                Tab(icon: Text('😊', style: TextStyle(fontSize: 24))),
                Tab(icon: Text('🎨', style: TextStyle(fontSize: 24))),
                Tab(icon: Text('🧢', style: TextStyle(fontSize: 24))),
                Tab(icon: Text('🖼️', style: TextStyle(fontSize: 24))),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFaceTab(),
                _buildColorTab(),
                _buildAccessoryTab(),
                _buildFrameTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '表情 Face',
              style: PixelTheme.pixelText(
                size: 10,
                color: PixelTheme.textDim,
              ),
            ),
          ),
          _buildEmojiGrid(
            AvatarData.faceEmojis,
            _currentAvatar.faceEmoji,
            (emoji) {
              setState(() {
                _currentAvatar = _currentAvatar.copyWith(faceEmoji: emoji);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildColorTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '背景色 Color',
              style: PixelTheme.pixelText(
                size: 10,
                color: PixelTheme.textDim,
              ),
            ),
          ),
          _buildColorGrid(),
        ],
      ),
    );
  }

  Widget _buildAccessoryTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '配飾 Accessory',
              style: PixelTheme.pixelText(
                size: 10,
                color: PixelTheme.textDim,
              ),
            ),
          ),
          _buildEmojiGrid(
            AvatarData.accessoryEmojis,
            _currentAvatar.accessoryEmoji,
            (emoji) {
              setState(() {
                _currentAvatar = _currentAvatar.copyWith(accessoryEmoji: emoji);
              });
            },
            showNone: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFrameTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '邊框 Frame',
              style: PixelTheme.pixelText(
                size: 10,
                color: PixelTheme.textDim,
              ),
            ),
          ),
          _buildFrameGrid(),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(
    List<String> emojis,
    String selectedEmoji,
    Function(String) onSelect, {
    bool showNone = false,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        final isSelected = emoji == selectedEmoji;
        final isEmpty = emoji.isEmpty;

        return GestureDetector(
          onTap: () => onSelect(emoji),
          child: Container(
            decoration: PixelTheme.codedexCard(
              borderColor: isSelected
                  ? PixelTheme.primary
                  : PixelTheme.textMuted.withOpacity(0.3),
              borderRadius: 12,
              withGlow: isSelected,
            ),
            child: Center(
              child: isEmpty
                  ? Text(
                      '無',
                      style: PixelTheme.pixelText(
                        size: 8,
                        color: PixelTheme.textDim,
                      ),
                    )
                  : Text(
                      emoji,
                      style: const TextStyle(fontSize: 32),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: AvatarData.backgroundColors.length,
      itemBuilder: (context, index) {
        final color = AvatarData.backgroundColors[index];
        final isSelected = color.value == _currentAvatar.backgroundColor;

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentAvatar = _currentAvatar.copyWith(backgroundColor: color.value);
            });
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? PixelTheme.textLight
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.6),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Center(
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildFrameGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: AvatarData.frameStyleNames.length,
      itemBuilder: (context, index) {
        final isSelected = index == _currentAvatar.frameStyle;
        final frameName = AvatarData.frameStyleNames[index];

        return GestureDetector(
          onTap: () {
            setState(() {
              _currentAvatar = _currentAvatar.copyWith(frameStyle: index);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: PixelTheme.codedexCard(
              borderColor: isSelected
                  ? PixelTheme.primary
                  : PixelTheme.textMuted.withOpacity(0.3),
              borderRadius: 12,
              withGlow: isSelected,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 小型預覽
                AvatarWidget(
                  data: _currentAvatar.copyWith(frameStyle: index),
                  size: 50,
                  showAccessory: false,
                ),
                const SizedBox(height: 8),
                Text(
                  frameName,
                  style: PixelTheme.modernText(
                    size: 10,
                    color: isSelected
                        ? PixelTheme.textLight
                        : PixelTheme.textDim,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlowButton(
        text: 'SAVE CHANGES',
        emoji: '💾',
        color: PixelTheme.cyan,
        height: 60,
        fontSize: 12,
        onPressed: _saveAvatar,
      ),
    );
  }
}
