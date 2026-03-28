import 'package:drift/drift.dart';
import '../models/skill.dart';
import '../models/database.dart';

/// 技能服务
class SkillService {
  final MBotDatabase _db;

  SkillService(this._db);

  /// 获取可用的技能列表 (模拟 ClawHub API)
  Future<List<SkillData>> fetchAvailableSkills({
    SkillCategory? category,
    String? searchQuery,
  }) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock 技能数据
    final mockSkills = _getMockSkills();

    // 过滤分类
    var filtered = category != null && category != SkillCategory.all
        ? mockSkills.where((s) => s.category == category).toList()
        : mockSkills;

    // 过滤搜索
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query) ||
                s.tags.any((t) => t.toLowerCase().contains(query)),
          )
          .toList();
    }

    return filtered;
  }

  /// 获取已安装的技能列表
  Future<List<SkillData>> getInstalledSkills() async {
    final skills = await (_db.select(
      _db.skills,
    )..where((tbl) => tbl.status.equals('installed'))).get();

    // 排序
    final sorted = skills..sort((a, b) => a.name.compareTo(b.name));

    return sorted.map((s) => SkillData.fromDB(s)).toList();
  }

  /// 安装技能
  Future<void> installSkill(String skillId) async {
    // 获取技能信息
    final availableSkills = await fetchAvailableSkills();
    final skill = availableSkills.firstWhere((s) => s.id == skillId);

    // 检查是否已存在
    final existing = await (_db.select(
      _db.skills,
    )..where((tbl) => tbl.id.equals(skillId))).getSingleOrNull();

    if (existing != null) {
      // 更新现有记录
      await (_db.update(
        _db.skills,
      )..where((tbl) => tbl.id.equals(skillId))).write(
        SkillsCompanion(
          status: const Value('installed'),
          installedAt: Value(DateTime.now()),
          installCount: Value(skill.installCount + 1),
        ),
      );
    } else {
      // 插入新记录
      await _db
          .into(_db.skills)
          .insert(
            SkillsCompanion(
              id: Value(skillId),
              name: Value(skill.name),
              description: Value(skill.description),
              emoji: Value(skill.emoji),
              version: Value(skill.version),
              author: Value(skill.author),
              installCount: Value(skill.installCount + 1),
              rating: Value(skill.rating),
              installedAt: Value(DateTime.now()),
              status: const Value('installed'),
              category: Value(skill.category.name),
              tags: Value(skill.tags.join(',')),
            ),
          );
    }
  }

  /// 卸载技能
  Future<void> uninstallSkill(String skillId) async {
    await (_db.update(
      _db.skills,
    )..where((tbl) => tbl.id.equals(skillId))).write(
      const SkillsCompanion(
        status: Value('available'),
        installedAt: Value.absent(),
      ),
    );
  }

  /// 初始化默认技能数据
  Future<void> initializeDefaultSkills() async {
    // 检查是否已有技能数据
    final existingCount = await (_db.select(_db.skills).get()).then(
      (s) => s.length,
    );
    if (existingCount > 0) return;

    // 插入默认技能
    final mockSkills = _getMockSkills();
    for (final skill in mockSkills) {
      await _db.into(_db.skills).insert(skill.toDBCompanion());
    }
  }

  /// 更新技能 (模拟从 ClawHub 获取更新)
  Future<void> updateSkill(String skillId) async {
    await (_db.update(_db.skills)..where((tbl) => tbl.id.equals(skillId)))
        .write(const SkillsCompanion(status: Value('installed')));
  }

  /// 获取技能详情
  Future<SkillData?> getSkillDetail(String skillId) async {
    final availableSkills = await fetchAvailableSkills();
    try {
      return availableSkills.firstWhere((s) => s.id == skillId);
    } catch (_) {
      return null;
    }
  }

  /// Mock 技能数据
  List<SkillData> _getMockSkills() {
    return [
      SkillData(
        id: 'skill_001',
        name: 'AI 写作助手',
        description: '智能文章生成与优化，支持多种文体风格',
        emoji: '🤖',
        version: '2.1.0',
        author: 'ClawHub Official',
        installCount: 12453,
        rating: 4.8,
        status: SkillStatus.available,
        category: SkillCategory.ai,
        tags: ['写作', '生成', '优化', 'AI', '文章'],
      ),
      SkillData(
        id: 'skill_002',
        name: '文本摘要',
        description: '长文本快速提取要点，支持中英文',
        emoji: '📝',
        version: '1.5.2',
        author: 'TextMaster',
        installCount: 8567,
        rating: 4.6,
        status: SkillStatus.available,
        category: SkillCategory.text,
        tags: ['摘要', '提取', '文本', '总结'],
      ),
      SkillData(
        id: 'skill_003',
        name: 'AI 绘画',
        description: '文字描述生成精美图片，支持多种风格',
        emoji: '🎨',
        version: '3.0.1',
        author: 'ArtBot',
        installCount: 23421,
        rating: 4.9,
        status: SkillStatus.available,
        category: SkillCategory.image,
        tags: ['绘画', '生成', '图片', 'AI', '艺术'],
      ),
      SkillData(
        id: 'skill_004',
        name: '代码助手',
        description: '代码生成与调试，支持多种编程语言',
        emoji: '💻',
        version: '2.3.0',
        author: 'DevTools',
        installCount: 15234,
        rating: 4.7,
        status: SkillStatus.available,
        category: SkillCategory.code,
        tags: ['代码', '生成', '调试', '编程', '开发'],
      ),
      SkillData(
        id: 'skill_005',
        name: '网页总结',
        description: '网页内容快速总结，提取关键信息',
        emoji: '🌐',
        version: '1.2.5',
        author: 'WebSummary',
        installCount: 6234,
        rating: 4.5,
        status: SkillStatus.available,
        category: SkillCategory.productivity,
        tags: ['网页', '总结', '提取', '效率'],
      ),
      SkillData(
        id: 'skill_006',
        name: '数据分析',
        description: '智能数据分析报告生成，可视化展示',
        emoji: '📊',
        version: '1.8.0',
        author: 'DataInsight',
        installCount: 9456,
        rating: 4.8,
        status: SkillStatus.available,
        category: SkillCategory.ai,
        tags: ['数据', '分析', '报告', '可视化'],
      ),
      SkillData(
        id: 'skill_007',
        name: '文档处理',
        description: 'PDF/Word 文档解析与内容提取',
        emoji: '📎',
        version: '1.4.3',
        author: 'DocMaster',
        installCount: 7823,
        rating: 4.4,
        status: SkillStatus.available,
        category: SkillCategory.productivity,
        tags: ['文档', 'PDF', 'Word', '解析'],
      ),
      SkillData(
        id: 'skill_008',
        name: '音乐推荐',
        description: '基于喜好的智能音乐推荐',
        emoji: '🎵',
        version: '1.1.0',
        author: 'MusicAI',
        installCount: 4201,
        rating: 4.3,
        status: SkillStatus.available,
        category: SkillCategory.ai,
        tags: ['音乐', '推荐', 'AI', '娱乐'],
      ),
      SkillData(
        id: 'skill_009',
        name: '翻译助手',
        description: '多语言实时翻译，支持文本和语音',
        emoji: '🌍',
        version: '2.0.0',
        author: 'TransLab',
        installCount: 18765,
        rating: 4.7,
        status: SkillStatus.available,
        category: SkillCategory.text,
        tags: ['翻译', '多语言', '实时'],
      ),
      SkillData(
        id: 'skill_010',
        name: '图像识别',
        description: '智能图像识别与物体检测',
        emoji: '👁️',
        version: '1.6.2',
        author: 'VisionBot',
        installCount: 11234,
        rating: 4.6,
        status: SkillStatus.available,
        category: SkillCategory.image,
        tags: ['图像', '识别', '检测', 'AI'],
      ),
      SkillData(
        id: 'skill_011',
        name: '日历管理',
        description: '智能日程安排与提醒',
        emoji: '📅',
        version: '1.3.1',
        author: 'TimeKeeper',
        installCount: 5432,
        rating: 4.5,
        status: SkillStatus.available,
        category: SkillCategory.productivity,
        tags: ['日历', '日程', '提醒', '效率'],
      ),
      SkillData(
        id: 'skill_012',
        name: '代码解释',
        description: '代码片段解释与注释生成',
        emoji: '🔍',
        version: '1.2.0',
        author: 'CodeExplainer',
        installCount: 8765,
        rating: 4.4,
        status: SkillStatus.available,
        category: SkillCategory.code,
        tags: ['代码', '解释', '注释', '编程'],
      ),
    ];
  }
}
