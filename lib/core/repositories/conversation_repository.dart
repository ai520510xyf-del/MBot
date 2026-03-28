import 'package:drift/drift.dart';
import 'package:mbot_mobile/core/models/database.dart';
import 'package:mbot_mobile/core/models/conversation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'conversation_repository.g.dart';

/// 会话仓库
class ConversationRepository {
  final MBotDatabase _db;

  ConversationRepository(this._db);

  /// 创建新会话
  Future<ConversationData> create({required String title}) async {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final companion = ConversationsCompanion.insert(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
    );

    await _db.into(_db.conversations).insert(companion);

    return ConversationData(
      id: id,
      title: title,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 获取所有会话（按更新时间倒序）
  Future<List<ConversationData>> getAll() async {
    final query = _db.select(_db.conversations)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    final results = await query.get();
    return results.map((e) => ConversationData.fromDB(e)).toList();
  }

  /// 获取会话流（自动更新）
  Stream<List<ConversationData>> watchAll() {
    final query = _db.select(_db.conversations)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);

    return query.watch().map(
      (rows) => rows.map((e) => ConversationData.fromDB(e)).toList(),
    );
  }

  /// 获取单个会话
  Future<ConversationData?> getById(String id) async {
    final query = _db.select(_db.conversations)..where((t) => t.id.equals(id));

    final result = await query.getSingleOrNull();
    return result != null ? ConversationData.fromDB(result) : null;
  }

  /// 更新会话
  Future<void> update(ConversationData conversation) async {
    final companion = ConversationsCompanion(
      id: Value(conversation.id),
      title: Value(conversation.title),
      lastMessage: Value(conversation.lastMessage),
      updatedAt: Value(DateTime.now()),
    );

    await _db.update(_db.conversations).replace(companion);
  }

  /// 更新会话的最后一条消息
  Future<void> updateLastMessage(String conversationId, String message) async {
    final companion = ConversationsCompanion(
      id: Value(conversationId),
      lastMessage: Value(message),
      updatedAt: Value(DateTime.now()),
    );

    await _db.update(_db.conversations).replace(companion);
  }

  /// 删除会话
  Future<void> delete(String id) async {
    await _db.transaction(() async {
      // 先删除会话的所有消息
      await (_db.delete(
        _db.messages,
      )..where((t) => t.conversationId.equals(id))).go();

      // 再删除会话
      await (_db.delete(_db.conversations)..where((t) => t.id.equals(id))).go();
    });
  }
}

/// ConversationRepository Provider
@riverpod
ConversationRepository conversationRepository(Ref ref) {
  return ConversationRepository(MBotDatabase.instance);
}
