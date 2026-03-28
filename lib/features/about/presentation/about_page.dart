import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme/theme.dart';

/// 关于页面
class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  bool _isCheckingUpdate = false;
  String? _updateStatus;

  static const String _version = '1.0.0';
  static const String _buildNumber = '1';
  static const String _githubUrl = 'https://github.com/your-org/mbot-mobile';
  static const String _privacyPolicyUrl = 'https://mbot.app/privacy';
  static const String _termsUrl = 'https://mbot.app/terms';

  Future<void> _checkForUpdates() async {
    setState(() {
      _isCheckingUpdate = true;
      _updateStatus = null;
    });

    try {
      // TODO: 实现实际的版本检查
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _updateStatus = '已是最新版本';
      });
    } catch (e) {
      setState(() {
        _updateStatus = '检查失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isCheckingUpdate = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于 MBot'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.s6),
        children: [
          // Logo 和 App 名称
          Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('🦞', style: TextStyle(fontSize: 50)),
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              const Text(
                'MBot Mobile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpace.s1),
              const Text(
                '口袋里的 AI Agent',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpace.s4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: AppSpace.s1,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: AppRadius.radiusMD,
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'v$_version (+$_buildNumber)',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpace.s8),

          // 功能说明
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.stars_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Text(
                      '核心功能',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s3),
                _buildFeatureItem('💬', '智能对话', '支持多模型 AI 对话'),
                _buildFeatureItem('🧠', '记忆系统', '跨会话上下文记忆'),
                _buildFeatureItem('🔌', '通道绑定', '支持微信/QQ/Telegram'),
                _buildFeatureItem('📦', '技能扩展', '5000+ 技能生态'),
                _buildFeatureItem('🔒', '隐私保护', '本地运行，数据不上传'),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s6),

          // 检查更新
          OutlinedButton.icon(
            onPressed: _isCheckingUpdate ? null : _checkForUpdates,
            icon: _isCheckingUpdate
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : const Icon(Icons.system_update_outlined, size: 20),
            label: Text(_isCheckingUpdate ? '检查中...' : '检查更新'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
            ),
          ),

          if (_updateStatus != null) ...[
            const SizedBox(height: AppSpace.s3),
            Text(
              _updateStatus!,
              style: TextStyle(
                fontSize: 13,
                color: _updateStatus!.startsWith('检查失败')
                    ? AppColors.error
                    : AppColors.success,
              ),
            ),
          ],

          const SizedBox(height: AppSpace.s6),

          // 链接
          _buildSectionHeader('链接'),
          _buildLinkItem(
            icon: Icons.code_outlined,
            title: 'GitHub 开源',
            subtitle: _githubUrl,
            onTap: () => _launchUrl(_githubUrl),
          ),
          _buildLinkItem(
            icon: Icons.privacy_tip_outlined,
            title: '隐私政策',
            subtitle: _privacyPolicyUrl,
            onTap: () => _launchUrl(_privacyPolicyUrl),
          ),
          _buildLinkItem(
            icon: Icons.gavel_outlined,
            title: '服务条款',
            subtitle: _termsUrl,
            onTap: () => _launchUrl(_termsUrl),
          ),

          const SizedBox(height: AppSpace.s6),

          // 团队信息
          _buildSectionHeader('团队'),
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MBot Team',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpace.s2),
                const Text(
                  '由 AI 驱动的下一代智能助手',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpace.s3),
                const Text(
                  '核心技术',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  '• OpenClaw Gateway\n• Flutter 3.x\n• Riverpod 2.x\n• Drift (SQLite)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s6),

          // 开源许可
          _buildLinkItem(
            icon: Icons.description_outlined,
            title: '开源许可',
            subtitle: '查看使用的开源库',
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'MBot Mobile',
                applicationVersion: 'v$_version',
              );
            },
          ),

          const SizedBox(height: AppSpace.s8),

          // 版权信息
          Center(
            child: Column(
              children: [
                Text(
                  '© 2026 MBot Team',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  'Made with ❤️ for AI',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s1),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s2),
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

  Widget _buildLinkItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(
        Icons.open_in_new,
        size: 18,
        color: AppColors.textTertiary,
      ),
      onTap: onTap,
    );
  }
}
