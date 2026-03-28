import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _loadSavedTheme();
    return AppThemeMode.dark;
  }

  /// 从本地存储加载主题设置
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMode = prefs.getString(_key);
    if (savedMode != null) {
      state = AppThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => AppThemeMode.dark,
      );
    }
  }

  /// 更新主题模式
  Future<void> setMode(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  /// 切换深色模式
  Future<void> toggleDark() async {
    final newMode = state == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setMode(newMode);
  }

  /// 切换到跟随系统
  Future<void> setSystem() async {
    await setMode(AppThemeMode.system);
  }
}
