import 'database.dart';

/// 记忆分类枚举
enum MemoryCategory {
  preference('preference', '偏好'),
  fact('fact', '事实'),
  decision('decision', '决策'),
  entity('entity', '实体');

  final String value;
  final String label;

  const MemoryCategory(this.value, this.label);

  static MemoryCategory fromValue(String value) {
    return MemoryCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MemoryCategory.fact,
    );
  }
}

/// 记忆来源枚举
enum MemorySource {
  user('user', '用户'),
  ai('ai', 'AI'),
  system('system', '系统');

  final String value;
  final String label;

  const MemorySource(this.value, this.label);

  static MemorySource fromValue(String value) {
    return MemorySource.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MemorySource.system,
    );
  }
}

/// 记忆数据模型 (不可变)
class MemoryData {
  final String id;
  final String content;
  final MemoryCategory category;
  final MemorySource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemoryData({
    required this.id,
    required this.content,
    required this.category,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库实体转换
  factory MemoryData.fromDB(Memory memory) {
    return MemoryData(
      id: memory.id,
      content: memory.content,
      category: MemoryCategory.fromValue(memory.category),
      source: MemorySource.fromValue(memory.source),
      createdAt: memory.createdAt,
      updatedAt: memory.updatedAt,
    );
  }

  /// 复制并修改部分字段
  MemoryData copyWith({
    String? id,
    String? content,
    MemoryCategory? category,
    MemorySource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemoryData(
      id: id ?? this.id,
      content: content ?? this.content,
      category: category ?? this.category,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// MemoryData 扩展方法
extension MemoryDataX on MemoryData {
  /// 转换为数据库插入实体
  MemoriesCompanion toDBCompanion() {
    return MemoriesCompanion.insert(
      id: id,
      content: content,
      category: category.value,
      source: source.value,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
