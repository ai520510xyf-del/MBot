import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// MBot Mobile - AI Agent 移动端
///
/// 一个基于 Flutter 的移动应用，集成内嵌 Gateway 和云端 AI 模型
void main() {
  runApp(
    const ProviderScope(
      child: MBotMobileApp(),
    ),
  );
}

/// 应用根组件
class MBotMobileApp extends ConsumerWidget {
  const MBotMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      // 应用标题
      title: 'MBot Mobile',

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getFlutterThemeMode(themeMode),

      // 路由配置
      routerConfig: router,

      // 调试横幅
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeMode _getFlutterThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.light:
        return ThemeMode.light;
    }
  }
}
