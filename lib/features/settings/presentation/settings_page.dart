import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'memory_page.dart';
import 'model_config/model_config_page.dart';
import '../../../../theme/theme.dart';

/// 设置页
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
        children: [
          // 用户信息卡片
          _buildProfileCard(context),

          const SizedBox(height: AppSpace.s6),

          // 模型设置组
          _buildSectionHeader('模型设置'),
          _buildSettingItem(
            context,
            icon: Icons.psychology,
            title: '模型配置',
            subtitle: 'Provider / API Key / 模型选择',
            trailing: const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textTertiary),
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
            subtitle: '已绑定',
            trailing: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusXS,
              ),
              child: const Text(
                '已连接',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.success,
                ),
              ),
            ),
            onTap: () {},
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
            onTap: () {},
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
            onTap: () {},
          ),

          const SizedBox(height: AppSpace.s6),

          // 通用设置组
          _buildSectionHeader('通用设置'),
          _buildSwitchItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: '深色模式',
            value: true,
            onChanged: (_) {},
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
          _buildSettingItem(context, icon: Icons.info_outline, title: '关于 MBot', onTap: () {}),
          _buildSettingItem(context, icon: Icons.help_outline, title: '帮助与反馈', onTap: () {}),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: '退出登录',
            titleColor: AppColors.error,
            onTap: () {},
          ),

          const SizedBox(height: AppSpace.s8),

          // 版本号
          Center(
            child: Text(
              'MBot Mobile v0.1.0',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: AppRadius.radiusFull,
            ),
            child: const Center(
              child: Text('🦞', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: AppSpace.s4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MBot 用户',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pro 会员 · 2026.12 到期',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textTertiary),
        ],
      ),
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
          color: AppColors.textTertiary,
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
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
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
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.textTertiary),
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
