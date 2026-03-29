import 'dart:convert';
import 'dart:io';

/// OpenClaw 配置管理
///
/// 生成手机端的 openclaw.json 配置文件
class OpenClawConfig {
  /// 默认模型 Provider（智谱 GLM）
  static const String defaultProvider = 'zai';
  static const String defaultModel = 'glm-5-turbo';
  static const String defaultBaseUrl = 'https://open.bigmodel.cn/api/anthropic';
  static const String defaultApiType = 'anthropic-messages';

  /// 生成默认配置 JSON
  static Map<String, dynamic> generateConfig({
    String? apiKey,
    String provider = defaultProvider,
    String model = defaultModel,
  }) {
    return {
      'models': {
        'mode': 'merge',
        'providers': {
          provider: {
            'baseUrl': defaultBaseUrl,
            'apiKey': apiKey ?? '',
            'api': defaultApiType,
            'models': getModels(provider),
          },
        },
      },
      'agents': {
        'defaults': {
          'model': {
            'primary': '$provider/$model',
          },
          'workspace': 'openclaw_workspace',
          'bootstrapMaxChars': 20000,
          'bootstrapTotalMaxChars': 100000,
          'compaction': {'mode': 'safeguard'},
          'maxConcurrent': 2,
          'sandbox': {'mode': 'off'},
        },
        'list': [
          {'id': 'main'},
        ],
      },
    };
  }

  /// 写入配置文件
  static Future<void> writeConfig(String configDir, {
    String? apiKey,
    String provider = defaultProvider,
    String model = defaultModel,
  }) async {
    final config = generateConfig(
      apiKey: apiKey,
      provider: provider,
      model: model,
    );

    final configFile = File('$configDir/openclaw.json');
    await configFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(config),
    );
  }

  /// 更新 API Key
  static Future<void> updateApiKey(String configDir, String apiKey) async {
    final configFile = File('$configDir/openclaw.json');
    if (!await configFile.exists()) return;

    final content = await configFile.readAsString();
    final config = json.decode(content) as Map<String, dynamic>;

    final models = config['models'] as Map<String, dynamic>?;
    final providers = models?['providers'] as Map<String, dynamic>?;
    if (providers != null && providers.containsKey(defaultProvider)) {
      (providers[defaultProvider] as Map<String, dynamic>)['apiKey'] = apiKey;
    }

    await configFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(config),
    );
  }

  /// 获取可用模型列表
  static List<Map<String, String>> getModels(String provider) {
    switch (provider) {
      case 'zai':
        return [
          {'id': 'glm-5-turbo', 'name': 'GLM-5-Turbo'},
          {'id': 'glm-5', 'name': 'GLM-5'},
          {'id': 'glm-4.7', 'name': 'GLM-4.7'},
          {'id': 'glm-4.6', 'name': 'GLM-4.6'},
          {'id': 'glm-4.5-air', 'name': 'GLM-4.5-Air'},
          {'id': 'glm-4.5', 'name': 'GLM-4.5'},
        ];
      case 'deepseek':
        return [
          {'id': 'deepseek-chat', 'name': 'DeepSeek Chat'},
          {'id': 'deepseek-coder', 'name': 'DeepSeek Coder'},
        ];
      case 'qwen':
        return [
          {'id': 'qwen-max', 'name': 'Qwen-Max'},
          {'id': 'qwen-plus', 'name': 'Qwen-Plus'},
          {'id': 'qwen-turbo', 'name': 'Qwen-Turbo'},
        ];
      default:
        return [
          {'id': 'glm-5-turbo', 'name': 'GLM-5-Turbo'},
        ];
    }
  }

  /// 获取支持的 Provider 列表
  static List<Map<String, String>> get supportedProviders => [
    {'id': 'zai', 'name': '智谱 GLM', 'emoji': '🧠'},
    {'id': 'deepseek', 'name': 'DeepSeek', 'emoji': '🔥'},
    {'id': 'qwen', 'name': '通义千问', 'emoji': '💬'},
  ];
}
