import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/memory.dart';
import '../models/database.dart';
import '../services/memory_service.dart';

part 'memory_providers.g.dart';

/// 记忆服务 Provider
@riverpod
MemoryService memoryService(Ref ref) {
  final db = MBotDatabase.instance;
  return MemoryService(db);
}

/// 当前选中的分类
@riverpod
class SelectedMemoryCategory extends _$SelectedMemoryCategory {
  @override
  MemoryCategory build() {
    return MemoryCategory.fact;
  }

  void setCategory(MemoryCategory category) {
    state = category;
  }
}

/// 记忆搜索查询
@riverpod
class MemorySearchQuery extends _$MemorySearchQuery {
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

/// 所有记忆列表 Provider
@riverpod
Future<List<MemoryData>> allMemories(Ref ref) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getAllMemories();
}

/// 搜索/过滤后的记忆列表 Provider
@riverpod
Future<List<MemoryData>> filteredMemories(Ref ref) async {
  final category = ref.watch(selectedMemoryCategoryProvider);
  final searchQuery = ref.watch(memorySearchQueryProvider);
  final service = ref.watch(memoryServiceProvider);

  return service.searchMemories(
    query: searchQuery.isEmpty ? null : searchQuery,
    category: category,
  );
}

/// 记忆统计 Provider
@riverpod
Future<Map<MemoryCategory, int>> memoryStats(Ref ref) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getMemoryStats();
}

/// 记忆操作状态
@riverpod
class MemoryState extends _$MemoryState {
  @override
  Set<String> build() {
    return {};
  }

  /// 存储记忆
  Future<void> storeMemory({
    required String content,
    required MemoryCategory category,
    MemorySource source = MemorySource.ai,
  }) async {
    final service = ref.read(memoryServiceProvider);
    await service.storeMemory(
      content: content,
      category: category,
      source: source,
    );
    // 触发刷新
    ref.invalidate(allMemoriesProvider);
    ref.invalidate(filteredMemoriesProvider);
    ref.invalidate(memoryStatsProvider);
  }

  /// 自动分类并存储记忆
  Future<void> storeMemoryAuto({
    required String content,
    MemorySource source = MemorySource.ai,
  }) async {
    final service = ref.read(memoryServiceProvider);
    final category = service.autoCategorizeMemory(content);
    await storeMemory(content: content, category: category, source: source);
  }

  /// 删除记忆
  Future<void> deleteMemory(String memoryId) async {
    final service = ref.read(memoryServiceProvider);
    await service.deleteMemory(memoryId);
    state = {...state}..remove(memoryId);
    // 触发刷新
    ref.invalidate(allMemoriesProvider);
    ref.invalidate(filteredMemoriesProvider);
    ref.invalidate(memoryStatsProvider);
  }

  /// 更新记忆
  Future<void> updateMemory({
    required String id,
    String? content,
    MemoryCategory? category,
  }) async {
    final service = ref.read(memoryServiceProvider);
    await service.updateMemory(id: id, content: content, category: category);
    // 触发刷新
    ref.invalidate(allMemoriesProvider);
    ref.invalidate(filteredMemoriesProvider);
  }

  /// 清空所有记忆
  Future<void> clearAll() async {
    final service = ref.read(memoryServiceProvider);
    await service.clearAllMemories();
    // 触发刷新
    ref.invalidate(allMemoriesProvider);
    ref.invalidate(filteredMemoriesProvider);
    ref.invalidate(memoryStatsProvider);
  }

  /// 刷新记忆列表
  Future<void> refresh() async {
    // 触发 Provider 重新获取数据
    ref.invalidate(allMemoriesProvider);
    ref.invalidate(filteredMemoriesProvider);
    ref.invalidate(memoryStatsProvider);
  }

  /// 检查记忆是否正在加载
  bool isLoading(String memoryId) {
    return state.contains(memoryId);
  }
}

/// 分类列表 Provider
@riverpod
List<MemoryCategory> memoryCategoryList(Ref ref) {
  return MemoryCategory.values;
}

/// 根据ID获取记忆 Provider
@riverpod
Future<MemoryData?> memoryById(Ref ref, String id) async {
  final service = ref.watch(memoryServiceProvider);
  return service.getMemoryById(id);
}
