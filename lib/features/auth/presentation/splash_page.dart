import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/gateway_service.dart';
import '../../../../core/providers/gateway_provider.dart';
import '../../../../theme/theme.dart';

/// 本地 OpenClaw Gateway 地址
const String _localGatewayUrl = 'ws://127.0.0.1:78789';

/// 启动页 - 自动连接本地 Gateway 后跳转主页
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText = '正在启动...';
  StreamSubscription<GatewayConnectionState>? _statusSub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();

    // 动画完成后开始连接 Gateway
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _connectGateway();
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _connectGateway() async {
    setState(() => _statusText = '正在连接 OpenClaw Gateway...');

    try {
      final gateway = ref.read(gatewayServiceProvider);

      _statusSub = gateway.statusStream.listen((state) {
        if (!mounted || _navigated) return;

        switch (state) {
          case GatewayConnectionState.connected:
            _navigateToHome();
          case GatewayConnectionState.failed:
            setState(() => _statusText = 'Gateway 连接失败，正在重试...');
          case GatewayConnectionState.disconnected:
            setState(() => _statusText = 'Gateway 已断开，正在重连...');
          default:
            break;
        }
      });

      await gateway.connect(_localGatewayUrl);
    } catch (e) {
      if (mounted && !_navigated) {
        setState(() => _statusText = '连接失败，5秒后重试...');
        // 5秒后重试
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_navigated) _connectGateway();
        });
      }
    }
  }

  void _navigateToHome() {
    if (_navigated) return;
    _navigated = true;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surface],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo 容器
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🦞', style: TextStyle(fontSize: 60)),
                        ),
                      ),
                      const SizedBox(height: AppSpace.s6),

                      // 应用名称
                      const Text(
                        'MBot',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s2),

                      // 副标题
                      const Text(
                        '口袋里的 AI Agent',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s8),

                      // 状态文字
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textTertiary,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s4),

                      // 加载指示器
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
