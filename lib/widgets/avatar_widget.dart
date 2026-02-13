import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/avatar_data.dart';
import '../theme/pixel_theme.dart';

/// 可重用的 Avatar 顯示 Widget
class AvatarWidget extends StatelessWidget {
  final AvatarData data;
  final double size;
  final bool showAccessory;
  final bool showGlow;

  const AvatarWidget({
    super.key,
    required this.data,
    this.size = 120,
    this.showAccessory = true,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(data.backgroundColor);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 外圈邊框效果
          _buildFrame(bgColor),
          
          // 背景圓形/方形
          _buildBackground(bgColor),
          
          // 中間大 emoji
          Center(
            child: Text(
              data.faceEmoji,
              style: TextStyle(fontSize: size * 0.5),
            ),
          ),
          
          // 頂部配飾 emoji
          if (showAccessory && data.accessoryEmoji.isNotEmpty)
            Positioned(
              top: size * 0.05,
              child: Text(
                data.accessoryEmoji,
                style: TextStyle(fontSize: size * 0.3),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground(Color bgColor) {
    switch (data.frameStyle) {
      case 2: // 方形發光
        return Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(size * 0.15),
          ),
        );
      case 3: // 六角形
        return ClipPath(
          clipper: _HexagonClipper(),
          child: Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  bgColor,
                  bgColor.withOpacity(0.7),
                ],
              ),
            ),
          ),
        );
      default: // 圓形（預設和其他情況）
        return Container(
          width: size * 0.85,
          height: size * 0.85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                bgColor,
                bgColor.withOpacity(0.7),
              ],
            ),
          ),
        );
    }
  }

  Widget _buildFrame(Color bgColor) {
    if (data.frameStyle == 0 || !showGlow) {
      // 無邊框
      return const SizedBox.shrink();
    }

    switch (data.frameStyle) {
      case 1: // 圓形發光
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: bgColor.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: showGlow ? [
              BoxShadow(
                color: bgColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ] : null,
          ),
        );
      
      case 2: // 方形發光
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.2),
            border: Border.all(
              color: bgColor.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: showGlow ? [
              BoxShadow(
                color: bgColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ] : null,
          ),
        );
      
      case 3: // 六角形
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            boxShadow: showGlow ? [
              BoxShadow(
                color: bgColor.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ] : null,
          ),
          child: CustomPaint(
            painter: _HexagonBorderPainter(
              color: bgColor.withOpacity(0.5),
              strokeWidth: 3,
            ),
          ),
        );
      
      case 4: // 雙層邊框
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: bgColor.withOpacity(0.8),
              width: 2,
            ),
            boxShadow: showGlow ? [
              BoxShadow(
                color: bgColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ] : null,
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: bgColor.withOpacity(0.4),
                width: 2,
              ),
            ),
          ),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 六角形 Clipper
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    
    path.moveTo(w * 0.5, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.5, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 六角形邊框畫筆
class _HexagonBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _HexagonBorderPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final w = size.width * 0.85;
    final h = size.height * 0.85;
    final offsetX = (size.width - w) / 2;
    final offsetY = (size.height - h) / 2;
    
    final path = Path();
    path.moveTo(w * 0.5 + offsetX, offsetY);
    path.lineTo(w + offsetX, h * 0.25 + offsetY);
    path.lineTo(w + offsetX, h * 0.75 + offsetY);
    path.lineTo(w * 0.5 + offsetX, h + offsetY);
    path.lineTo(offsetX, h * 0.75 + offsetY);
    path.lineTo(offsetX, h * 0.25 + offsetY);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
