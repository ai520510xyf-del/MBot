import 'dart:async';
import 'dart:io';

/// OpenClaw 内嵌环境管理服务
///
/// 通过内嵌的 Node.js 运行时（libnode.so）在 App 沙箱内运行 OpenClaw Gateway。
/// 无需 Termux、proot 或任何外部依赖。
///
/// 架构：
/// - Android: libnode.so（通过 nodejs-mobile-react-native 预编译）
/// - iOS: libnode.dylib（同上）
/// - App 启动时自动解压 OpenClaw npm 包到沙箱目录
/// - 通过 Process.start 启动 Node.js 运行 OpenClaw Gateway
class OpenClawEnvService {
  /// Gateway 端口
  static const int gatewayPort = 78789;

  /// OpenClaw Gateway 进程
  Process? _gatewayProcess;

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
  bool get isGatewayRunning => _gatewayProcess != null;

  /// OpenClaw 主目录
  String? get openclawHome => _openclawHome;

  /// 初始化 OpenClaw 环境
  ///
  /// 步骤：
  /// 1. 定位 Node.js 二进制（内嵌 libnode.so 的 wrapper）
  /// 2. 创建 OpenClaw 工作目录
  /// 3. 安装 OpenClaw npm 包
  /// 4. 配置 Gateway
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Step 1: 定位 Node.js
      _progress('nodejs', 0.1, '定位 Node.js 运行时...');
      _nodeBinaryPath = await _findNodeBinary();
      if (_nodeBinaryPath == null) {
        throw Exception('未找到 Node.js 运行时，请检查 App 安装完整性');
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
        _progress('install', 0.6, 'OpenClaw 已安装，跳过...');
        _log('OpenClaw 已存在，跳过安装');
      }

      // Step 4: 配置 OpenClaw
      _progress('config', 0.8, '配置 OpenClaw...');
      await _configureOpenClaw(homeDir);

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
    if (_gatewayProcess != null) {
      _log('Gateway 已在运行中');
      return true;
    }

    if (_openclawHome == null || _nodeBinaryPath == null) {
      throw Exception('环境未初始化');
    }

    try {
      _progress('gateway', 0, '启动 OpenClaw Gateway...');

      // 使用 Node.js 直接运行 OpenClaw Gateway
      final openclawEntry = '$_openclawHome/node_modules/openclaw/openclaw.mjs';

      _gatewayProcess = await Process.start(
        _nodeBinaryPath!,
        [
          openclawEntry,
          'gateway',
          'run',
          '--port', gatewayPort.toString(),
        ],
        mode: ProcessStartMode.normal,
        environment: {
          'OPENCLAW_STATE_DIR': '${_openclawHome!}/.openclaw',
          'OPENCLAW_CONFIG_PATH': '${_openclawHome!}/.openclaw/openclaw.json',
          'HOME': _openclawHome!,
          'NODE_PATH': '${_openclawHome!}/node_modules',
          'PATH': _nodeBinaryPath!,
        },
        workingDirectory: _openclawHome,
      );

      // 监听输出
      _gatewayProcess!.stdout.listen((data) {
        final line = String.fromCharCodes(data).trim();
        if (line.isNotEmpty) _log('[gateway] $line');
      });
      _gatewayProcess!.stderr.listen((data) {
        final line = String.fromCharCodes(data).trim();
        if (line.isNotEmpty) _log('[gateway:err] $line');
      });

      // 监听进程退出
      _gatewayProcess!.exitCode.then((code) {
        _log('Gateway 进程退出，code: $code');
        _gatewayProcess = null;
      });

      // 等待 Gateway 启动
      await Future.delayed(const Duration(seconds: 3));

      _progress('gateway', 1.0, 'Gateway 已启动 (端口 $gatewayPort)');
      return true;
    } catch (e) {
      _progress('error', 0, '启动 Gateway 失败: $e');
      _log('启动 Gateway 错误: $e');
      return false;
    }
  }

  /// 停止 OpenClaw Gateway
  Future<void> stopGateway() async {
    if (_gatewayProcess == null) return;

    _log('停止 Gateway...');
    _gatewayProcess!.kill();
    _gatewayProcess = await _gatewayProcess!.exitCode.then((_) => null);
    _gatewayProcess = null;
    _progress('gateway', 0, 'Gateway 已停止');
  }

  /// 在 OpenClaw 环境中执行命令
  Future<ProcessResult> runCommand(List<String> args) async {
    if (_nodeBinaryPath == null || _openclawHome == null) {
      throw Exception('环境未初始化');
    }

    return Process.run(
      _nodeBinaryPath!,
      args,
      environment: {
        'OPENCLAW_STATE_DIR': '${_openclawHome!}/.openclaw',
        'OPENCLAW_CONFIG_PATH': '${_openclawHome!}/.openclaw/openclaw.json',
        'HOME': _openclawHome!,
        'NODE_PATH': '${_openclawHome!}/node_modules',
      },
      workingDirectory: _openclawHome,
    );
  }

  /// 定位 Node.js 二进制
  ///
  /// 在 Android 上，nodejs-mobile 通过 platform channel 提供 node binary wrapper。
  /// 查找顺序：
  /// 1. App 内嵌的 node wrapper（通过 MethodChannel 获取路径）
  /// 2. PATH 中的 node
  /// 3. /system/bin/node（某些自定义 ROM）
  Future<String?> _findNodeBinary() async {
    // 尝试 PATH 中的 node（开发环境）
    try {
      final result = await Process.run('which', ['node']);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim();
      }
    } catch (_) {}

    // 尝试常见路径
    const candidates = [
      '/data/data/com.mbot.mobile/files/bin/node',  // Android App sandbox
      '/data/user/0/com.mbot.mobile/files/bin/node',
      '/usr/local/bin/node',
      '/usr/bin/node',
    ];

    for (final path in candidates) {
      if (await File(path).exists()) {
        return path;
      }
    }

    // TODO: 通过 PlatformChannel 从原生层获取 node binary 路径
    // 这部分需要 Flutter 原生代码配合（Android: NodejsMobilePlugin）
    return null;
  }

  /// 创建工作目录
  Future<String> _createWorkDirectory() async {
    final tempDir = Directory.systemTemp;
    final homeDir = Directory('${tempDir.path}/mbot-openclaw');
    if (!await homeDir.exists()) {
      await homeDir.create(recursive: true);
    }

    // 创建必要子目录
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

  /// 安装 OpenClaw
  Future<void> _installOpenClaw(String homeDir) async {
    if (_nodeBinaryPath == null) throw Exception('Node.js 未找到');

    _progress('install', 0.45, '下载 OpenClaw...');

    // 使用 npm install 安装 OpenClaw
    final process = await Process.start(
      _nodeBinaryPath!,
      ['npm', 'install', '-g', 'openclaw', '--prefix', homeDir],
      environment: {
        'HOME': homeDir,
        'NODE_PATH': '$homeDir/node_modules',
      },
      workingDirectory: homeDir,
    );

    // 实时输出日志
    process.stdout.listen((data) {
      final line = String.fromCharCodes(data).trim();
      if (line.isNotEmpty) _log('[npm] $line');
    });
    process.stderr.listen((data) {
      final line = String.fromCharCodes(data).trim();
      if (line.isNotEmpty) _log('[npm:err] $line');
    });

    final exitCode = await process.exitCode.timeout(
      const Duration(minutes: 10),
      onTimeout: () {
        process.kill();
        throw TimeoutException('npm install 超时');
      },
    );

    if (exitCode != 0) {
      throw Exception('OpenClaw 安装失败 (exit code: $exitCode)');
    }

    _progress('install', 0.7, 'OpenClaw 安装完成');
  }

  /// 配置 OpenClaw
  Future<void> _configureOpenClaw(String homeDir) async {
    final configDir = '$homeDir/.openclaw';
    final configFile = '$configDir/openclaw.json';

    // 如果配置文件不存在，创建基本配置
    if (!await File(configFile).exists()) {
      _log('创建默认配置...');
      // 配置通过 OpenClaw 自身的 configure 命令完成
      // 或者直接写一个最小配置
    }
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
