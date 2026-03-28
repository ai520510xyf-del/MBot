import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/auth_state.dart';

part 'auth_provider.g.dart';

/// 认证状态管理 Provider
@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() {
    // TODO: 从持久化存储读取登录状态
    return const AuthState.unauthenticated();
  }

  /// 手机号登录
  Future<void> loginWithPhone({
    required String phone,
    required String code,
  }) async {
    state = const AuthState.authenticating();
    
    try {
      // TODO: 实现实际的登录逻辑
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟登录成功
      state = AuthState.authenticated(
        userId: 'user_$phone',
        phone: phone,
        nickname: 'MBot 用户',
      );
      
      // TODO: 保存到持久化存储
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// 微信绑定登录
  Future<void> loginWithWechat({
    required String qrCode,
  }) async {
    state = const AuthState.authenticating();
    
    try {
      // TODO: 实现微信扫码登录逻辑
      await Future.delayed(const Duration(seconds: 2));
      
      state = const AuthState.authenticated(
        userId: 'user_wechat',
        phone: '',
        nickname: '微信用户',
      );
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  /// 退出登录
  Future<void> logout() async {
    // TODO: 清除持久化存储
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
