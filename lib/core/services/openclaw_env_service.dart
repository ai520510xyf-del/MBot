import 'dart:async';
import 'dart:io';

/// OpenClaw 环境管理服务
///
/// 在 Android 设备上通过 proot-distro 管理 Linux 环境，
/// 在 Linux 环境中安装并运行 OpenClaw Gateway。
class OpenClawEnvService {
  /// proot-distro 默认发行版
  static const String _distro = 'ubuntu';

  /// Gateway 端口
  static const int gatewayPort = 78789;

  /// OpenClaw Gateway 进程
  Process? _gatewayProcess;

  /// 是否已初始化
  bool _initialized = false;

  /// 安装进度回调
  void Function(String stage, String message)? onProgress;

  /// 日志回调
  void Function(String message)? onLog;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// Gateway 是否运行中
  bool get isGatewayRunning => _gatewayProcess != null;

  /// 初始化 proot-distro + Node.js + OpenClaw
  ///
  /// 步骤：
  /// 1. 检查/安装 proot-distro
  /// 2. 检查/安装 Ubuntu
  /// 3. 在 Ubuntu 中安装 Node.js 22
  /// 4. 在 Ubuntu 中安装 OpenClaw
  /// 5. 配置 OpenClaw
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Step 1: 检查 Termux 环境
      _progress('termux', '检查 Termux 环境...');
      final hasTermux = await _checkCommand('which termux-setup-storage');
      if (!hasTermux) {
        // 非 Termux 环境，尝试直接执行
        _log('非 Termux 环境，尝试直接执行...');
      }

      // Step 2: 检查 proot-distro
      _progress('proot', '检查 proot-distro...');
      final hasProot = await _checkCommand('which proot-distro');
      if (!hasProot) {
        _progress('proot', '安装 proot-distro...');
        await _runCommand('pkg install proot-distro -y');
      }

      // Step 3: 检查 Ubuntu
      _progress('distro', '检查 Ubuntu 环境...');
      final hasUbuntu = await _checkProotDistro(_distro);
      if (!hasUbuntu) {
        _progress('distro', '安装 Ubuntu（可能需要几分钟）...');
        await _runCommand('proot-distro install $_distro --non-interactive');
      }

      // Step 4: 在 Ubuntu 中安装 Node.js
      _progress('nodejs', '检查 Node.js...');
      final hasNode = await _checkInDistro('node --version');
      if (!hasNode) {
        _progress('nodejs', '安装 Node.js 22.x...');
        await _runInDistro(
          'curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && '
          'apt-get install -y nodejs',
        );
      }

      // Step 5: 在 Ubuntu 中安装 OpenClaw
      _progress('openclaw', '检查 OpenClaw...');
      final hasOpenclaw = await _checkInDistro('which openclaw');
      if (!hasOpenclaw) {
        _progress('openclaw', '安装 OpenClaw（npm install -g）...');
        await _runInDistro('npm install -g openclaw');
      }

      // Step 6: 配置 OpenClaw
      _progress('config', '配置 OpenClaw...');
      await _configureOpenClaw();

      _initialized = true;
      _progress('done', '初始化完成！');
      return true;
    } catch (e) {
      _progress('error', '初始化失败: $e');
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

    try {
      _progress('gateway', '启动 OpenClaw Gateway...');

      // 在 proot 环境中启动 gateway
      _gatewayProcess = await Process.start(
        'proot-distro',
        [
          'login',
          _distro,
          '--',
          'openclaw',
          'gateway',
          'run',
          '--port', gatewayPort.toString(),
          '--bind', '0.0.0.0',
        ],
        mode: ProcessStartMode.normal,
      );

      // 监听输出
      _gatewayProcess!.stdout.listen((data) {
        _log('[gateway] ${String.fromCharCodes(data)}');
      });
      _gatewayProcess!.stderr.listen((data) {
        _log('[gateway:err] ${String.fromCharCodes(data)}');
      });

      // 等待进程退出时清理
      _gatewayProcess!.exitCode.then((code) {
        _log('Gateway 进程退出，code: $code');
        _gatewayProcess = null;
      });

      // 等待 Gateway 启动（给几秒时间）
      await Future.delayed(const Duration(seconds: 3));

      _progress('gateway', 'Gateway 已启动 (端口 $gatewayPort)');
      return true;
    } catch (e) {
      _progress('error', '启动 Gateway 失败: $e');
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
    _progress('gateway', 'Gateway 已停止');
  }

  /// 在 proot 环境中执行命令
  Future<String> _runInDistro(String command) async {
    final result = await Process.run(
      'proot-distro',
      ['login', _distro, '--', 'bash', '-c', command],
    ).timeout(const Duration(minutes: 10));

    if (result.exitCode != 0) {
      throw Exception(
        '命令执行失败 (exit ${result.exitCode}): ${result.stderr}',
      );
    }
    return result.stdout.toString().trim();
  }

  /// 执行系统命令
  Future<String> _runCommand(String command) async {
    final parts = command.split(' ');
    final result = await Process.run(
      parts.first,
      parts.sublist(1),
    ).timeout(const Duration(minutes: 10));

    if (result.exitCode != 0) {
      throw Exception(
        '命令执行失败 (exit ${result.exitCode}): ${result.stderr}',
      );
    }
    return result.stdout.toString().trim();
  }

  /// 检查命令是否存在
  Future<bool> _checkCommand(String command) async {
    try {
      final result = await Process.run(
        'bash',
        ['-c', '$command 2>/dev/null && echo OK || echo FAIL'],
      ).timeout(const Duration(seconds: 5));
      return result.stdout.toString().trim() == 'OK';
    } catch (_) {
      return false;
    }
  }

  /// 检查 proot-distro 是否已安装
  Future<bool> _checkProotDistro(String distro) async {
    try {
      final result = await Process.run(
        'bash',
        ['-c', 'proot-distro list 2>/dev/null | grep -q "$distro" && echo OK || echo FAIL'],
      ).timeout(const Duration(seconds: 5));
      return result.stdout.toString().trim() == 'OK';
    } catch (_) {
      return false;
    }
  }

  /// 在 proot 环境中检查命令
  Future<bool> _checkInDistro(String command) async {
    try {
      final result = await Process.run(
        'proot-distro',
        ['login', _distro, '--', 'bash', '-c', '$command 2>/dev/null && echo OK || echo FAIL'],
      ).timeout(const Duration(seconds: 10));
      return result.stdout.toString().trim() == 'OK';
    } catch (_) {
      return false;
    }
  }

  /// 配置 OpenClaw
  Future<void> _configureOpenClaw() async {
    // 创建基本配置目录
    await _runInDistro('mkdir -p ~/.openclaw');
  }

  void _progress(String stage, String message) {
    onProgress?.call(stage, message);
  }

  void _log(String message) {
    onLog?.call(message);
  }

  /// 清理资源
  void dispose() {
    stopGateway();
  }
}
