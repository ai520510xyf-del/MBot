import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gateway_provider.g.dart';

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

/// 网关状态 Notifier
@riverpod
class GatewayState extends _$GatewayState {
  @override
  GatewayConnectionState build() {
    return GatewayConnectionState.disconnected;
  }

  /// 更新状态
  void update(GatewayConnectionState newState) {
    state = newState;
  }
}
