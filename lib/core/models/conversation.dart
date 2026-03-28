import 'package:drift/drift.dart' as drift;
import 'database.dart';

/// 会话状态
enum ConversationStatus {
  /// 活跃
  active,

  /// 已归档
  archived,

  /// 已删除
  deleted,
}

/// 从字符串解析会话状态
ConversationStatus conversationStatusFromString(String value) {
  return ConversationStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => ConversationStatus.active,
  );
}

/// 会话数据模型 (不可变)
class ConversationData {
  final String id;
  final String title;
  final String agentId;
  final ConversationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastMessageAt;
  final int messageCount;

  const ConversationData({
    required this.id,
    required this.title,
    required this.agentId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessageAt,
    this.messageCount = 0,
  });

  /// 从数据库实体转换
  factory ConversationData.fromDB(Conversation conversation) {
    return ConversationData(
      id: conversation.id,
      title: conversation.title,
      agentId: '', // Will be set by repository
      status: ConversationStatus.active, // Default status
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      lastMessageAt: null,
      messageCount: 0,
    );
  }

  /// 从 JSON 创建
  factory ConversationData.fromJson(Map<String, dynamic> json) {
    return ConversationData(
      id: json['id'] as String,
      title: json['title'] as String,
      agentId: json['agentId'] as String,
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lastMessageAt: json['lastMessageAt'] == null
          ? null
          : DateTime.parse(json['lastMessageAt'] as String),
      messageCount: json['messageCount'] as int? ?? 0,
    );
  }

  /// 复制并修改部分字段
  ConversationData copyWith({
    String? id,
    String? title,
    String? agentId,
    ConversationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastMessageAt,
    int? messageCount,
  }) {
    return ConversationData(
      id: id ?? this.id,
      title: title ?? this.title,
      agentId: agentId ?? this.agentId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }

  /// 是否为活跃状态
  bool get isActive => status == ConversationStatus.active;

  /// 是否已归档
  bool get isArchived => status == ConversationStatus.archived;

  /// 状态显示名称
  String get statusDisplayName {
    switch (status) {
      case ConversationStatus.active:
        return '活跃';
      case ConversationStatus.archived:
        return '已归档';
      case ConversationStatus.deleted:
        return '已删除';
    }
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'agentId': agentId,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messageCount': messageCount,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationData &&
        other.id == id &&
        other.title == title &&
        other.agentId == agentId &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.lastMessageAt == lastMessageAt &&
        other.messageCount == messageCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      agentId,
      status,
      createdAt,
      updatedAt,
      lastMessageAt,
      messageCount,
    );
  }

  @override
  String toString() {
    return 'ConversationData(id: $id, title: $title, agentId: $agentId, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, lastMessageAt: $lastMessageAt, messageCount: $messageCount)';
  }
}

/// ConversationData 扩展方法
extension ConversationDataX on ConversationData {
  /// 转换为数据库插入实体
  ConversationsCompanion toDBCompanion() {
    return ConversationsCompanion(
      id: drift.Value(id),
      title: drift.Value(title),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
      lastMessage: lastMessageAt != null
          ? drift.Value('') // Will be set by service
          : const drift.Value.absent(),
    );
  }
}

/// 会话创建参数
class ConversationCreateParams {
  final String title;
  final String agentId;

  const ConversationCreateParams({required this.title, required this.agentId});
}
