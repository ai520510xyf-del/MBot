import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/theme.dart';
import '../../../../core/providers/openclaw_env_provider.dart';
import '../../../../core/services/openclaw_config.dart';

/// 模型配置页面
class ModelConfigPage extends ConsumerStatefulWidget {
  const ModelConfigPage({super.key});

  @override
  ConsumerState<ModelConfigPage> createState() => _ModelConfigPageState();
}

class _ModelConfigPageState extends ConsumerState<ModelConfigPage> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isSaving = false;
  String? _statusMessage;
  bool? _isSuccess;

  String _selectedProvider = OpenClawConfig.defaultProvider;
  String _selectedModel = OpenClawConfig.defaultModel;

  @override
  void initState() {
    super.initState();
    _loadSavedConfig();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('oc_api_key') ?? '';
    final provider = prefs.getString('oc_provider') ?? OpenClawConfig.defaultProvider;
    final model = prefs.getString('oc_model') ?? OpenClawConfig.defaultModel;

    setState(() {
      _apiKeyController.text = apiKey;
      _selectedProvider = provider;
      _selectedModel = model;
    });
  }

  Future<void> _saveConfig() async {
    if (_apiKeyController.text.isEmpty) {
      setState(() {
        _statusMessage = '请输入 API Key';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      // 保存到 OpenClaw 配置
      final env = ref.read(openClawEnvProvider.notifier);
      await env.updateApiKey(_apiKeyController.text.trim());

      // 保存到本地偏好
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('oc_api_key', _apiKeyController.text.trim());
      await prefs.setString('oc_provider', _selectedProvider);
      await prefs.setString('oc_model', _selectedModel);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _statusMessage = '✓ 配置已保存';
          _isSuccess = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _statusMessage = '✗ 保存失败: $e';
          _isSuccess = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('模型配置')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.s4),
        children: [
          // 说明卡片
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: DarkColors.surfaceElevated,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: DarkColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpace.s3),
                const Expanded(
                  child: Text(
                    '配置 AI 模型的 API Key 以使用对话功能。\n推荐使用智谱 GLM（免费额度充足）。',
                    style: TextStyle(
                      fontSize: 13,
                      color: DarkColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s6),

          // Provider 选择
          _buildSectionHeader('模型服务商'),
          _buildProviderSelector(),

          const SizedBox(height: AppSpace.s6),

          // 模型选择
          _buildSectionHeader('模型'),
          _buildModelSelector(),

          const SizedBox(height: AppSpace.s6),

          // API Key
          _buildSectionHeader('API Key'),
          _buildApiKeyInput(),

          const SizedBox(height: AppSpace.s6),

          // 获取 API Key 链接
          _buildApiKeyHelp(),

          const SizedBox(height: AppSpace.s6),

          // 状态消息
          if (_statusMessage != null) _buildStatusMessage(),

          const SizedBox(height: AppSpace.s8),

          // 保存按钮
          FilledButton.icon(
            onPressed: _isSaving ? null : _saveConfig,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save),
            label: Text(_isSaving ? '保存中...' : '保存配置'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s3),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProviderSelector() {
    final providers = OpenClawConfig.supportedProviders;
    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: DarkColors.border),
      ),
      child: Column(
        children: providers.map((p) {
          final isSelected = p['id'] == _selectedProvider;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedProvider = p['id']!;
                // 切换 provider 时重置模型
                _selectedModel = OpenClawConfig.defaultModel;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpace.s3),
              margin: const EdgeInsets.only(bottom: AppSpace.s2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: AppRadius.radiusSM,
                border: Border.all(
                  color: isSelected ? AppColors.primary : DarkColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(p['emoji']!, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Text(
                      p['name']!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : DarkColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppColors.primary),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModelSelector() {
    final models = OpenClawConfig.getModels(_selectedProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: DarkColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: models.any((m) => m['id'] == _selectedModel) ? _selectedModel : models.first['id'],
          isExpanded: true,
          dropdownColor: DarkColors.surfaceElevated,
          style: const TextStyle(fontSize: 15, color: DarkColors.textPrimary),
          items: models.map((model) {
            return DropdownMenuItem<String>(
              value: model['id'],
              child: Text(model['name']!),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedModel = value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return Container(
      decoration: BoxDecoration(
        color: DarkColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: DarkColors.border),
      ),
      child: TextField(
        controller: _apiKeyController,
        obscureText: _isObscured,
        maxLines: _isObscured ? 1 : 3,
        decoration: InputDecoration(
          hintText: '请输入 API Key',
          hintStyle: const TextStyle(color: DarkColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpace.s3),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: DarkColors.textSecondary,
            ),
            onPressed: () => setState(() => _isObscured = !_isObscured),
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeyHelp() {
    final url = _selectedProvider == 'zai'
        ? 'https://open.bigmodel.cn'
        : _selectedProvider == 'deepseek'
            ? 'https://platform.deepseek.com'
            : 'https://dashscope.console.aliyun.com';

    return InkWell(
      onTap: () {
        // TODO: 打开浏览器
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpace.s3),
        decoration: BoxDecoration(
          color: DarkColors.surface,
          borderRadius: AppRadius.radiusMD,
        ),
        child: Row(
          children: [
            const Icon(Icons.open_in_new, size: 16, color: AppColors.primary),
            const SizedBox(width: AppSpace.s2),
            Expanded(
              child: Text(
                '前往 $url 获取 API Key',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: (_isSuccess ?? false)
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: (_isSuccess ?? false) ? AppColors.success : AppColors.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            (_isSuccess ?? false) ? Icons.check_circle_outline : Icons.error_outline,
            color: (_isSuccess ?? false) ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                fontSize: 14,
                color: (_isSuccess ?? false) ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
