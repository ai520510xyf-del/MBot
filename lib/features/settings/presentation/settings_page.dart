import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/gateway_provider.dart';
import '../../../../core/services/gateway_service.dart';
import '../../../../theme/theme.dart';
import 'memory_page.dart';
import '../../about/presentation/about_page.dart';
import 'model_config/model_config_page.dart';

/// Gateway 连接配置 Provider
final gatewayUrlProvider = StateProvider<String>((ref) => '');

/// Gateway 连接状态 Provider
final gatewayConnectedProvider = StateProvider<bool>((ref) => false);

/// 设置页
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _gatewayUrlController = TextEditingController();
  bool _isConnecting = false;
  String? _gatewayStatus;

  @override
  void initState() {
    super.initState();
    _loadGatewayConfig();
  }

  @override
  void dispose() {
    _gatewayUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadGatewayConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('gateway_url') ?? '';
    if (mounted) {
      setState(() {
        _gatewayUrlController.text = url;
        ref.read(gatewayUrlProvider.notifier).state = url;
      });
      // 如果有保存的 URL，自动连接
      if (url.isNotEmpty) {
        _connectGateway(url);
      }
    }
  }

  Future<void> _connectGateway(String url) async {
    setState(() {
      _isConnecting = true;
      _gatewayStatus = '正在连接...';
    });

    try {
      final gateway = ref.read(gatewayServiceProvider);

      // 先断开旧连接
      await gateway.disconnect();

      // 监听状态变化
      gateway.statusStream.listen((state) {
        if (mounted) {
          switch (state) {
            case GatewayConnectionState.connected:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '已连接 ✓';
                ref.read(gatewayConnectedProvider.notifier).state = true;
              });
              break;
            case GatewayConnectionState.failed:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '连接失败 ✗';
                ref.read(gatewayConnectedProvider.notifier).state = false;
              });
              break;
            case GatewayConnectionState.disconnected:
              setState(() {
                _isConnecting = false;
                _gatewayStatus = '已断开';
                ref.read(gatewayConnectedProvider.notifier).state = false;
              });
              break;
            default:
              break;
          }
        }
      });

      await gateway.connect(url);

      // 保存 URL
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gateway_url', url);
      ref.read(gatewayUrlProvider.notifier).state = url;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnecting = false;
          _gatewayStatus = '连接失败: $e';
        });
      }
    }
  }

  Future<void> _disconnectGateway() async {
    final gateway = ref.read(gatewayServiceProvider);
    await gateway.disconnect();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gateway_url');

    setState(() {
      _gatewayStatus = '已断开';
      ref.read(gatewayConnectedProvider.notifier).state = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isConnected = ref.watch(gatewayConnectedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
        children: [
          // Gateway 连接卡片
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
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusFull,
                ),
                child: Icon(
                  isConnected ? Icons.cloud_done : Icons.cloud_outlined,
                  color: isConnected ? AppColors.success : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gateway 连接',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DarkColors.textPrimary,
                      ),
                    ),
                    if (_gatewayStatus != null)
                      Text(
                        _gatewayStatus!,
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
                  color: isConnected ? AppColors.success : DarkColors.textTertiary,
                  shape: BoxShape.circle,
                  boxShadow: isConnected
                      ? [BoxShadow(color: AppColors.success.withValues(alpha: 0.5), blurRadius: 6)]
                      : null,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.s4),

          // Gateway URL 输入
          TextField(
            controller: _gatewayUrlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'wss://your-gateway-url/ws',
              hintStyle: const TextStyle(color: DarkColors.textTertiary, fontSize: 14),
              border: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide(color: DarkColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: BorderSide(color: DarkColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.radiusMD,
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s3,
                vertical: AppSpace.s3,
              ),
              suffixIcon: _gatewayUrlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: DarkColors.textTertiary),
                      onPressed: () {
                        setState(() {
                          _gatewayUrlController.clear();
                        });
                      },
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: AppSpace.s3),

          // 操作按钮
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _isConnecting || _gatewayUrlController.text.isEmpty
                      ? null
                      : () => _connectGateway(_gatewayUrlController.text.trim()),
                  icon: _isConnecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.link, size: 18),
                  label: Text(isConnected ? '重新连接' : '连接'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
                  ),
                ),
              ),
              if (isConnected) ...[
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _disconnectGateway,
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('断开'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
                _buildThemeOption(
                  context,
                  icon: Icons.brightness_auto,
                  title: '跟随系统',
                  mode: AppThemeMode.system,
                  currentMode: currentMode,
                  ref: ref,
                ),
                _buildThemeOption(
                  context,
                  icon: Icons.dark_mode,
                  title: '深色模式',
                  mode: AppThemeMode.dark,
                  currentMode: currentMode,
                  ref: ref,
                ),
                _buildThemeOption(
                  context,
                  icon: Icons.light_mode,
                  title: '浅色模式',
                  mode: AppThemeMode.light,
                  currentMode: currentMode,
                  ref: ref,
                ),
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

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required AppThemeMode mode,
    required AppThemeMode currentMode,
    required WidgetRef ref,
  }) {
    final isSelected = mode == currentMode;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: () async {
        await ref.read(themeModeProvider.notifier).setMode(mode);
        if (context.mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s2,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: DarkColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      leading: Icon(icon, color: DarkColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: titleColor ?? DarkColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: DarkColors.textTertiary,
              ),
            )
          : null,
      trailing:
          trailing ??
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: DarkColors.textTertiary,
          ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      leading: Icon(icon, color: DarkColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: DarkColors.textTertiary,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}
