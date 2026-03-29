import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/openclaw_env_service.dart';
import '../services/openclaw_config.dart';

part 'openclaw_env_provider.g.dart';

/// 环境状态
enum EnvStage {
  /// 未开始
  idle,

  /// Node.js
  nodejs,

  /// 创建环境
  env,

  /// 安装 OpenClaw
  install,

  /// 配置
  config,

  /// 完成
  done,

  /// 启动 Gateway
  gateway,

  /// 错误
  error,
}

/// 环境状态数据
class EnvState {
  final EnvStage stage;
  final String message;
  final double progress; // 0.0 ~ 1.0
  final bool isInitialized;
  final bool isGatewayRunning;
  final List<String> logs;

  const EnvState({
    this.stage = EnvStage.idle,
    this.message = '',
    this.progress = 0.0,
    this.isInitialized = false,
    this.isGatewayRunning = false,
    this.logs = const [],
  });

  EnvState copyWith({
    EnvStage? stage,
    String? message,
    double? progress,
    bool? isInitialized,
    bool? isGatewayRunning,
    List<String>? logs,
  }) {
    return EnvState(
      stage: stage ?? this.stage,
      message: message ?? this.message,
      progress: progress ?? this.progress,
      isInitialized: isInitialized ?? this.isInitialized,
      isGatewayRunning: isGatewayRunning ?? this.isGatewayRunning,
      logs: logs ?? this.logs,
    );
  }
}

/// OpenClaw 环境管理 Provider
@riverpod
class OpenClawEnv extends _$OpenClawEnv {
  OpenClawEnvService? _service;

  @override
  EnvState build() {
    _service?.dispose();
    _service = OpenClawEnvService()
      ..onProgress = _onProgress
      ..onLog = _onLog;
    ref.onDispose(() => _service?.dispose());
    return const EnvState();
  }

  void _onProgress(String stage, double progress, String message) {
    final envStage = EnvStage.values.firstWhere(
      (e) => e.name == stage,
      orElse: () => EnvStage.idle,
    );
    state = state.copyWith(stage: envStage, progress: progress, message: message);
  }

  void _onLog(String log) {
    final newLogs = [...state.logs, log];
    if (newLogs.length > 200) {
      newLogs.removeRange(0, newLogs.length - 200);
    }
    state = state.copyWith(logs: newLogs);
  }

  /// 初始化环境
  Future<bool> initialize() async {
    state = state.copyWith(stage: EnvStage.nodejs, message: '开始初始化...');
    final result = await _service!.initialize();
    if (result) {
      state = state.copyWith(
        isInitialized: true,
        stage: EnvStage.done,
        progress: 1.0,
        message: '初始化完成',
      );
    } else {
      state = state.copyWith(stage: EnvStage.error, message: '初始化失败');
    }
    return result;
  }

  /// 启动 Gateway
  Future<bool> startGateway() async {
    state = state.copyWith(message: '启动 Gateway...', stage: EnvStage.gateway);
    final result = await _service!.startGateway();
    state = state.copyWith(
      isGatewayRunning: result,
      message: result ? 'Gateway 已启动 (端口 78789)' : 'Gateway 启动失败',
    );
    return result;
  }

  /// 停止 Gateway
  Future<void> stopGateway() async {
    await _service!.stopGateway();
    state = state.copyWith(isGatewayRunning: false, message: 'Gateway 已停止');
  }

  /// 重启 Gateway
  Future<bool> restartGateway() async {
    await stopGateway();
    await Future.delayed(const Duration(seconds: 1));
    return startGateway();
  }

  /// 更新 API Key
  Future<void> updateApiKey(String apiKey) async {
    await _service!.updateApiKey(apiKey);
  }
}
