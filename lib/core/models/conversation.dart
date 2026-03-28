import 'package:drift/drift.dart' as drift;
import 'database.dart';

/// 会话数据模型 (不可变)
class ConversationData {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastMessage;

  const ConversationData({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
  });

  /// 从数据库实体转换
  factory ConversationData.fromDB(Conversation conversation) {
    return ConversationData(
      id: conversation.id,
      title: conversation.title,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      lastMessage: conversation.lastMessage,
    );
  }

  /// 复制并修改部分字段
  ConversationData copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? lastMessage,
  }) {
    return ConversationData(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}

/// ConversationData 扩展方法
extension ConversationDataX on ConversationData {
  /// 转换为数据库插入实体
  ConversationsCompanion toDBCompanion() {
    return ConversationsCompanion.insert(
      id: id,
      title: title,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastMessage: lastMessage == null
          ? const drift.Value.absent()
          : drift.Value(lastMessage),
    );
  }
}
