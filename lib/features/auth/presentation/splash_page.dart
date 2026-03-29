import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/gateway_service.dart';
import '../../../../core/providers/gateway_provider.dart';
import '../../../../core/providers/openclaw_env_provider.dart';
import '../../../../theme/theme.dart';

/// 本地 OpenClaw Gateway 地址
const String _localGatewayUrl = 'ws://127.0.0.1:78789';

/// 启动页 - 初始化环境 → 启动 Gateway → 连接 → 跳转主页
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
  String _subStatusText = '';
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

    // 动画完成后开始初始化
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _initAndConnect();
    });
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 完整初始化流程
  Future<void> _initAndConnect() async {
    final env = ref.read(openClawEnvProvider.notifier);

    // 监听环境状态变化，更新 UI
    ref.listen(openClawEnvProvider, (prev, next) {
      if (mounted && !_navigated) {
        setState(() {
          _statusText = _getStageTitle(next.stage);
          _subStatusText = next.message;
        });
      }
    });

    // Step 1: 初始化环境（proot + Node.js + OpenClaw）
    final envReady = await env.initialize();
    if (!envReady || !mounted) return;

    // Step 2: 启动 Gateway
    final gatewayStarted = await env.startGateway();
    if (!gatewayStarted || !mounted) return;

    // Step 3: 连接 Gateway WebSocket
    setState(() {
      _statusText = '正在连接 Gateway...';
      _subStatusText = _localGatewayUrl;
    });

    await _connectGateway();
  }

  Future<void> _connectGateway() async {
    try {
      final gateway = ref.read(gatewayServiceProvider);

      _statusSub?.cancel();
      _statusSub = gateway.statusStream.listen((state) {
        if (!mounted || _navigated) return;

        switch (state) {
          case GatewayConnectionState.connected:
            _navigateToHome();
          case GatewayConnectionState.failed:
            setState(() {
              _statusText = '连接失败，重试中...';
            });
          case GatewayConnectionState.disconnected:
            setState(() {
              _statusText = '已断开，重连中...';
            });
          default:
            break;
        }
      });

      await gateway.connect(_localGatewayUrl);
    } catch (e) {
      if (mounted && !_navigated) {
        setState(() {
          _statusText = '连接失败';
          _subStatusText = e.toString();
        });
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

  String _getStageTitle(EnvStage stage) {
    switch (stage) {
      case EnvStage.idle:
        return '准备中...';
      case EnvStage.termux:
        return '检查环境...';
      case EnvStage.proot:
        return '配置 Linux 环境...';
      case EnvStage.distro:
        return '安装 Ubuntu...';
      case EnvStage.nodejs:
        return '安装 Node.js...';
      case EnvStage.openclaw:
        return '安装 OpenClaw...';
      case EnvStage.config:
        return '配置 OpenClaw...';
      case EnvStage.done:
        return '初始化完成';
      case EnvStage.error:
        return '初始化失败';
    }
  }

  @override
  Widget build(BuildContext context) {
    final envState = ref.watch(openClawEnvProvider);

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
                      // Logo
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

                      const Text(
                        '口袋里的 AI Agent',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: AppSpace.s8),

                      // 状态
                      Text(
                        _statusText,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (_subStatusText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          _subStatusText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],

                      // 进度条
                      const SizedBox(height: AppSpace.s6),
                      SizedBox(
                        width: 200,
                        child: LinearProgressIndicator(
                          value: envState.stage == EnvStage.done
                              ? 1.0
                              : envState.stage == EnvStage.error
                                  ? 0
                                  : null, // indeterminate
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
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
