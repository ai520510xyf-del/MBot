import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/skill.dart';
import '../models/database.dart';
import '../services/skill_service.dart';

part 'skill_providers.g.dart';

/// 数据库实例 Provider
@riverpod
MBotDatabase database(Ref ref) {
  return MBotDatabase.instance;
}

/// 技能服务 Provider
@riverpod
SkillService skillService(Ref ref) {
  final db = ref.watch(databaseProvider);
  return SkillService(db);
}

/// 当前选中的分类
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  SkillCategory build() {
    return SkillCategory.all;
  }

  void setCategory(SkillCategory category) {
    state = category;
  }
}

/// 搜索查询
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() {
    return '';
  }

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// 可用技能列表 Provider
@riverpod
Future<List<SkillData>> availableSkills(Ref ref) async {
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final service = ref.watch(skillServiceProvider);

  // 初始化默认技能数据
  await service.initializeDefaultSkills();

  return service.fetchAvailableSkills(
    category: category,
    searchQuery: searchQuery.isEmpty ? null : searchQuery,
  );
}

/// 已安装技能列表 Provider
@riverpod
Future<List<SkillData>> installedSkills(Ref ref) async {
  final service = ref.watch(skillServiceProvider);
  return service.getInstalledSkills();
}

/// 技能操作状态
@riverpod
class SkillState extends _$SkillState {
  @override
  Map<String, SkillStatus> build() {
    return {};
  }

  /// 安装技能
  Future<void> installSkill(String skillId) async {
    final service = ref.read(skillServiceProvider);
    await service.installSkill(skillId);
    state = {...state, skillId: SkillStatus.installed};
  }

  /// 卸载技能
  Future<void> uninstallSkill(String skillId) async {
    final service = ref.read(skillServiceProvider);
    await service.uninstallSkill(skillId);
    state = {...state, skillId: SkillStatus.available};
  }

  /// 刷新技能列表
  Future<void> refresh() async {
    // 触发 Provider 重新获取数据
    state = {...state};
  }

  /// 检查技能是否已安装
  bool isInstalled(String skillId) {
    return state[skillId] == SkillStatus.installed;
  }
}

/// 技能详情 Provider
@riverpod
Future<SkillData?> skillDetail(Ref ref, String skillId) async {
  final service = ref.watch(skillServiceProvider);
  return service.getSkillDetail(skillId);
}

/// 分类列表 Provider
@riverpod
List<SkillCategory> categoryList(Ref ref) {
  return SkillCategory.values;
}
