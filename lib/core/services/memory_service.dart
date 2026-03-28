import 'package:drift/drift.dart';
import '../models/memory.dart';
import '../models/database.dart';

/// 记忆服务
class MemoryService {
  final MBotDatabase _db;

  MemoryService(this._db);

  /// 存储记忆
  Future<void> storeMemory({
    required String content,
    required MemoryCategory category,
    MemorySource source = MemorySource.ai,
  }) async {
    final now = DateTime.now();
    final id = _generateId();

    await _db
        .into(_db.memories)
        .insert(
          MemoriesCompanion(
            id: Value(id),
            content: Value(content),
            category: Value(category.value),
            source: Value(source.value),
            createdAt: Value(now),
            updatedAt: Value(now),
          ),
        );
  }

  /// 搜索记忆
  Future<List<MemoryData>> searchMemories({
    String? query,
    MemoryCategory? category,
    int limit = 50,
  }) async {
    var stmt = _db.select(_db.memories);

    // 按分类过滤
    if (category != null) {
      stmt = stmt..where((tbl) => tbl.category.equals(category.value));
    }

    // 按搜索关键词过滤
    if (query != null && query.isNotEmpty) {
      stmt = stmt..where((tbl) => tbl.content.contains(query));
    }

    // 按更新时间倒序
    stmt = stmt..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]);

    // 限制结果数量
    stmt = stmt..limit(limit);

    final memories = await stmt.get();
    return memories.map((m) => MemoryData.fromDB(m)).toList();
  }

  /// 获取所有记忆
  Future<List<MemoryData>> getAllMemories() async {
    final memories = await (_db.select(
      _db.memories,
    )..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)])).get();
    return memories.map((m) => MemoryData.fromDB(m)).toList();
  }

  /// 根据分类获取记忆
  Future<List<MemoryData>> getMemoriesByCategory(
    MemoryCategory category,
  ) async {
    final memories =
        await (_db.select(_db.memories)
              ..where((tbl) => tbl.category.equals(category.value))
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.updatedAt)]))
            .get();
    return memories.map((m) => MemoryData.fromDB(m)).toList();
  }

  /// 根据ID获取记忆
  Future<MemoryData?> getMemoryById(String id) async {
    final memory = await (_db.select(
      _db.memories,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return memory != null ? MemoryData.fromDB(memory) : null;
  }

  /// 更新记忆
  Future<void> updateMemory({
    required String id,
    String? content,
    MemoryCategory? category,
  }) async {
    final now = DateTime.now();
    final companion = MemoriesCompanion(updatedAt: Value(now));

    if (content != null) {
      companion.copyWith(content: Value(content));
    }
    if (category != null) {
      companion.copyWith(category: Value(category.value));
    }

    await (_db.update(
      _db.memories,
    )..where((tbl) => tbl.id.equals(id))).write(companion);
  }

  /// 删除记忆
  Future<void> deleteMemory(String id) async {
    await (_db.delete(_db.memories)..where((tbl) => tbl.id.equals(id))).go();
  }

  /// 清空所有记忆
  Future<void> clearAllMemories() async {
    await _db.delete(_db.memories).go();
  }

  /// 自动分类记忆
  MemoryCategory autoCategorizeMemory(String content) {
    final lowerContent = content.toLowerCase();

    // 偏好类记忆识别
    if (lowerContent.contains('喜欢') ||
        lowerContent.contains('偏爱') ||
        lowerContent.contains('prefer') ||
        lowerContent.contains('favorite')) {
      return MemoryCategory.preference;
    }

    // 决策类记忆识别
    if (lowerContent.contains('决定') ||
        lowerContent.contains('选择') ||
        lowerContent.contains('decision') ||
        lowerContent.contains('choose')) {
      return MemoryCategory.decision;
    }

    // 实体类记忆识别
    if (lowerContent.contains('是') ||
        lowerContent.contains('叫做') ||
        lowerContent.contains('名叫') ||
        lowerContent.contains('name is')) {
      return MemoryCategory.entity;
    }

    // 默认为事实类记忆
    return MemoryCategory.fact;
  }

  /// 获取记忆统计
  Future<Map<MemoryCategory, int>> getMemoryStats() async {
    final memories = await _db.select(_db.memories).get();
    final stats = <MemoryCategory, int>{};

    for (final memory in memories) {
      final category = MemoryCategory.fromValue(memory.category);
      stats[category] = (stats[category] ?? 0) + 1;
    }

    return stats;
  }

  /// 生成唯一ID
  String _generateId() {
    return 'mem_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  /// 生成随机字符串
  String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final sb = StringBuffer();
    for (var i = 0; i < length; i++) {
      sb.write(chars[(random + i) % chars.length]);
    }
    return sb.toString();
  }
}
