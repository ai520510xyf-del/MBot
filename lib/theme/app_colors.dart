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

  // ========== 语义色别名（默认使用深色主题值）==========
  static const Color background = DarkColors.background;
  static const Color surface = DarkColors.surface;
  static const Color surfaceElevated = DarkColors.surfaceElevated;
  static const Color surfaceHighlight = DarkColors.surfaceHighlight;
  static const Color border = DarkColors.border;
  static const Color textPrimary = DarkColors.textPrimary;
  static const Color textSecondary = DarkColors.textSecondary;
  static const Color textTertiary = DarkColors.textTertiary;
  static const Color textInverse = DarkColors.textInverse;
  static const Color textLink = DarkColors.textLink;
  static const LinearGradient aiBubbleGradient = DarkColors.aiBubbleGradient;
  static const LinearGradient cardGradient = DarkColors.cardGradient;
  static const LinearGradient disabledGradient = DarkColors.disabledGradient;
}

/// 深色主题色彩
class DarkColors {
  DarkColors._();

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

  // ========== 气泡渐变 ==========
  static const LinearGradient aiBubbleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceHighlight, surfaceElevated],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceElevated, background],
  );

  static const LinearGradient disabledGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [textTertiary, border],
  );
}

/// 浅色主题色彩
class LightColors {
  LightColors._();

  // ========== 背景色系 ==========
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF5F5F5);
  static const Color surfaceHighlight = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);

  // ========== 文字色系 ==========
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textTertiary = Color(0xFF999999);
  static const Color textInverse = Color(0xFFFFFFFF);
  static const Color textLink = Color(0xFF0066CC);

  // ========== 气泡渐变 ==========
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

  static const LinearGradient disabledGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [textTertiary, border],
  );
}
