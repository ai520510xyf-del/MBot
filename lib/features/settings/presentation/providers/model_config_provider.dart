import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'model_config_provider.g.dart';
part 'model_config_provider.freezed.dart';

/// 模型提供商枚举
enum ModelProvider {
  deepseek,
  glm,
  qwen,
  minimax,
}

/// 模型提供商信息
class ModelProviderInfo {
  final String key;
  final String name;
  final String emoji;
  final String description;
  final String defaultModel;

  const ModelProviderInfo({
    required this.key,
    required this.name,
    required this.emoji,
    required this.description,
    required this.defaultModel,
  });

  static const Map<String, ModelProviderInfo> _info = {
    'deepseek': ModelProviderInfo(
      key: 'deepseek',
      name: 'DeepSeek',
      emoji: '🔥',
      description: '高质量国产大模型',
      defaultModel: 'deepseek-chat',
    ),
    'glm': ModelProviderInfo(
      key: 'glm',
      name: '智谱 GLM',
      emoji: '🧠',
      description: '清华大学知识工程实验室',
      defaultModel: 'glm-4-plus',
    ),
    'qwen': ModelProviderInfo(
      key: 'qwen',
      name: '通义千问',
      emoji: '💬',
      description: '阿里云大语言模型',
      defaultModel: 'qwen-plus',
    ),
    'minimax': ModelProviderInfo(
      key: 'minimax',
      name: 'MiniMax',
      emoji: '⚡',
      description: '专注于AI对话和语音',
      defaultModel: 'abab6.5s-chat',
    ),
  };

  static ModelProviderInfo getInfo(ModelProvider provider) {
    return _info[provider.key]!;
  }

  static List<Map<String, String>> getModels(String providerKey) {
    switch (providerKey) {
      case 'deepseek':
        return [
          {'value': 'deepseek-chat', 'name': 'DeepSeek Chat', 'icon': '💬', 'description': '通用对话模型'},
          {'value': 'deepseek-coder', 'name': 'DeepSeek Coder', 'icon': '💻', 'description': '代码生成模型'},
        ];
      case 'glm':
        return [
          {'value': 'glm-4-plus', 'name': 'GLM-4-Plus', 'icon': '🌟', 'description': '最新最强模型'},
          {'value': 'glm-4', 'name': 'GLM-4', 'icon': '🚀', 'description': '高性能模型'},
          {'value': 'glm-4-flash', 'name': 'GLM-4-Flash', 'icon': '⚡', 'description': '超高速模型'},
          {'value': 'glm-4-air', 'name': 'GLM-4-Air', 'icon': '💨', 'description': '轻量级模型'},
        ];
      case 'qwen':
        return [
          {'value': 'qwen-max', 'name': 'Qwen-Max', 'icon': '🌟', 'description': '最强旗舰模型'},
          {'value': 'qwen-plus', 'name': 'Qwen-Plus', 'icon': '🚀', 'description': '高性价比模型'},
          {'value': 'qwen-turbo', 'name': 'Qwen-Turbo', 'icon': '⚡', 'description': '超高速响应'},
        ];
      case 'minimax':
        return [
          {'value': 'abab6.5s-chat', 'name': 'abab6.5s-chat', 'icon': '🌟', 'description': '最新对话模型'},
          {'value': 'abab6-chat', 'name': 'abab6-chat', 'icon': '💬', 'description': '标准对话模型'},
        ];
      default:
        return [];
    }
  }
}

extension ModelProviderExtension on ModelProvider {
  String get key {
    switch (this) {
      case ModelProvider.deepseek:
        return 'deepseek';
      case ModelProvider.glm:
        return 'glm';
      case ModelProvider.qwen:
        return 'qwen';
      case ModelProvider.minimax:
        return 'minimax';
    }
  }
}

/// 模型配置
@freezed
class ModelConfig with _$ModelConfig {
  const factory ModelConfig({
    @Default('deepseek') String provider,
    @Default('deepseek-chat') String model,
  }) = _ModelConfig;
}

/// 模型配置 Provider
@riverpod
class ModelConfig extends _$ModelConfig {
  @override
  ModelConfig build() {
    return const ModelConfig();
  }

  void setProvider(String provider) {
    state = state.copyWith(provider: provider);
  }

  void setModel(String model) {
    state = state.copyWith(model: model);
  }

  void reset() {
    state = const ModelConfig();
  }
}
