import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题模式枚举
enum AppThemeMode {
  /// 跟随系统
  system,

  /// 深色模式
  dark,

  /// 浅色模式
  light,
}

/// 主题设置 Provider
final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.dark;
});
