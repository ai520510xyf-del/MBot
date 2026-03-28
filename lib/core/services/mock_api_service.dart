import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

/// Mock API 服务 - 用于演示模式，无需真实网络请求
/// 所有数据存储在内存中，仅用于开发和演示
class MockApiService {
  static final MockApiService _instance = MockApiService._internal();
  factory MockApiService() => _instance;
  MockApiService._internal();

  // 存储验证码 {手机号: 验证码}
  final Map<String, String> _smsCodes = {};

  // 存储微信扫码状态 {qrCodeId: 扫码状态}
  final Map<String, WechatScanState> _wechatStates = {};

  // UUID 生成器
  final _uuid = const Uuid();

  /// 发送短信验证码
  /// [phone] 手机号
  /// 返回 {success: bool, message: String, code: String (仅调试)}
  Future<Map<String, dynamic>> sendSmsCode(String phone) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 生成 6 位随机验证码
    final code = (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();

    // 存储验证码
    _smsCodes[phone] = code;

    // 打印到控制台（调试用）
    debugPrint('════════════════════════════════════════');
    debugPrint('📱 [Mock SMS] 手机号: $phone');
    debugPrint('🔑 [Mock SMS] 验证码: $code');
    debugPrint('════════════════════════════════════════');

    return {
      'success': true,
      'message': '验证码已发送，请注意查收',
      'code': code, // 返回验证码用于调试
    };
  }

  /// 验证短信验证码
  /// [phone] 手机号
  /// [code] 用户输入的验证码
  /// 返回 {success: bool, message: String}
  Future<Map<String, dynamic>> verifySmsCode(String phone, String code) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    // 检查验证码长度
    if (code.length != 6) {
      return {
        'success': false,
        'message': '请输入 6 位验证码',
      };
    }

    // 演示模式：接受任意 6 位数字
    // 但如果存储的验证码存在，优先验证正确的验证码
    final storedCode = _smsCodes[phone];
    if (storedCode != null && storedCode == code) {
      // 验证成功后删除验证码（一次性使用）
      _smsCodes.remove(phone);
      return {
        'success': true,
        'message': '验证成功',
      };
    }

    // 演示模式：任意 6 位数字都可以登录
    if (RegExp(r'^\d{6}$').hasMatch(code)) {
      debugPrint('════════════════════════════════════════');
      debugPrint('✅ [Mock SMS] 演示模式：接受任意 6 位验证码');
      debugPrint('📱 [Mock SMS] 手机号: $phone, 输入验证码: $code');
      debugPrint('════════════════════════════════════════');
      return {
        'success': true,
        'message': '验证成功（演示模式）',
      };
    }

    return {
      'success': false,
      'message': '验证码格式不正确',
    };
  }

  /// 获取微信扫码二维码
  /// 返回 {success: bool, qrCodeUrl: String, qrCodeId: String, expireSeconds: int}
  Future<Map<String, dynamic>> getWechatQrCode() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // 生成唯一的二维码 ID
    final qrCodeId = 'wechat_qr_${_uuid.v4().substring(0, 8)}';

    // 生成模拟的微信扫码 URL
    final qrCodeUrl = 'weixin://wxpay/bizpayurl?pr=$qrCodeId';

    // 初始化扫码状态
    _wechatStates[qrCodeId] = WechatScanState(
      qrCodeId: qrCodeId,
      status: WechatScanStatus.waiting,
      createdAt: DateTime.now(),
    );

    // 启动自动确认定时器（30 秒后自动确认）
    _startAutoConfirmTimer(qrCodeId);

    debugPrint('════════════════════════════════════════');
    debugPrint('📷 [Mock WeChat] 生成二维码');
    debugPrint('🆔 [Mock WeChat] qrCodeId: $qrCodeId');
    debugPrint('⏰ [Mock WeChat] 30 秒后自动确认登录');
    debugPrint('════════════════════════════════════════');

    return {
      'success': true,
      'qrCodeUrl': qrCodeUrl,
      'qrCodeId': qrCodeId,
      'expireSeconds': 300, // 5 分钟有效期
    };
  }

  /// 轮询微信扫码状态
  /// [qrCodeId] 二维码 ID
  /// 返回 {success: bool, status: String, userId: String?, token: String?}
  Future<Map<String, dynamic>> checkWechatScanStatus(String qrCodeId) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 100));

    final state = _wechatStates[qrCodeId];
    if (state == null) {
      return {
        'success': false,
        'status': 'expired',
        'message': '二维码已过期',
      };
    }

    // 检查是否过期（5 分钟）
    if (DateTime.now().difference(state.createdAt).inSeconds > 300) {
      _wechatStates.remove(qrCodeId);
      return {
        'success': false,
        'status': 'expired',
        'message': '二维码已过期',
      };
    }

    final result = {
      'success': true,
      'status': state.status.name,
    };

    // 如果已确认，返回用户信息
    if (state.status == WechatScanStatus.confirmed) {
      result['userId'] = 'wechat_user_${qrCodeId.substring(0, 8)}';
      result['token'] = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      result['nickname'] = '微信用户';

      // 清理状态
      _wechatStates.remove(qrCodeId);
    }

    return result;
  }

  /// 启动自动确认定时器（30 秒后自动确认登录）
  void _startAutoConfirmTimer(String qrCodeId) {
    Future.delayed(const Duration(seconds: 30), () {
      final state = _wechatStates[qrCodeId];
      if (state != null && state.status == WechatScanStatus.waiting) {
        _wechatStates[qrCodeId] = state.copyWith(
          status: WechatScanStatus.confirmed,
        );

        debugPrint('════════════════════════════════════════');
        debugPrint('✅ [Mock WeChat] 自动确认登录');
        debugPrint('🆔 [Mock WeChat] qrCodeId: $qrCodeId');
        debugPrint('════════════════════════════════════════');
      }
    });
  }

  /// 手动确认扫码（用于测试）
  void confirmWechatScan(String qrCodeId) {
    final state = _wechatStates[qrCodeId];
    if (state != null) {
      _wechatStates[qrCodeId] = state.copyWith(
        status: WechatScanStatus.confirmed,
      );

      debugPrint('════════════════════════════════════════');
      debugPrint('✅ [Mock WeChat] 手动确认登录');
      debugPrint('🆔 [Mock WeChat] qrCodeId: $qrCodeId');
      debugPrint('════════════════════════════════════════');
    }
  }

  /// 清理所有数据（用于测试）
  void clearAll() {
    _smsCodes.clear();
    _wechatStates.clear();
  }
}

/// 微信扫码状态枚举
enum WechatScanStatus {
  waiting, // 等待扫码
  scanned, // 已扫码，等待确认
  confirmed, // 已确认
  expired, // 已过期
}

/// 微信扫码状态数据类
class WechatScanState {
  final String qrCodeId;
  final WechatScanStatus status;
  final DateTime createdAt;

  WechatScanState({
    required this.qrCodeId,
    required this.status,
    required this.createdAt,
  });

  WechatScanState copyWith({
    String? qrCodeId,
    WechatScanStatus? status,
    DateTime? createdAt,
  }) {
    return WechatScanState(
      qrCodeId: qrCodeId ?? this.qrCodeId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 全局 Mock API 服务实例
final mockApiService = MockApiService();
