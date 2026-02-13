import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

/// Avatar 數據模型
class AvatarData {
  final String faceEmoji;      // 😄😎🤓 等
  final int backgroundColor;   // Color 的 int 值
  final String accessoryEmoji;  // 👑🎩 等，可以是空字串
  final int frameStyle;         // 0=無, 1=圓形發光, 2=方形發光, 3=六角形, 4=雙層

  // 可選的 emoji 列表
  static const List<String> faceEmojis = [
    '😄', '😎', '🤓', '😊', '🥳', '🤩', '😏', '🧐', '😇', '🤗'
  ];

  static const List<String> accessoryEmojis = [
    '', // 無配飾選項
    '👑', '🎩', '🧢', '🎓', '💎', '🌟', '🔥', '⚡', '🎯'
  ];

  // 背景色選項（霓虹紫、粉紅、青色、金黃、綠色、橙色、藍色、紅色、白色、灰色）
  static const List<Color> backgroundColors = [
    Color(0xFF6C63FF), // 霓虹紫
    Color(0xFFFF6B9D), // 粉紅
    Color(0xFF38B6FF), // 青色
    Color(0xFFFFD700), // 金黃
    Color(0xFF00D4AA), // 綠色
    Color(0xFFFF8C42), // 橙色
    Color(0xFF5B8DEF), // 藍色
    Color(0xFFFF6B6B), // 紅色
    Color(0xFFE0E0E0), // 白色
    Color(0xFF6B7280), // 灰色
  ];

  static const List<String> frameStyleNames = [
    '無邊框',
    '圓形發光',
    '方形發光',
    '六角形',
    '雙層邊框'
  ];

  const AvatarData({
    required this.faceEmoji,
    required this.backgroundColor,
    required this.accessoryEmoji,
    required this.frameStyle,
  });

  /// 預設頭像
  static AvatarData get defaultAvatar => const AvatarData(
    faceEmoji: '😊',
    backgroundColor: 0xFF6C63FF, // 霓虹紫
    accessoryEmoji: '',
    frameStyle: 1, // 圓形發光
  );

  /// 隨機生成頭像
  static AvatarData randomAvatar() {
    final random = Random();
    return AvatarData(
      faceEmoji: faceEmojis[random.nextInt(faceEmojis.length)],
      backgroundColor: backgroundColors[random.nextInt(backgroundColors.length)].value,
      accessoryEmoji: accessoryEmojis[random.nextInt(accessoryEmojis.length)],
      frameStyle: random.nextInt(frameStyleNames.length),
    );
  }

  /// 從 JSON 反序列化
  factory AvatarData.fromJson(Map<String, dynamic> json) {
    return AvatarData(
      faceEmoji: json['faceEmoji'] as String? ?? '😊',
      backgroundColor: json['backgroundColor'] as int? ?? 0xFF6C63FF,
      accessoryEmoji: json['accessoryEmoji'] as String? ?? '',
      frameStyle: json['frameStyle'] as int? ?? 1,
    );
  }

  /// 序列化為 JSON
  Map<String, dynamic> toJson() {
    return {
      'faceEmoji': faceEmoji,
      'backgroundColor': backgroundColor,
      'accessoryEmoji': accessoryEmoji,
      'frameStyle': frameStyle,
    };
  }

  /// 從 JSON 字串反序列化
  static AvatarData fromJsonString(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return AvatarData.fromJson(json);
    } catch (e) {
      return defaultAvatar;
    }
  }

  /// 序列化為 JSON 字串
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// 複製並修改
  AvatarData copyWith({
    String? faceEmoji,
    int? backgroundColor,
    String? accessoryEmoji,
    int? frameStyle,
  }) {
    return AvatarData(
      faceEmoji: faceEmoji ?? this.faceEmoji,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accessoryEmoji: accessoryEmoji ?? this.accessoryEmoji,
      frameStyle: frameStyle ?? this.frameStyle,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarData &&
          runtimeType == other.runtimeType &&
          faceEmoji == other.faceEmoji &&
          backgroundColor == other.backgroundColor &&
          accessoryEmoji == other.accessoryEmoji &&
          frameStyle == other.frameStyle;

  @override
  int get hashCode =>
      faceEmoji.hashCode ^
      backgroundColor.hashCode ^
      accessoryEmoji.hashCode ^
      frameStyle.hashCode;
}
