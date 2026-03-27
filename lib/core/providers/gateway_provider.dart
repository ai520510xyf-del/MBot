import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 网关连接状态
enum GatewayConnectionState {
  /// 未连接
  disconnected,

  /// 连接中
  connecting,

  /// 已连接
  connected,

  /// 连接失败
  failed,
}

/// 网关状态 Provider
final gatewayStateProvider = StateProvider<GatewayConnectionState>((ref) {
  return GatewayConnectionState.disconnected;
});
