import 'package:flutter/material.dart';

/// Pixel Art 遊戲主題 - 升級為 Codedex 風格
class PixelTheme {
  // Codedex 色板 - 霓虹色 + 太空黑
  static const Color bgDark = Color(0xFF0D1117);      // 深太空黑背景
  static const Color bgMid = Color(0xFF161B22);       // 中間背景 (卡片)
  static const Color bgLight = Color(0xFF21262D);     // 淺背景
  static const Color bgCard = Color(0xFF1C2333);      // 專用卡片背景
  
  static const Color primary = Color(0xFF6C63FF);     // 霓虹紫 (主色)
  static const Color secondary = Color(0xFFFFD700);   // 金黃 (金幣/分數)
  static const Color secondaryGlow = Color(0xFFFFB700); // 金黃發光
  static const Color accent = Color(0xFF00D4AA);      // 青綠 (特殊)
  static const Color pink = Color(0xFFFF6B9D);        // 粉紅
  static const Color cyan = Color(0xFF38B6FF);        // 天藍
  static const Color orange = Color(0xFFFF8C42);      // 橙色
  static const Color purple = Color(0xFFa855f7);      // 紫色 (史詩)
  
  static const Color textLight = Color(0xFFF0F6FC);   // 白色文字
  static const Color textDim = Color(0xFF8B949E);     // 暗灰文字
  static const Color textMuted = Color(0xFF484F58);   // 更暗的文字
  
  static const Color success = Color(0xFF00D4AA);     // 答對
  static const Color error = Color(0xFFff6b6b);       // 答錯
  static const Color warning = Color(0xFFFFD700);     // 警告
  
  // 常數
  static const String defaultRarity = 'common';       // 預設稀有度
  static const double starThresholdHigh = 80.0;       // 3星門檻 (80%+)
  static const double starThresholdMid = 60.0;        // 2星門檻 (60%+)
  static const double starThresholdLow = 40.0;        // 1星門檻 (40%+)
  
  // 保留向後兼容的像素色
  static const Color pixel1 = Color(0xFF5fcde4);      // 青色
  static const Color pixel2 = Color(0xFFcbdbfc);      // 淺藍
  static const Color pixel3 = Color(0xFF9badb7);      // 灰藍
  static const Color pixel4 = Color(0xFF847e87);      // 暗灰
  
  // Codedex 風格漸變背景
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      bgDark,
      Color(0xFF0D1520),
      Color(0xFF0A0E1A),
    ],
  );
  
  // 紫色發光漸層
  static const LinearGradient purpleGlow = LinearGradient(
    colors: [
      primary,
      Color(0xFF8B7FFF),
      Color(0xFFB4A3FF),
    ],
  );
  
  // 卡片專用漸層
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      bgCard,
      bgMid,
    ],
  );
  
  // 根據稀有度獲取顏色
  static Color getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return secondary; // Gold
      case 'epic':
        return purple; // Purple
      case 'rare':
        return cyan; // Blue
      case 'common':
      default:
        return textDim; // Gray
    }
  }
  
  // 題目專用字體 (清晰易讀)
  static const String questionFont = 'Times New Roman';
  static const String questionFontChinese = 'PMingLiU';  // 新細明體
  
  // 題目文字樣式 - 使用標準字體
  static TextStyle questionText({
    double size = 16,
    Color color = textLight,
    double? height,
  }) {
    return TextStyle(
      fontFamily: questionFontChinese,
      fontSize: size,
      color: color,
      height: height ?? 1.6,
    );
  }
  
  // 像素字體
  static const String pixelFont = 'PressStart2P';
  
  // Codedex 風格圓角卡片裝飾
  static BoxDecoration codedexCard({
    Color? color,
    Color? borderColor,
    double borderRadius = 16,
    bool withGlow = false,
  }) {
    return BoxDecoration(
      gradient: color != null 
        ? null
        : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgCard, bgMid],
          ),
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor ?? textMuted.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: withGlow
        ? [
            BoxShadow(
              color: (borderColor ?? primary).withOpacity(0.3),
              blurRadius: 16,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }
  
  // 霓虹發光按鈕裝飾
  static BoxDecoration glowButton({
    required Color color,
    double borderRadius = 12,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(borderRadius),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.6),
          blurRadius: 20,
          spreadRadius: 0,
        ),
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 40,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // Quest 進度卡片裝飾
  static BoxDecoration questCard({
    Color accentColor = primary,
    bool isCompleted = false,
    bool isLocked = false,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isLocked 
          ? [bgMid.withOpacity(0.5), bgCard.withOpacity(0.5)]
          : [bgCard, bgMid],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isCompleted 
          ? success.withOpacity(0.5)
          : isLocked
            ? textMuted.withOpacity(0.2)
            : accentColor.withOpacity(0.3),
        width: 2,
      ),
      boxShadow: [
        if (!isLocked)
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  // 現代清晰文字樣式 (用於內文)
  static TextStyle modernText({
    double size = 16,
    Color color = textLight,
    FontWeight weight = FontWeight.normal,
    double? height,
  }) {
    return TextStyle(
      fontSize: size,
      color: color,
      fontWeight: weight,
      height: height ?? 1.5,
      letterSpacing: 0.3,
    );
  }
  
  // 像素邊框裝飾 (向後兼容)
  static BoxDecoration pixelBorder({
    Color color = textLight,
    Color? bgColor,
    int borderWidth = 4,
  }) {
    return BoxDecoration(
      color: bgColor ?? bgMid,
      border: Border.all(color: color, width: borderWidth.toDouble()),
      // 像素風格用直角
    );
  }
  
  // 凸起按鈕效果
  static BoxDecoration pixelButton({
    Color topColor = const Color(0xFF3bff6f),
    Color bottomColor = const Color(0xFF2a9d4f),
    Color shadowColor = const Color(0xFF1a5c2f),
  }) {
    return BoxDecoration(
      color: topColor,
      border: Border(
        top: BorderSide(color: topColor.withOpacity(0.8), width: 4),
        left: BorderSide(color: topColor.withOpacity(0.8), width: 4),
        right: BorderSide(color: shadowColor, width: 4),
        bottom: BorderSide(color: shadowColor, width: 4),
      ),
    );
  }
  
  // 凹陷效果 (被按下)
  static BoxDecoration pixelButtonPressed({
    Color topColor = const Color(0xFF2a9d4f),
    Color shadowColor = const Color(0xFF1a5c2f),
  }) {
    return BoxDecoration(
      color: topColor,
      border: Border.all(color: shadowColor, width: 4),
    );
  }
  
  // 文字樣式
  static TextStyle pixelText({
    double size = 12,
    Color color = textLight,
    double? height,
  }) {
    return TextStyle(
      fontFamily: pixelFont,
      fontSize: size,
      color: color,
      height: height ?? 1.5,
      letterSpacing: 1,
    );
  }
  
  // 標題樣式 - 帶發光效果
  static TextStyle pixelTitle({double size = 16, Color color = textLight}) {
    return TextStyle(
      fontFamily: pixelFont,
      fontSize: size,
      color: color,
      height: 1.3,
      shadows: [
        Shadow(
          color: color.withOpacity(0.8),
          offset: const Offset(0, 0),
          blurRadius: 20,
        ),
        Shadow(
          color: color.withOpacity(0.5),
          offset: const Offset(0, 0),
          blurRadius: 40,
        ),
        Shadow(color: Colors.black, offset: const Offset(2, 2), blurRadius: 0),
      ],
    );
  }
}

/// 像素風格按鈕
class PixelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color color;
  final double width;
  final double height;
  final double fontSize;
  final String? emoji;

  const PixelButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color = PixelTheme.primary,
    this.width = double.infinity,
    this.height = 56,
    this.fontSize = 10,
    this.emoji,
  });

  @override
  State<PixelButton> createState() => _PixelButtonState();
}

class _PixelButtonState extends State<PixelButton> {
  bool _isPressed = false;

  Color get _shadowColor => HSLColor.fromColor(widget.color)
      .withLightness((HSLColor.fromColor(widget.color).lightness - 0.3).clamp(0, 1))
      .toColor();

  Color get _highlightColor => HSLColor.fromColor(widget.color)
      .withLightness((HSLColor.fromColor(widget.color).lightness + 0.1).clamp(0, 1))
      .toColor();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.translationValues(0, _isPressed ? 4 : 0, 0),
        decoration: BoxDecoration(
          color: widget.color,
          border: Border(
            top: BorderSide(
              color: _isPressed ? _shadowColor : _highlightColor,
              width: 4,
            ),
            left: BorderSide(
              color: _isPressed ? _shadowColor : _highlightColor,
              width: 4,
            ),
            right: BorderSide(color: _shadowColor, width: 4),
            bottom: BorderSide(
              color: _shadowColor,
              width: _isPressed ? 4 : 8,
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.emoji != null) ...[
                Text(widget.emoji!, style: TextStyle(fontSize: widget.fontSize + 4)),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: PixelTheme.pixelText(
                  size: widget.fontSize,
                  color: PixelTheme.bgDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 像素風格卡片 - 更新為圓角 Codedex 風格
class PixelCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? bgColor;
  final EdgeInsets padding;
  final bool rounded; // 新增: 是否使用圓角

  const PixelCard({
    super.key,
    required this.child,
    this.borderColor = PixelTheme.textDim,
    this.bgColor,
    this.padding = const EdgeInsets.all(16),
    this.rounded = true, // 預設使用圓角
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: rounded
        ? PixelTheme.codedexCard(
            color: bgColor,
            borderColor: borderColor,
          )
        : BoxDecoration(
            color: bgColor ?? PixelTheme.bgMid,
            border: Border.all(color: borderColor, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
      child: child,
    );
  }
}

/// 像素風格進度條
class PixelProgressBar extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final Color fillColor;
  final Color bgColor;
  final double height;
  final String? label;

  const PixelProgressBar({
    super.key,
    required this.value,
    this.fillColor = PixelTheme.primary,
    this.bgColor = PixelTheme.bgLight,
    this.height = 24,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(label!, style: PixelTheme.pixelText(size: 8)),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: PixelTheme.textDim, width: 3),
          ),
          child: Stack(
            children: [
              // 填充
              FractionallySizedBox(
                widthFactor: value.clamp(0, 1),
                child: Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    border: Border(
                      top: BorderSide(
                        color: fillColor.withOpacity(0.7),
                        width: 4,
                      ),
                    ),
                  ),
                ),
              ),
              // 像素分隔線
              Row(
                children: List.generate(10, (i) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.black.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 像素風格生命條
class PixelHealthBar extends StatelessWidget {
  final int current;
  final int max;
  final String label;
  final Color color;
  final String emoji;

  const PixelHealthBar({
    super.key,
    required this.current,
    required this.max,
    this.label = 'HP',
    this.color = PixelTheme.primary,
    this.emoji = '❤️',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Expanded(
          child: PixelProgressBar(
            value: max > 0 ? current / max : 0,
            fillColor: color,
            height: 20,
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

/// 像素風格 Badge
class PixelBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;

  const PixelBadge({
    super.key,
    required this.text,
    this.color = PixelTheme.secondary,
    this.fontSize = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        border: Border(
          bottom: BorderSide(
            color: HSLColor.fromColor(color)
                .withLightness((HSLColor.fromColor(color).lightness - 0.2).clamp(0, 1))
                .toColor(),
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        style: PixelTheme.pixelText(size: fontSize, color: PixelTheme.bgDark),
      ),
    );
  }
}

/// 閃爍動畫文字
class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const BlinkingText({
    super.key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value > 0.5 ? 1 : 0.3,
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

/// 像素風格選項按鈕
class PixelOptionButton extends StatefulWidget {
  final String label;
  final String text;
  final VoidCallback? onTap;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;

  const PixelOptionButton({
    super.key,
    required this.label,
    required this.text,
    this.onTap,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
  });

  @override
  State<PixelOptionButton> createState() => _PixelOptionButtonState();
}

class _PixelOptionButtonState extends State<PixelOptionButton> {
  bool _isPressed = false;

  Color get _bgColor {
    if (widget.showResult) {
      if (widget.isCorrect) return PixelTheme.success.withOpacity(0.3);
      if (widget.isWrong) return PixelTheme.error.withOpacity(0.3);
    }
    if (widget.isSelected) return PixelTheme.accent.withOpacity(0.3);
    return PixelTheme.bgMid;
  }

  Color get _borderColor {
    if (widget.showResult) {
      if (widget.isCorrect) return PixelTheme.success;
      if (widget.isWrong) return PixelTheme.error;
    }
    if (widget.isSelected) return PixelTheme.accent;
    return PixelTheme.textDim;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onTap != null ? (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgColor,
          border: Border.all(color: _borderColor, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              offset: Offset(4, _isPressed ? 2 : 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Label (A, B, C, D)
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _borderColor,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.label,
                  style: PixelTheme.pixelText(
                    size: 12,
                    color: PixelTheme.bgDark,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Text - 使用清晰字體顯示選項
            Expanded(
              child: Text(
                widget.text,
                style: PixelTheme.questionText(size: 16),
              ),
            ),
            // Result icon
            if (widget.showResult && widget.isCorrect)
              const Text('✓', style: TextStyle(fontSize: 24, color: PixelTheme.success)),
            if (widget.showResult && widget.isWrong)
              const Text('✗', style: TextStyle(fontSize: 24, color: PixelTheme.error)),
          ],
        ),
      ),
    );
  }
}

/// 像素星星難度指示
class PixelStars extends StatelessWidget {
  final int count;
  final int max;
  final double size;

  const PixelStars({
    super.key,
    required this.count,
    this.max = 3,
    this.size = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        return Text(
          i < count ? '★' : '☆',
          style: TextStyle(
            fontSize: size,
            color: i < count ? PixelTheme.secondary : PixelTheme.textDim,
          ),
        );
      }),
    );
  }
}
