import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

/// 主题模式枚举
enum AppThemeMode {
  /// 跟随系统
  system,

  /// 深色模式
  dark,

  /// 浅色模式
  light,
}

/// 主题设置 Notifier
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  AppThemeMode build() {
    return AppThemeMode.dark;
  }

  /// 更新主题模式
  void setMode(AppThemeMode mode) {
    state = mode;
  }

  /// 切换深色模式
  void toggleDark() {
    state = state == AppThemeMode.dark ? AppThemeMode.light : AppThemeMode.dark;
  }
}
