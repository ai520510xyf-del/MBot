import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ws_connection_provider.g.dart';

/// WebSocket 连接状态 Notifier
@riverpod
class WsConnection extends _$WsConnection {
  @override
  bool build() => false;

  void setConnected(bool value) {
    state = value;
  }
}
