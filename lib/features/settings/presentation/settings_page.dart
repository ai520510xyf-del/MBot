import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/gateway_provider.dart';
import '../../../../core/providers/ws_connection_provider.dart';
import '../../../../core/services/gateway_service.dart';
import '../../../../theme/theme.dart';
import 'memory_page.dart';
import '../../about/presentation/about_page.dart';
import 'model_config/model_config_page.dart';

/// 本地 OpenClaw Gateway 地址
const String _localGatewayUrl = 'ws://127.0.0.1:78789';

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isConnecting = false;
  String _gatewayStatus = '未连接';
  StreamSubscription<GatewayConnectionState>? _statusSub;

  @override
  void initState() {
    super.initState();
    _autoConnectGateway();
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _autoConnectGateway() async {
    setState(() {
      _isConnecting = true;
      _gatewayStatus = '正在连接本地 Gateway...';
    });

    try {
      final gateway = ref.read(gatewayServiceProvider);

      await gateway.disconnect();

      _statusSub?.cancel();
      _statusSub = gateway.statusStream.listen((state) {
        if (mounted) {
          switch (state) {
            case GatewayConnectionState.connected:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '已连接 ✓  $_localGatewayUrl';
                ref.read(wsConnectionProvider.notifier).setConnected(true);
              });
              break;
            case GatewayConnectionState.failed:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '连接失败，请确认 OpenClaw 已启动';
                ref.read(wsConnectionProvider.notifier).setConnected(false);
              });
              break;
            case GatewayConnectionState.disconnected:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '已断开';
                ref.read(wsConnectionProvider.notifier).setConnected(false);
              });
              break;
            default:
              break;
          }
        }
      });

      await gateway.connect(_localGatewayUrl);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _gatewayStatus = '连接失败: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isConnected = ref.watch(wsConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
        children: [
          // Gateway 连接状态卡片
          _buildGatewayCard(isConnected),

          const SizedBox(height: AppSpace.s6),

          // 模型设置组
          _buildSectionHeader('模型设置'),
          _buildSettingItem(
            context,
            icon: Icons.psychology,
            title: '模型配置',
            subtitle: 'Provider / API Key / 模型选择',
            trailing: const Icon(
              Icons.chevron_right,
              size: 20,
              color: DarkColors.textTertiary,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelConfigPage()),
              );
            },
          ),

          const SizedBox(height: AppSpace.s6),

          // 通道设置组
          _buildSectionHeader('通道绑定'),
          _buildSettingItem(
            context,
            icon: Icons.wechat_outlined,
            title: '微信',
            subtitle: '未绑定',
            trailing: const Text(
              '去绑定',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.chat_outlined,
            title: 'QQ',
            subtitle: '未绑定',
            trailing: const Text(
              '去绑定',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.send_outlined,
            title: 'Telegram',
            subtitle: '未绑定',
            trailing: const Text(
              '去绑定',
              style: TextStyle(fontSize: 13, color: AppColors.primary),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),

          const SizedBox(height: AppSpace.s6),

          // 通用设置组
          _buildSectionHeader('通用设置'),
          _buildSettingItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: '主题模式',
            subtitle: _getThemeModeText(themeMode),
            trailing: const Icon(
              Icons.chevron_right,
              size: 20,
              color: DarkColors.textTertiary,
            ),
            onTap: () => _showThemeDialog(context, ref),
          ),
          _buildSwitchItem(
            context,
            icon: Icons.notifications_outlined,
            title: '消息通知',
            value: true,
            onChanged: (_) {},
          ),
          _buildSwitchItem(
            context,
            icon: Icons.lock_outline,
            title: '隐私模式',
            subtitle: '开启后使用端侧模型',
            value: false,
            onChanged: (_) {},
          ),

          const SizedBox(height: AppSpace.s6),

          // 数据管理组
          _buildSectionHeader('数据管理'),
          _buildSettingItem(
            context,
            icon: Icons.psychology_outlined,
            title: '记忆管理',
            subtitle: '管理 AI 学习的偏好和事实',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MemoryPage()),
              );
            },
          ),

          const SizedBox(height: AppSpace.s6),

          // 关于
          _buildSectionHeader('关于'),
          _buildSettingItem(
            context,
            icon: Icons.info_outline,
            title: '关于 MBot',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: '帮助与反馈',
            onTap: () {},
          ),

          const SizedBox(height: AppSpace.s8),

          // 版本号
          Center(
            child: Text(
              'MBot Mobile v0.2.0',
              style: const TextStyle(
                fontSize: 12,
                color: DarkColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGatewayCard(bool isConnected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(
          color: isConnected ? AppColors.success : DarkColors.border,
          width: isConnected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isConnected
                      ? AppColors.success.withValues(alpha: 0.15)
                      : _isConnecting
                          ? AppColors.info.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Icon(
                  _isConnecting
                      ? Icons.sync
                      : isConnected
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                  color: _isConnecting
                      ? AppColors.info
                      : isConnected
                          ? AppColors.success
                          : DarkColors.textTertiary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OpenClaw Gateway',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DarkColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _gatewayStatus,
                      style: TextStyle(
                        fontSize: 13,
                        color: isConnected ? AppColors.success : DarkColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // 连接状态指示灯
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isConnecting
                      ? AppColors.info
                      : isConnected
                          ? AppColors.success
                          : DarkColors.textTertiary,
                  shape: BoxShape.circle,
                  boxShadow: isConnected
                      ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.s3),

          // 地址信息
          Container(
            padding: const EdgeInsets.all(AppSpace.s3),
            decoration: BoxDecoration(
              color: DarkColors.surfaceElevated,
              borderRadius: AppRadius.radiusSM,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.dns_outlined,
                  size: 16,
                  color: DarkColors.textTertiary,
                ),
                const SizedBox(width: AppSpace.s2),
                Text(
                  _localGatewayUrl,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color: DarkColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          if (!isConnected && !_isConnecting) ...[
            const SizedBox(height: AppSpace.s3),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _autoConnectGateway,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('重新连接'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getThemeModeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.dark:
        return '深色模式';
      case AppThemeMode.light:
        return '浅色模式';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题模式'),
        content: Consumer(
          builder: (context, ref, _) {
            final currentMode = ref.watch(themeModeProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(context, icon: Icons.brightness_auto, title: '跟随系统', mode: AppThemeMode.system, currentMode: currentMode, ref: ref),
                _buildThemeOption(context, icon: Icons.dark_mode, title: '深色模式', mode: AppThemeMode.dark, currentMode: currentMode, ref: ref),
                _buildThemeOption(context, icon: Icons.light_mode, title: '浅色模式', mode: AppThemeMode.light, currentMode: currentMode, ref: ref),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, {required IconData icon, required String title, required AppThemeMode mode, required AppThemeMode currentMode, required WidgetRef ref}) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () async {
        await ref.read(themeModeProvider.notifier).setMode(mode);
        if (context.mounted) Navigator.pop(context);
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4, vertical: AppSpace.s2),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DarkColors.textTertiary)),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, String? subtitle, Widget? trailing, Color? titleColor, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      leading: Icon(icon, color: DarkColors.textSecondary),
      title: Text(title, style: TextStyle(fontSize: 15, color: titleColor ?? DarkColors.textPrimary)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 13, color: DarkColors.textTertiary)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: DarkColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(BuildContext context, {required IconData icon, required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      leading: Icon(icon, color: DarkColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 13, color: DarkColors.textTertiary)) : null,
      trailing: Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
    );
  }
}
