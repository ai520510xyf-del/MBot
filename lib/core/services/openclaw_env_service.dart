import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'nodejs_mobile_bridge.dart';
import 'openclaw_config.dart';

/// OpenClaw 内嵌环境管理服务
///
/// 首次启动时用 Node.js 直接调用 npm API 安装 openclaw，
/// 后续启动直接使用本地缓存。
class OpenClawEnvService {
  static const int gatewayPort = 78789;
  static const String _markerFile = '.npm-installed-v1';

  int? _nodePid;
  String? _nodeBinaryPath;
  String? _openclawHome;
  bool _initialized = false;

  void Function(String stage, double progress, String message)? onProgress;
  void Function(String message)? onLog;

  bool get isInitialized => _initialized;
  int? get nodePid => _nodePid;
  String? get openclawHome => _openclawHome;

  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      _progress('nodejs', 0.05, '检查 Node.js...');
      _nodeBinaryPath = await NodejsMobileBridge.getNodeBinaryPath();
      _log('Node.js: $_nodeBinaryPath');

      _progress('env', 0.1, '准备环境...');
      final appDir = await getApplicationSupportDirectory();
      final homeDir = '${appDir.path}/openclaw';
      _openclawHome = homeDir;

      for (final dir in [
        homeDir,
        '$homeDir/.openclaw',
        '$homeDir/.openclaw/workspace',
        '$homeDir/.openclaw/skills',
      ]) {
        await Directory(dir).create(recursive: true);
      }

      final marker = File('$homeDir/$_markerFile');
      if (!await marker.exists()) {
        _progress('install', 0.15, '安装 OpenClaw（首次，约2-5分钟）...');
        await _installOpenClaw(homeDir);
        await marker.writeAsString(DateTime.now().toIso8601String());
        _log('安装完成');
      } else {
        _progress('install', 0.7, 'OpenClaw 已安装');
      }

      _progress('config', 0.85, '加载配置...');
      await _writeDefaultConfig(homeDir);

      _initialized = true;
      _progress('done', 1.0, '就绪！');
      return true;
    } catch (e) {
      _progress('error', 0, '初始化失败: $e');
      _log('错误: $e');
      return false;
    }
  }

  /// 用 Node.js 调用 npm install（libnode.so 自带 npm 模块）
  Future<void> _installOpenClaw(String homeDir) async {
    final installScript = '''
// libnode.so 自带 npm，直接 require 即可
const npm = require('npm');
const path = require('path');

npm.load({
  prefix: process.argv[2],
  registry: 'https://registry.npmmirror.com',
  // 国内镜像加速
}, async (err) => {
  if (err) {
    console.error('NPM_LOAD_FAIL: ' + err.message);
    process.exit(1);
  }

  console.log('npm loaded, installing openclaw...');

  try {
    await new Promise((resolve, reject) => {
      npm.commands.install(['openclaw'], (err, data) => {
        if (err) reject(err);
        else resolve(data);
      });
    });
    console.log('NPM_INSTALL_OK');
    process.exit(0);
  } catch(e) {
    console.error('NPM_INSTALL_FAIL: ' + e.message);
    process.exit(1);
  }
});
''';

    final scriptFile = File('$homeDir/_install.js');
    await scriptFile.writeAsString(installScript);

    _nodePid = await NodejsMobileBridge.startNodeProcess(
      args: [scriptFile.path, homeDir],
      env: {'HOME': homeDir},
      workDir: homeDir,
    );

    var elapsed = 0;
    while (elapsed < 600) {
      await Future.delayed(const Duration(seconds: 3));
      elapsed += 3;
      final running = await NodejsMobileBridge.isNodeRunning();
      if (!running) {
        _nodePid = null;
        _progress('install', 0.7, '安装完成');
        return;
      }
      if (elapsed % 15 == 0) {
        final est = 0.15 + (elapsed / 600) * 0.55;
        _progress('install', est, '安装中... (${elapsed}s)');
      }
    }

    await NodejsMobileBridge.stopNodeProcess();
    _nodePid = null;
    throw TimeoutException('安装超时（10分钟）');
  }

  Future<bool> startGateway() async {
    if (_nodePid != null) {
      final running = await NodejsMobileBridge.isNodeRunning();
      if (running) return true;
    }

    if (_openclawHome == null || _nodeBinaryPath == null) {
      throw Exception('环境未初始化');
    }

    try {
      _progress('gateway', 0, '启动 Gateway...');
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

      await Future.delayed(const Duration(seconds: 3));
      _progress('gateway', 1.0, 'Gateway 已启动 (端口 $gatewayPort)');
      _log('Gateway pid: $_nodePid');
      return true;
    } catch (e) {
      _progress('error', 0, '启动失败: $e');
      return false;
    }
  }

  Future<void> stopGateway() async {
    if (_nodePid == null) return;
    await NodejsMobileBridge.stopNodeProcess();
    _nodePid = null;
  }

  Future<void> _writeDefaultConfig(String homeDir) async {
    final configFile = File('$homeDir/.openclaw/openclaw.json');
    if (!await configFile.exists()) {
      await OpenClawConfig.writeConfig('$homeDir/.openclaw');
    }
  }

  Future<void> updateApiKey(String apiKey) async {
    if (_openclawHome == null) throw Exception('环境未初始化');
    await OpenClawConfig.updateApiKey('$_openclawHome/.openclaw', apiKey);
  }

  void _progress(String stage, double progress, String message) {
    onProgress?.call(stage, progress, message);
  }

  void _log(String message) {
    onLog?.call(message);
  }

  void dispose() {
    stopGateway();
  }
}
