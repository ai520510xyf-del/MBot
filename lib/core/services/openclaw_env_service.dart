import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'nodejs_mobile_bridge.dart';
import 'openclaw_config.dart';

/// OpenClaw 内嵌环境管理服务
///
/// 通过内嵌的 Node.js 运行时（libnode.so）在 App 沙箱内运行 OpenClaw Gateway。
/// 无需 Termux、proot 或任何外部依赖。
///
/// 架构：
/// - Android: libnode.so（通过 nodejs-mobile-react-native 预编译）
/// - App 启动时自动解压 OpenClaw npm 包到沙箱目录
/// - 通过 MethodChannel 调用原生层启动 Node.js 运行 OpenClaw Gateway
class OpenClawEnvService {
  /// Gateway 端口
  static const int gatewayPort = 78789;

  /// Node.js 进程 PID
  int? _nodePid;

  /// Node.js 二进制路径
  String? _nodeBinaryPath;

  /// OpenClaw 工作目录
  String? _openclawHome;

  /// 是否已初始化
  bool _initialized = false;

  /// 安装进度回调
  void Function(String stage, double progress, String message)? onProgress;

  /// 日志回调
  void Function(String message)? onLog;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// Gateway 是否运行中
  int? get nodePid => _nodePid;

  /// OpenClaw 主目录
  String? get openclawHome => _openclawHome;

  /// 初始化 OpenClaw 环境
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Step 1: 获取内嵌 Node.js 路径
      _progress('nodejs', 0.1, '初始化 Node.js 运行时...');
      _nodeBinaryPath = await NodejsMobileBridge.getNodeBinaryPath();
      if (_nodeBinaryPath == null) {
        throw Exception('未找到内嵌 Node.js，请检查 App 安装完整性');
      }
      _log('Node.js 路径: $_nodeBinaryPath');

      // Step 2: 创建工作目录
      _progress('env', 0.2, '创建工作环境...');
      final homeDir = await _createWorkDirectory();
      _openclawHome = homeDir;
      _log('工作目录: $homeDir');

      // Step 3: 安装 OpenClaw
      _progress('install', 0.3, '检查 OpenClaw...');
      final openclawBin = '$homeDir/node_modules/.bin/openclaw';
      final openclawExists = await File(openclawBin).exists();

      if (!openclawExists) {
        _progress('install', 0.4, '安装 OpenClaw（首次可能需要几分钟）...');
        await _installOpenClaw(homeDir);
      } else {
        _progress('install', 0.6, 'OpenClaw 已安装');
        _log('OpenClaw 已存在，跳过安装');
      }

      // Step 4: 写入默认配置
      _progress('config', 0.8, '写入配置...');
      await _writeDefaultConfig(homeDir);

      _initialized = true;
      _progress('done', 1.0, '初始化完成！');
      return true;
    } catch (e) {
      _progress('error', 0, '初始化失败: $e');
      _log('初始化错误: $e');
      return false;
    }
  }

  /// 启动 OpenClaw Gateway
  Future<bool> startGateway() async {
    if (_nodePid != null) {
      final running = await NodejsMobileBridge.isNodeRunning();
      if (running) {
        _log('Gateway 已在运行中 (pid: $_nodePid)');
        return true;
      }
    }

    if (_openclawHome == null || _nodeBinaryPath == null) {
      throw Exception('环境未初始化');
    }

    try {
      _progress('gateway', 0, '启动 OpenClaw Gateway...');

      final openclawEntry = '$_openclawHome/node_modules/openclaw/openclaw.mjs';

      _nodePid = await NodejsMobileBridge.startNodeProcess(
        args: [
          openclawEntry,
          'gateway',
          'run',
          '--port', gatewayPort.toString(),
        ],
        env: {
          'OPENCLAW_STATE_DIR': '$_openclawHome/.openclaw',
          'OPENCLAW_CONFIG_PATH': '$_openclawHome/.openclaw/openclaw.json',
          'HOME': _openclawHome!,
          'NODE_PATH': '$_openclawHome/node_modules',
        },
        workDir: _openclawHome,
      );

      // 等待 Gateway 启动
      await Future.delayed(const Duration(seconds: 3));

      _progress('gateway', 1.0, 'Gateway 已启动 (端口 $gatewayPort)');
      _log('Gateway 进程已启动, pid: $_nodePid');
      return true;
    } catch (e) {
      _progress('error', 0, '启动 Gateway 失败: $e');
      _log('启动 Gateway 错误: $e');
      return false;
    }
  }

  /// 停止 OpenClaw Gateway
  Future<void> stopGateway() async {
    if (_nodePid == null) return;

    _log('停止 Gateway (pid: $_nodePid)...');
    await NodejsMobileBridge.stopNodeProcess();
    _nodePid = null;
    _progress('gateway', 0, 'Gateway 已停止');
  }

  /// 创建工作目录
  Future<String> _createWorkDirectory() async {
    final tempDir = Directory.systemTemp;
    final homeDir = Directory('${tempDir.path}/mbot-openclaw');
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }

    for (final dir in [
      '$homeDir/.openclaw',
      '$homeDir/.openclaw/workspace',
      '$homeDir/.openclaw/skills',
    ]) {
      final d = Directory(dir);
      if (!await d.exists()) {
        await d.create(recursive: true);
      }
    }

    return homeDir.path;
  }

  /// 安装 OpenClaw（通过 npm）
  Future<void> _installOpenClaw(String homeDir) async {
    _progress('install', 0.45, '下载并安装 OpenClaw...');

    _nodePid = await NodejsMobileBridge.startNodeProcess(
      args: ['npm', 'install', '-g', 'openclaw', '--prefix', homeDir],
      env: {
        'HOME': homeDir,
        'NODE_PATH': '$homeDir/node_modules',
      },
      workDir: homeDir,
    );

    // 等待 npm install 完成
    // 注意：原生层的 stdout/stderr 输出到 logcat
    // 这里通过轮询检查进程状态
    var elapsed = 0;
    while (elapsed < 600) { // 最多等 10 分钟
      await Future.delayed(const Duration(seconds: 2));
      elapsed += 2;

      final running = await NodejsMobileBridge.isNodeRunning();
      if (!running) {
        _nodePid = null;
        _progress('install', 0.7, 'npm install 完成');
        _log('OpenClaw npm install 完成');
        return;
      }

      // 更新进度（估算）
      final estimatedProgress = 0.45 + (elapsed / 600) * 0.25;
      if (elapsed % 10 == 0) {
        _progress('install', estimatedProgress.clamp(0.4, 0.7), '安装中... (${elapsed}s)');
      }
    }

    // 超时
    await NodejsMobileBridge.stopNodeProcess();
    _nodePid = null;
    throw TimeoutException('OpenClaw 安装超时（10分钟）');
  }

  /// 写入默认 OpenClaw 配置
  Future<void> _writeDefaultConfig(String homeDir) async {
    final configDir = '$homeDir/.openclaw';
    await OpenClawConfig.writeConfig(configDir);
    _log('默认配置已写入 $configDir/openclaw.json');
  }

  /// 更新 API Key
  Future<void> updateApiKey(String apiKey) async {
    if (_openclawHome == null) throw Exception('环境未初始化');
    await OpenClawConfig.updateApiKey('$_openclawHome/.openclaw', apiKey);
    _log('API Key 已更新');
  }

  void _progress(String stage, double progress, String message) {
    onProgress?.call(stage, progress, message);
  }

  void _log(String message) {
    onLog?.call(message);
  }

  /// 清理资源
  void dispose() {
    stopGateway();
  }
}
