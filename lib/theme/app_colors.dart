import 'package:flutter/material.dart';

/// MBot Mobile 色彩系统
/// 基于 DESIGN_SYSTEM.md v2.0
class AppColors {
  AppColors._();

  // ========== 主色调 — MBot 红 ==========
  static const Color primary = Color(0xFFFF3B30);
  static const Color primaryLight = Color(0xFFFF6961);
  static const Color primaryDark = Color(0xFFD62828);
  static const Color primaryGlow = Color(0x26FF3B30);

  // ========== 背景色系 ==========
  static const Color background = Color(0xFF0D1117);
  static const Color surface = Color(0xFF161B22);
  static const Color surfaceElevated = Color(0xFF1C2128);
  static const Color surfaceHighlight = Color(0xFF21262D);
  static const Color border = Color(0xFF30363D);

  // ========== 文字色系 ==========
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textTertiary = Color(0xFF6E7681);
  static const Color textInverse = Color(0xFF0D1117);
  static const Color textLink = Color(0xFF58A6FF);

  // ========== 功能色系 ==========
  static const Color success = Color(0xFF3FB950);
  static const Color successDark = Color(0xFF2EA043);
  static const Color warning = Color(0xFFD29922);
  static const Color error = Color(0xFFF85149);
  static const Color info = Color(0xFF58A6FF);

  // ========== 渐变色系 ==========
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient userBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient aiBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceHighlight, surfaceElevated],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceElevated, surface],
  );
}
