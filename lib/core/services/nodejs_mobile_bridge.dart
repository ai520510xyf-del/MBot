import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

/// Node.js 移动端桥接服务
///
/// 通过 MethodChannel 与 Android 原生层通信，
/// 调用内嵌的 Node.js 运行时（libnode.so）。
class NodejsMobileBridge {
  static const MethodChannel _channel = MethodChannel('com.mbot.mobile/nodejs');

  /// 获取 Node.js 二进制路径
  static Future<String?> getNodeBinaryPath() async {
    try {
      final path = await _channel.invokeMethod<String?>('getNodeBinaryPath');
      return path;
    } on PlatformException catch (e) {
      throw Exception('获取 Node.js 路径失败: ${e.message}');
    }
  }

  /// 启动 Node.js 进程
  ///
  /// [args] 命令行参数
  /// [env] 环境变量
  /// [workDir] 工作目录
  /// 返回进程 PID
  static Future<int> startNodeProcess({
    required List<String> args,
    Map<String, String>? env,
    String? workDir,
  }) async {
    try {
      final pid = await _channel.invokeMethod<int>('startNodeProcess', {
        'args': args,
        'env': env ?? {},
        'workDir': workDir,
      });
      return pid ?? -1;
    } on PlatformException catch (e) {
      throw Exception('启动 Node.js 进程失败: ${e.message}');
    }
  }

  /// 停止 Node.js 进程
  static Future<void> stopNodeProcess() async {
    try {
      await _channel.invokeMethod('stopNodeProcess');
    } on PlatformException catch (e) {
      throw Exception('停止 Node.js 进程失败: ${e.message}');
    }
  }

  /// 检查 Node.js 是否运行中
  static Future<bool> isNodeRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isNodeRunning') ?? false;
    } on PlatformException {
      return false;
    }
  }
}
