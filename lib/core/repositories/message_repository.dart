import 'package:drift/drift.dart';
import 'package:mbot_mobile/core/models/database.dart';
import 'package:mbot_mobile/core/models/message.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message_repository.g.dart';

/// 消息仓库
class MessageRepository {
  final MBotDatabase _db;

  MessageRepository(this._db);

  /// 创建新消息
  Future<MessageData> create({
    required String conversationId,
    required String content,
    required MessageSender sender,
    String? toolName,
    String? toolResult,
    MessageStatus status = MessageStatus.pending,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final companion = MessagesCompanion.insert(
      id: id,
      conversationId: conversationId,
      content: content,
      sender: sender.name,
      timestamp: now,
      toolName: toolName == null
          ? const Value.absent()
          : Value(toolName),
      toolResult: toolResult == null
          ? const Value.absent()
          : Value(toolResult),
      status: status.name,
    );

    await _db.into(_db.messages).insert(companion);

    return MessageData(
      id: id,
      conversationId: conversationId,
      content: content,
      sender: sender,
      timestamp: now,
      toolName: toolName,
      toolResult: toolResult,
      status: status,
    );
  }

  /// 获取会话的所有消息（按时间正序）
  Future<List<MessageData>> getByConversation(String conversationId) async {
    final query = _db.select(_db.messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]);

    final results = await query.get();
    return results.map((e) => MessageData.fromDB(e)).toList();
  }

  /// 监听会话消息流（自动更新）
  Stream<List<MessageData>> watchByConversation(String conversationId) {
    final query = _db.select(_db.messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm.asc(t.timestamp)]);

    return query.watch().map(
      (rows) => rows.map((e) => MessageData.fromDB(e)).toList(),
    );
  }

  /// 获取单个消息
  Future<MessageData?> getById(String id) async {
    final query = _db.select(_db.messages)..where((t) => t.id.equals(id));

    final result = await query.getSingleOrNull();
    return result != null ? MessageData.fromDB(result) : null;
  }

  /// 更新消息
  Future<void> update(MessageData message) async {
    final companion = MessagesCompanion(
      id: Value(message.id),
      content: Value(message.content),
      toolName: message.toolName == null
          ? const Value.absent()
          : Value(message.toolName),
      toolResult: message.toolResult == null
          ? const Value.absent()
          : Value(message.toolResult),
      status: Value(message.status.name),
    );

    await _db.update(_db.messages).replace(companion);
  }

  /// 更新消息状态
  Future<void> updateStatus(String messageId, MessageStatus status) async {
    final companion = MessagesCompanion(
      id: Value(messageId),
      status: Value(status.name),
    );

    await _db.update(_db.messages).replace(companion);
  }

  /// 更新消息内容
  Future<void> updateContent(String messageId, String content) async {
    final companion = MessagesCompanion(
      id: Value(messageId),
      content: Value(content),
    );

    await _db.update(_db.messages).replace(companion);
  }

  /// 删除消息
  Future<void> delete(String id) async {
    await (_db.delete(_db.messages)..where((t) => t.id.equals(id))).go();
  }

  /// 删除会话的所有消息
  Future<void> deleteByConversation(String conversationId) async {
    await (_db.delete(_db.messages)
          ..where((t) => t.conversationId.equals(conversationId)))
        .go();
  }
}

/// MessageRepository Provider
@riverpod
MessageRepository messageRepository(Ref ref) {
  return MessageRepository(MBotDatabase.instance);
}
