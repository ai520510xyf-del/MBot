import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:math';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/gateway_provider.dart';

part 'gateway_service.g.dart';

/// AGP 协议消息类型
enum AgpMessageType {
  /// 会话更新
  sessionUpdate,

  /// 工具调用
  toolCall,

  /// 工具结果
  toolResult,

  /// 错误
  error,

  /// Ping
  ping,

  /// Pong
  pong,
}

/// AGP 协议消息
class AgpMessage {
  final String msgId;
  final String guid;
  final AgpMessageType method;
  final Map<String, dynamic> payload;

  AgpMessage({
    required this.msgId,
    required this.guid,
    required this.method,
    required this.payload,
  });

  factory AgpMessage.fromJson(Map<String, dynamic> json) {
    return AgpMessage(
      msgId: json['msg_id'] as String,
      guid: json['guid'] as String,
      method: _methodFromString(json['method'] as String),
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : Map<String, dynamic>.from(json['payload'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'msg_id': msgId,
      'guid': guid,
      'method': method.name,
      'payload': payload,
    };
  }

  static AgpMessageType _methodFromString(String value) {
    return AgpMessageType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AgpMessageType.sessionUpdate,
    );
  }
}

/// Gateway 服务
class GatewayService {
  WebSocketChannel? _channel;
  final _messageController = StreamController<AgpMessage>.broadcast();
  final _statusController =
      StreamController<GatewayConnectionState>.broadcast();

  final Set<String> _receivedMsgIds = {};
  static const int _maxMsgIds = 1000;

  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _initialReconnectDelay = Duration(seconds: 3);
  static const Duration _maxReconnectDelay = Duration(seconds: 25);
  static const Duration _heartbeatInterval = Duration(seconds: 20);

  String? _serverUrl;
  String? _sessionGuid;

  /// 消息流
  Stream<AgpMessage> get messageStream => _messageController.stream;

  /// 连接状态流
  Stream<GatewayConnectionState> get statusStream => _statusController.stream;

  /// 当前连接状态
  GatewayConnectionState _currentState = GatewayConnectionState.disconnected;
  GatewayConnectionState get currentState => _currentState;

  /// 连接到 Gateway
  Future<void> connect(String url) async {
    if (_currentState == GatewayConnectionState.connecting ||
        _currentState == GatewayConnectionState.connected) {
      return;
    }

    _serverUrl = url;
    _updateState(GatewayConnectionState.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 监听连接状态
      _channel!.ready.then(
        (_) {
          _onConnected();
        },
        onError: (error) {
          _onError(error);
        },
      );

      // 监听消息
      _channel!.stream.listen(_onMessage, onError: _onError, onDone: _onDone);
    } catch (e) {
      _onError(e);
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _reconnectAttempts = 0;

    await _channel?.sink.close();
    _channel = null;
    _updateState(GatewayConnectionState.disconnected);
  }

  /// 发送消息
  void sendMessage(AgpMessage message) {
    if (_currentState != GatewayConnectionState.connected) {
      throw StateError('Gateway not connected');
    }

    _channel?.sink.add(jsonEncode(message.toJson()));
  }

  /// 发送聊天消息
  String sendChatMessage(String content, {String? conversationId}) {
    final msgId = _generateMsgId();
    final guid = conversationId ?? _sessionGuid ?? _generateGuid();

    final message = AgpMessage(
      msgId: msgId,
      guid: guid,
      method: AgpMessageType.sessionUpdate,
      payload: {'content': content, 'type': 'text'},
    );

    sendMessage(message);
    return msgId;
  }

  void _onConnected() {
    _reconnectAttempts = 0;
    _updateState(GatewayConnectionState.connected);

    // 启动心跳
    _startHeartbeat();
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final message = AgpMessage.fromJson(json);

      // 消息去重
      if (_receivedMsgIds.contains(message.msgId)) {
        return;
      }

      _receivedMsgIds.add(message.msgId);
      if (_receivedMsgIds.length > _maxMsgIds) {
        _receivedMsgIds.remove(_receivedMsgIds.first);
      }

      // 处理 Ping/Pong
      if (message.method == AgpMessageType.ping) {
        sendMessage(
          AgpMessage(
            msgId: _generateMsgId(),
            guid: message.guid,
            method: AgpMessageType.pong,
            payload: {},
          ),
        );
        return;
      }

      if (message.method == AgpMessageType.pong) {
        return; // Pong 已收到，重置心跳计时
      }

      // 发送消息到流
      _messageController.add(message);
    } catch (e) {
      _onError(e);
    }
  }

  void _onError(dynamic error) {
    _updateState(GatewayConnectionState.failed);
    _scheduleReconnect();
  }

  void _onDone() {
    _updateState(GatewayConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_currentState == GatewayConnectionState.connected) {
        sendMessage(
          AgpMessage(
            msgId: _generateMsgId(),
            guid: _sessionGuid ?? '',
            method: AgpMessageType.ping,
            payload: {'timestamp': DateTime.now().millisecondsSinceEpoch},
          ),
        );
      }
    });
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    final delay = _calculateReconnectDelay();
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      if (_serverUrl != null) {
        connect(_serverUrl!);
      }
    });
  }

  Duration _calculateReconnectDelay() {
    final exponent = _reconnectAttempts - 1;
    final delay =
        _initialReconnectDelay.inMilliseconds * (1 << exponent.clamp(0, 10));
    final maxDelay = _maxReconnectDelay.inMilliseconds;
    return Duration(milliseconds: delay.clamp(0, maxDelay));
  }

  void _updateState(GatewayConnectionState state) {
    _currentState = state;
    _statusController.add(state);
  }

  String _generateMsgId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  String _generateGuid() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${_randomString(12)}';
  }

  String _randomString(int length) {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}

/// GatewayService Provider
@riverpod
GatewayService gatewayService(Ref ref) {
  final service = GatewayService();
  ref.onDispose(() => service.dispose());
  return service;
}
