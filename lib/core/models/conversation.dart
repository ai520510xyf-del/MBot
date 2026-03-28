import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

/// 会话状态
enum ConversationStatus {
  /// 活跃
  active,

  /// 已归档
  archived,

  /// 已删除
  deleted,
}

/// 会话数据模型
@freezed
class ConversationData with _$ConversationData {
  const factory ConversationData({
    required String id,
    required String title,
    required String agentId,
    required ConversationStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    DateTime? lastMessageAt,
    @Default(0) int messageCount,
  }) = _ConversationData;

  factory ConversationData.fromJson(Map<String, dynamic> json) =>
      _$ConversationDataFromJson(json);
}

/// 会话创建参数
class ConversationCreateParams {
  final String title;
  final String agentId;

  const ConversationCreateParams({required this.title, required this.agentId});
}
