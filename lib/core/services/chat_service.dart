import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/message.dart';
import '../services/gateway_service.dart';
import '../providers/gateway_provider.dart';
import '../repositories/conversation_repository.dart';
import '../repositories/message_repository.dart';

part 'chat_service.g.dart';

/// 聊天响应数据
class ChatResponse {
  final String messageId;
  final String content;
  final MessageSender sender;
  final String? toolName;
  final String? toolResult;
  final bool isComplete;

  const ChatResponse({
    required this.messageId,
    required this.content,
    required this.sender,
    this.toolName,
    this.toolResult,
    required this.isComplete,
  });

  ChatResponse copyWith({
    String? messageId,
    String? content,
    MessageSender? sender,
    String? toolName,
    String? toolResult,
    bool? isComplete,
  }) {
    return ChatResponse(
      messageId: messageId ?? this.messageId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      toolName: toolName ?? this.toolName,
      toolResult: toolResult ?? this.toolResult,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

/// 聊天服务
class ChatService {
  final GatewayService _gateway;
  final ConversationRepository _conversationRepo;
  final MessageRepository _messageRepo;

  final _responseController = StreamController<ChatResponse>.broadcast();
  StreamSubscription? _gatewaySubscription;
  StreamSubscription? _statusSubscription;

  String? _currentConversationId;
  String? _pendingAiMessageId;
  final StringBuffer _pendingContent = StringBuffer();

  ChatService({
    required GatewayService gateway,
    required ConversationRepository conversationRepo,
    required MessageRepository messageRepo,
  })  : _gateway = gateway,
        _conversationRepo = conversationRepo,
        _messageRepo = messageRepo;

  /// 响应流（用于流式 UI 更新）
  Stream<ChatResponse> get responseStream => _responseController.stream;

  /// 发送消息
  Future<String> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    _currentConversationId = conversationId;

    // 保存用户消息
    final userMessage = await _messageRepo.create(
      conversationId: conversationId,
      content: content,
      sender: MessageSender.user,
      status: MessageStatus.sent,
    );

    // 更新会话的最后一条消息
    await _conversationRepo.updateLastMessage(conversationId, content);

    // 发送到 Gateway
    _gateway.sendChatMessage(
      content,
      conversationId: conversationId,
    );

    // 创建待处理的 AI 消息占位
    _pendingAiMessageId = await _createPendingAiMessage(conversationId);

    return userMessage.id;
  }

  /// 创建待处理的 AI 消息
  Future<String> _createPendingAiMessage(String conversationId) async {
    final message = await _messageRepo.create(
      conversationId: conversationId,
      content: '',
      sender: MessageSender.ai,
      status: MessageStatus.pending,
    );
    return message.id;
  }

  /// 开始监听 Gateway 消息
  void startListening() {
    if (_gatewaySubscription != null) return;

    // 监听 Gateway 消息
    _gatewaySubscription = _gateway.messageStream.listen(
      _handleGatewayMessage,
      onError: (error) {
        _responseController.addError(error);
      },
    );

    // 监听连接状态变化
    _statusSubscription = _gateway.statusStream.listen((state) {
      if (state == GatewayConnectionState.disconnected ||
          state == GatewayConnectionState.failed) {
        // 连接断开，标记待发送消息为失败
        _handleConnectionLost();
      }
    });
  }

  /// 停止监听
  void stopListening() {
    _gatewaySubscription?.cancel();
    _gatewaySubscription = null;
    _statusSubscription?.cancel();
    _statusSubscription = null;
  }

  void _handleGatewayMessage(AgpMessage message) {
    switch (message.method) {
      case AgpMessageType.sessionUpdate:
        _handleSessionUpdate(message);
        break;
      case AgpMessageType.toolCall:
        _handleToolCall(message);
        break;
      case AgpMessageType.toolResult:
        _handleToolResult(message);
        break;
      case AgpMessageType.error:
        _handleError(message);
        break;
      default:
        break;
    }
  }

  void _handleSessionUpdate(AgpMessage message) {
    final content = message.payload['content'] as String? ?? '';
    final isComplete = message.payload['complete'] as bool? ?? false;

    // 追加内容到缓冲
    _pendingContent.write(content);

    // 发送流式更新
    _responseController.add(ChatResponse(
      messageId: _pendingAiMessageId ?? '',
      content: _pendingContent.toString(),
      sender: MessageSender.ai,
      isComplete: isComplete,
    ));

    // 更新数据库中的消息内容
    if (_pendingAiMessageId != null) {
      _messageRepo.updateContent(
        _pendingAiMessageId!,
        _pendingContent.toString(),
      );
    }

    // 消息完成
    if (isComplete) {
      _finalizeAiMessage();
    }
  }

  void _handleToolCall(AgpMessage message) {
    final toolName = message.payload['tool_name'] as String?;
    final toolArgs = message.payload['args'] as Map<String, dynamic>?;

    // 保存工具调用消息
    if (_currentConversationId != null && toolName != null) {
      _messageRepo.create(
        conversationId: _currentConversationId!,
        content: toolArgs.toString(),
        sender: MessageSender.tool,
        toolName: toolName,
        status: MessageStatus.pending,
      );
    }

    // 发送工具调用通知
    _responseController.add(ChatResponse(
      messageId: _pendingAiMessageId ?? '',
      content: _pendingContent.toString(),
      sender: MessageSender.ai,
      toolName: toolName,
      isComplete: false,
    ));
  }

  void _handleToolResult(AgpMessage message) {
    final toolName = message.payload['tool_name'] as String?;
    final result = message.payload['result'] as String?;

    // 更新工具调用结果
    _responseController.add(ChatResponse(
      messageId: _pendingAiMessageId ?? '',
      content: _pendingContent.toString(),
      sender: MessageSender.ai,
      toolName: toolName,
      toolResult: result,
      isComplete: false,
    ));
  }

  void _handleError(AgpMessage message) {
    final errorMessage = message.payload['message'] as String? ?? 'Unknown error';

    // 标记待发送消息为失败
    if (_pendingAiMessageId != null) {
      _messageRepo.updateStatus(_pendingAiMessageId!, MessageStatus.failed);
    }

    // 发送错误响应
    _responseController.addError(errorMessage);
    _finalizeAiMessage();
  }

  void _handleConnectionLost() {
    // 标记待发送消息为失败
    if (_pendingAiMessageId != null) {
      _messageRepo.updateStatus(_pendingAiMessageId!, MessageStatus.failed);
    }
  }

  void _finalizeAiMessage() {
    // 标记消息为已发送
    if (_pendingAiMessageId != null) {
      _messageRepo.updateStatus(_pendingAiMessageId!, MessageStatus.sent);
    }

    // 更新会话的最后一条消息
    if (_currentConversationId != null) {
      _conversationRepo.updateLastMessage(
        _currentConversationId!,
        _pendingContent.toString(),
      );
    }

    // 重置状态
    _pendingContent.clear();
    _pendingAiMessageId = null;
  }

  void dispose() {
    stopListening();
    _responseController.close();
  }
}

/// ChatService Provider
@riverpod
ChatService chatService(Ref ref) {
  final gateway = ref.watch(gatewayServiceProvider);
  final conversationRepo = ref.watch(conversationRepositoryProvider);
  final messageRepo = ref.watch(messageRepositoryProvider);

  final service = ChatService(
    gateway: gateway,
    conversationRepo: conversationRepo,
    messageRepo: messageRepo,
  );

  ref.onDispose(() => service.dispose());

  return service;
}
