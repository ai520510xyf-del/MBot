import 'package:drift/drift.dart' as drift;
import 'database.dart';

/// 消息发送者类型
enum MessageSender {
  user,
  ai,
  tool,
}

/// 消息状态
enum MessageStatus {
  pending,
  sending,
  sent,
  failed,
}

/// 消息数据模型 (不可变)
class MessageData {
  final String id;
  final String conversationId;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final String? toolName;
  final String? toolResult;
  final MessageStatus status;

  const MessageData({
    required this.id,
    required this.conversationId,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.toolName,
    this.toolResult,
    required this.status,
  });

  /// 从数据库实体转换
  factory MessageData.fromDB(Message message) {
    return MessageData(
      id: message.id,
      conversationId: message.conversationId,
      content: message.content,
      sender: _senderFromString(message.sender),
      timestamp: message.timestamp,
      toolName: message.toolName,
      toolResult: message.toolResult,
      status: _statusFromString(message.status),
    );
  }

  /// 复制并修改部分字段
  MessageData copyWith({
    String? id,
    String? conversationId,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    String? toolName,
    String? toolResult,
    MessageStatus? status,
  }) {
    return MessageData(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      toolName: toolName ?? this.toolName,
      toolResult: toolResult ?? this.toolResult,
      status: status ?? this.status,
    );
  }
}

/// MessageData 扩展方法
extension MessageDataX on MessageData {
  /// 转换为数据库插入实体
  MessagesCompanion toDBCompanion() {
    return MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      content: content,
      sender: sender.name,
      timestamp: timestamp,
      toolName: toolName == null
          ? const drift.Value.absent()
          : drift.Value(toolName),
      toolResult: toolResult == null
          ? const drift.Value.absent()
          : drift.Value(toolResult),
      status: status.name,
    );
  }
}

/// 从字符串解析发送者类型
MessageSender _senderFromString(String value) {
  return MessageSender.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MessageSender.user,
  );
}

/// 从字符串解析消息状态
MessageStatus _statusFromString(String value) {
  return MessageStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MessageStatus.pending,
  );
}
