import 'package:drift/drift.dart' as drift;
import 'database.dart';

/// 技能状态
enum SkillStatus {
  /// 未安装
  available,
  /// 已安装
  installed,
  /// 更新可用
  updateAvailable,
  /// 已禁用
  disabled,
}

/// 技能分类
enum SkillCategory {
  /// 全部
  all,
  /// AI
  ai,
  /// 文本
  text,
  /// 图像
  image,
  /// 编程
  code,
  /// 效率
  productivity,
}

/// 从字符串解析技能状态
SkillStatus statusFromString(String value) {
  return SkillStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SkillStatus.available,
  );
}

/// 从字符串解析技能分类
SkillCategory categoryFromString(String value) {
  return SkillCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => SkillCategory.all,
  );
}

/// 技能数据模型 (不可变)
class SkillData {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final String version;
  final String author;
  final int installCount;
  final double rating;
  final DateTime? installedAt;
  final SkillStatus status;
  final SkillCategory category;
  final List<String> tags;

  const SkillData({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.version,
    required this.author,
    required this.installCount,
    required this.rating,
    this.installedAt,
    required this.status,
    required this.category,
    this.tags = const [],
  });

  /// 从数据库实体转换
  factory SkillData.fromDB(Skill skill) {
    return SkillData(
      id: skill.id,
      name: skill.name,
      description: skill.description,
      emoji: skill.emoji,
      version: skill.version,
      author: skill.author,
      installCount: skill.installCount,
      rating: skill.rating,
      installedAt: skill.installedAt,
      status: statusFromString(skill.status),
      category: categoryFromString(skill.category),
      tags: skill.tags.split(',').where((t) => t.isNotEmpty).toList(),
    );
  }

  /// 复制并修改部分字段
  SkillData copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    String? version,
    String? author,
    int? installCount,
    double? rating,
    DateTime? installedAt,
    SkillStatus? status,
    SkillCategory? category,
    List<String>? tags,
  }) {
    return SkillData(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      version: version ?? this.version,
      author: author ?? this.author,
      installCount: installCount ?? this.installCount,
      rating: rating ?? this.rating,
      installedAt: installedAt ?? this.installedAt,
      status: status ?? this.status,
      category: category ?? this.category,
      tags: tags ?? this.tags,
    );
  }

  /// 是否已安装
  bool get isInstalled => status == SkillStatus.installed || status == SkillStatus.updateAvailable;

  /// 是否可用
  bool get isAvailable => status == SkillStatus.available;

  /// 格式化安装数量
  String get formattedInstallCount {
    if (installCount >= 1000000) {
      return '${(installCount / 1000000).toStringAsFixed(1)}M';
    } else if (installCount >= 1000) {
      return '${(installCount / 1000).toStringAsFixed(1)}K';
    }
    return installCount.toString();
  }

  /// 格式化评分
  String get formattedRating => rating.toStringAsFixed(1);
}

/// SkillData 扩展方法
extension SkillDataX on SkillData {
  /// 转换为数据库插入实体
  SkillsCompanion toDBCompanion() {
    return SkillsCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      description: drift.Value(description),
      emoji: drift.Value(emoji),
      version: drift.Value(version),
      author: drift.Value(author),
      installCount: drift.Value(installCount),
      rating: drift.Value(rating),
      installedAt: installedAt == null
          ? const drift.Value.absent()
          : drift.Value(installedAt!),
      status: drift.Value(status.name),
      category: drift.Value(category.name),
      tags: drift.Value(tags.join(',')),
    );
  }
}

/// 技能分类显示名称
String categoryDisplayName(SkillCategory category) {
  switch (category) {
    case SkillCategory.all:
      return '全部';
    case SkillCategory.ai:
      return 'AI';
    case SkillCategory.text:
      return '文本';
    case SkillCategory.image:
      return '图像';
    case SkillCategory.code:
      return '编程';
    case SkillCategory.productivity:
      return '效率';
  }
}
