import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../theme/theme.dart';
import '../providers/model_config_provider.dart';

/// 模型配置页面
class ModelConfigPage extends ConsumerStatefulWidget {
  const ModelConfigPage({super.key});

  @override
  ConsumerState<ModelConfigPage> createState() => _ModelConfigPageState();
}

class _ModelConfigPageState extends ConsumerState<ModelConfigPage> {
  final _apiKeyController = TextEditingController();
  bool _isObscured = true;
  bool _isTesting = false;
  String? _testResult;

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
    final apiKey = prefs.getString('model_api_key') ?? '';
    final providerKey = prefs.getString('model_provider') ?? 'deepseek';
    final modelKey = prefs.getString('model_name') ?? 'deepseek-chat';
    
    setState(() {
      _apiKeyController.text = apiKey;
    });
    
    ref.read(modelConfigProvider.notifier).setProvider(providerKey);
    ref.read(modelConfigProvider.notifier).setModel(modelKey);
  }

  Future<void> _saveConfig() async {
    final config = ref.read(modelConfigProvider);
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('model_api_key', _apiKeyController.text);
    await prefs.setString('model_provider', config.provider);
    await prefs.setString('model_name', config.model);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('配置已保存'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_apiKeyController.text.isEmpty) {
      setState(() {
        _testResult = '请先输入 API Key';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      // TODO: 实际的 API 测试请求
      await Future.delayed(const Duration(seconds: 2));
      
      // 模拟测试结果
      final config = ref.read(modelConfigProvider);
      setState(() {
        _testResult = '✓ 连接成功！${config.provider} - ${config.model}';
      });
    } catch (e) {
      setState(() {
        _testResult = '✗ 连接失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(modelConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('模型配置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.s4),
        children: [
          // 说明卡片
          Container(
            padding: const EdgeInsets.all(AppSpace.s4),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: AppColors.border),
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
                    '配置您的 AI 模型 API Key 以使用对话功能',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpace.s6),

          // 服务商选择
          _buildSectionHeader('服务商'),
          _buildProviderSelector(config.provider),

          const SizedBox(height: AppSpace.s6),

          // 模型选择
          _buildSectionHeader('模型'),
          _buildModelSelector(config.provider, config.model),

          const SizedBox(height: AppSpace.s6),

          // API Key 输入
          _buildSectionHeader('API Key'),
          _buildApiKeyInput(),

          const SizedBox(height: AppSpace.s6),

          // 测试连接
          _buildSectionHeader('连接测试'),
          _buildTestButton(),

          if (_testResult != null) ...[
            const SizedBox(height: AppSpace.s4),
            _buildTestResult(),
          ],

          const SizedBox(height: AppSpace.s8),

          // 保存按钮
          FilledButton.icon(
            onPressed: _saveConfig,
            icon: const Icon(Icons.save),
            label: const Text('保存配置'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
            ),
          ),

          const SizedBox(height: AppSpace.s4),

          // 重置按钮
          OutlinedButton.icon(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('model_api_key');
              await prefs.remove('model_provider');
              await prefs.remove('model_name');
              _apiKeyController.clear();
              ref.read(modelConfigProvider.notifier).reset();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('配置已重置'),
                  ),
                );
              }
            },
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('重置配置'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.radiusMD,
              ),
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
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildProviderSelector(String currentProvider) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var provider in ModelProvider.values)
            _buildProviderItem(
              provider,
              provider == currentProvider,
            ),
        ],
      ),
    );
  }

  Widget _buildProviderItem(ModelProvider provider, bool isSelected) {
    final info = ModelProviderInfo.getInfo(provider);
    
    return InkWell(
      onTap: () {
        ref.read(modelConfigProvider.notifier).setProvider(provider.key);
        // 切换服务商时重置模型为默认
        ref.read(modelConfigProvider.notifier).setModel(info.defaultModel);
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
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              info.emoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelSelector(String provider, String currentModel) {
    final models = ModelProviderInfo.getModels(provider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentModel,
          isExpanded: true,
          dropdownColor: AppColors.surfaceElevated,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          items: models.map((model) {
            return DropdownMenuItem<String>(
              value: model['value'],
              child: Row(
                children: [
                  if (model['icon'] != null) ...[
                    Text(
                      model['icon']!,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: AppSpace.s2),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model['name']!),
                        if (model['description'] != null)
                          Text(
                            model['description']!,
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
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              ref.read(modelConfigProvider.notifier).setModel(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildApiKeyInput() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _apiKeyController,
        obscureText: _isObscured,
        maxLines: _isObscured ? 1 : 3,
        decoration: InputDecoration(
          hintText: '请输入 API Key',
          hintStyle: const TextStyle(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(AppSpace.s3),
          suffixIcon: IconButton(
            icon: Icon(
              _isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _isObscured = !_isObscured;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return OutlinedButton.icon(
      onPressed: _isTesting ? null : _testConnection,
      icon: _isTesting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : const Icon(Icons.wifi_outlined, size: 20),
      label: Text(_isTesting ? '测试中...' : '测试连接'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
      ),
    );
  }

  Widget _buildTestResult() {
    final isSuccess = _testResult?.startsWith('✓') ?? false;
    
    return Container(
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: isSuccess ? AppColors.success : AppColors.error,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppSpace.s2),
          Expanded(
            child: Text(
              _testResult!,
              style: TextStyle(
                fontSize: 14,
                color: isSuccess ? AppColors.successDark : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
