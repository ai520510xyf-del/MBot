import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/auth_state.dart';

part 'auth_provider.g.dart';

/// 认证状态管理 Provider
@riverpod
class Auth extends _$Auth {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  @override
  AuthState build() {
    // Check secure storage for existing auth session
    _checkAuthStatus();
    return const AuthState.unauthenticated();
  }

  /// Check authentication status from secure storage
  Future<void> _checkAuthStatus() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      final userId = await _storage.read(key: 'user_id');
      final phone = await _storage.read(key: 'phone');
      final nickname = await _storage.read(key: 'nickname');

      if (token != null && userId != null) {
        state = AuthState.authenticated(
          userId: userId,
          phone: phone ?? '',
          nickname: nickname ?? 'MBot 用户',
        );
      }
    } catch (e) {
      // Storage read failed, remain unauthenticated
    }
  }

  /// 手机号登录
  Future<void> loginWithPhone({
    required String phone,
    required String code,
  }) async {
    state = const AuthState.authenticating();

    try {
      // TODO: 调用真实 API 验证手机号和验证码
      // POST /api/auth/login-with-phone
      // Body: { "phone": phone, "code": code }
      await Future.delayed(const Duration(seconds: 1));

      // 模拟登录成功 - 实际应该从 API 返回获取
      final userId = 'user_$phone';
      final token = 'token_${phone}_$code';

      state = AuthState.authenticated(
        userId: userId,
        phone: phone,
        nickname: 'MBot 用户',
      );

      // Save auth token to secure storage
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(key: 'phone', value: phone);
      await _storage.write(key: 'nickname', value: 'MBot 用户');
    } catch (e) {
      state = AuthState.error(e.toString());
      rethrow; // 重新抛出异常，让调用方处理
    }
  }

  /// 微信绑定登录
  Future<void> loginWithWechat({required String qrCode}) async {
    state = const AuthState.authenticating();

    try {
      // Integrate with WeChat OAuth flow
      await Future.delayed(const Duration(seconds: 2));

      const userId = 'user_wechat';
      const token = 'token_wechat';

      state = const AuthState.authenticated(
        userId: userId,
        phone: '',
        nickname: '微信用户',
      );

      // Save auth token to secure storage
      await _storage.write(key: 'auth_token', value: token);
      await _storage.write(key: 'user_id', value: userId);
      await _storage.write(key: 'nickname', value: '微信用户');
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// 退出登录
  Future<void> logout() async {
    // Clear auth data from secure storage
    try {
      await _storage.delete(key: 'auth_token');
      await _storage.delete(key: 'user_id');
      await _storage.delete(key: 'phone');
      await _storage.delete(key: 'nickname');
    } catch (e) {
      // Ignore storage errors during logout
    }
    state = const AuthState.unauthenticated();
  }

  /// 检查是否已登录
  bool get isAuthenticated => state is Authenticated;

  /// 获取当前用户信息
  Authenticated? get currentUser {
    final currentState = state;
    return currentState is Authenticated ? currentState : null;
  }
}
