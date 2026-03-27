import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'routing/app_router.dart';
import 'theme/app_theme.dart';

/// QClaw Mobile - 口袋里的小龙虾
///
/// 一个基于 Flutter 的移动应用，集成内嵌 Gateway 和云端 AI 模型
void main() {
  runApp(
    const ProviderScope(
      child: QClawMobileApp(),
    ),
  );
}

/// 应用根组件
class QClawMobileApp extends ConsumerWidget {
  const QClawMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      // 应用标题
      title: 'QClaw Mobile',

      // 主题配置
      theme: AppTheme.darkTheme,

      // 路由配置
      routerConfig: router,

      // 调试横幅
      debugShowCheckedModeBanner: false,
    );
  }
}
