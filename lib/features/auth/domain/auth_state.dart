import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

/// 认证状态
@freezed
class AuthState with _$AuthState {
  /// 未登录
  const factory AuthState.unauthenticated() = Unauthenticated;
  
  /// 登录中
  const factory AuthState.authenticating() = Authenticating;
  
  /// 已登录
  const factory AuthState.authenticated({
    required String userId,
    required String phone,
    String? nickname,
    String? avatar,
  }) = Authenticated;
  
  /// 登录失败
  const factory AuthState.error(String message) = AuthError;
}
