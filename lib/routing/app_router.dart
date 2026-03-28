import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/providers/root_nav_provider.dart';
import '../features/auth/presentation/splash_page.dart';
import '../features/conversations/presentation/conversation_list_page.dart';
import '../features/chat/presentation/chat_page.dart';
import '../features/skills/presentation/skill_market_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../theme/theme.dart';

/// Route paths
class AppRoutes {
  static const String splash = '/splash';
  static const String home = '/';
  static const String skills = '/skills';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String chat = '/chat/:id';
}

/// GoRouter 配置
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // 启动页
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SplashPage()),
      ),

      // 带底部导航的 Shell Route
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ConversationListPage()),
          ),
          GoRoute(
            path: AppRoutes.skills,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SkillMarketPage()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SettingsPage()),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DashboardPage()),
          ),
        ],
      ),
      // 聊天页 — 不带底部导航
      GoRoute(
        path: AppRoutes.chat,
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['id'] ?? '';
          return MaterialPage(child: ChatPage(chatId: chatId));
        },
      ),
    ],
  );
});

/// 带底部导航栏的 Scaffold
class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget child;

  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  DateTime? _lastPressedTime;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return PopScope(
      canPop: currentIndex == 0, // 只有在首页才能 pop
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // 在非首页时，返回首页
        if (currentIndex != 0) {
          ref.read(goRouterProvider).go(AppRoutes.home);
          return;
        }

        // 在首页时，双击退出
        final now = DateTime.now();
        if (_lastPressedTime == null ||
            now.difference(_lastPressedTime!) > const Duration(seconds: 2)) {
          _lastPressedTime = now;
          _showExitToast();
        } else {
          // 退出应用
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, ref),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: '对话',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.widgets_outlined),
              activeIcon: Icon(Icons.widgets),
              label: '技能',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: '仪表盘',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: '设置',
            ),
          ],
        ),
      ),
    );
  }

  void _showExitToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('再按一次退出应用'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/chat')) return -1;
    if (location.startsWith(AppRoutes.skills)) return 1;
    if (location.startsWith(AppRoutes.dashboard)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0;
  }

  void _onItemTapped(int index, WidgetRef ref) {
    ref.read(rootNavIndexProvider.notifier).setIndex(index);
    switch (index) {
      case 0:
        ref.read(goRouterProvider).go(AppRoutes.home);
      case 1:
        ref.read(goRouterProvider).go(AppRoutes.skills);
      case 2:
        ref.read(goRouterProvider).go(AppRoutes.dashboard);
      case 3:
        ref.read(goRouterProvider).go(AppRoutes.settings);
    }
  }
}
