import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';
import '../../../../core/providers/memory_providers.dart';
import '../../../../core/models/memory.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 记忆管理页
class MemoryPage extends ConsumerStatefulWidget {
  const MemoryPage({super.key});

  @override
  ConsumerState<MemoryPage> createState() => _MemoryPageState();
}

class _MemoryPageState extends ConsumerState<MemoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _addController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoriesAsync = ref.watch(filteredMemoriesProvider);
    final selectedCategory = ref.watch(selectedMemoryCategoryProvider);
    final statsAsync = ref.watch(memoryStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('记忆管理'),
        actions: [
          // 添加记忆按钮
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMemoryDialog(context),
          ),
          // 更多菜单
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear_all') {
                _showClearAllDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('清空所有记忆'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类筛选栏
          _buildCategoryFilter(selectedCategory),

          // 搜索框
          _buildSearchBar(),

          // 记忆列表
          Expanded(
            child: memoriesAsync.when(
              data: (memories) {
                if (memories.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpace.s4),
                  itemCount: memories.length,
                  itemBuilder: (context, index) {
                    return _buildMemoryCard(memories[index]);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpace.s4),
                    const Text('加载失败', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ),
          ),

          // 统计信息
          _buildStatsBar(statsAsync),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(MemoryCategory selectedCategory) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: MemoryCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpace.s2),
            child: FilterChip(
              label: Text(category.label),
              selected: isSelected,
              onSelected: (_) {
                ref.read(selectedMemoryCategoryProvider.notifier).setCategory(category);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索记忆...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textTertiary),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(memorySearchQueryProvider.notifier).clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: AppRadius.radiusMD,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s3,
            vertical: AppSpace.s2,
          ),
        ),
        onChanged: (value) {
          ref.read(memorySearchQueryProvider.notifier).setQuery(value);
        },
      ),
    );
  }

  Widget _buildMemoryCard(MemoryData memory) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s3),
      padding: const EdgeInsets.all(AppSpace.s3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildCategoryChip(memory.category),
              const Spacer(),
              Text(
                _formatDate(memory.updatedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteDialog(context, memory.id);
                  } else if (value == 'edit') {
                    _showEditDialog(context, memory);
                  }
                },
                icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textTertiary),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 12),
                        Text('编辑'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        SizedBox(width: 12),
                        Text('删除'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            memory.content,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Row(
            children: [
              Icon(
                _getSourceIcon(memory.source),
                size: 14,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                memory.source.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(MemoryCategory category) {
    Color color;
    IconData icon;

    switch (category) {
      case MemoryCategory.preference:
        color = AppColors.primary;
        icon = Icons.favorite;
        break;
      case MemoryCategory.fact:
        color = AppColors.success;
        icon = Icons.info;
        break;
      case MemoryCategory.decision:
        color = AppColors.warning;
        icon = Icons.psychology;
        break;
      case MemoryCategory.entity:
        color = AppColors.info;
        icon = Icons.person;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.radiusXS,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(AsyncValue<Map<MemoryCategory, int>> statsAsync) {
    return statsAsync.when(
      data: (stats) {
        final total = stats.values.fold(0, (sum, count) => sum + count);
        return Container(
          padding: const EdgeInsets.all(AppSpace.s4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('总计', '$total', Icons.storage),
              _buildStatItem('偏好', '${stats[MemoryCategory.preference] ?? 0}', Icons.favorite),
              _buildStatItem('事实', '${stats[MemoryCategory.fact] ?? 0}', Icons.info),
              _buildStatItem('决策', '${stats[MemoryCategory.decision] ?? 0}', Icons.psychology),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.psychology_outlined, size: 64, color: AppColors.textTertiary),
          const SizedBox(height: AppSpace.s4),
          const Text(
            '暂无记忆',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          const Text(
            'AI 会通过对话学习你的偏好',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context) {
    MemoryCategory selectedCategory = MemoryCategory.fact;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加记忆'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addController,
                decoration: const InputDecoration(
                  hintText: '输入记忆内容...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: AppSpace.s4),
              DropdownButtonFormField<MemoryCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
                items: MemoryCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (_addController.text.trim().isNotEmpty) {
                  ref.read(memoryStateProvider.notifier).storeMemory(
                        content: _addController.text.trim(),
                        category: selectedCategory,
                        source: MemorySource.user,
                      );
                  _addController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, MemoryData memory) {
    final controller = TextEditingController(text: memory.content);
    MemoryCategory selectedCategory = memory.category;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑记忆'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpace.s4),
              DropdownButtonFormField<MemoryCategory>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: '分类',
                  border: OutlineInputBorder(),
                ),
                items: MemoryCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.label),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedCategory = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                ref.read(memoryStateProvider.notifier).updateMemory(
                      id: memory.id,
                      content: controller.text.trim(),
                      category: selectedCategory,
                    );
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String memoryId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记忆'),
        content: const Text('确定要删除这条记忆吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(memoryStateProvider.notifier).deleteMemory(memoryId);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空所有记忆'),
        content: const Text('确定要清空所有记忆吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(memoryStateProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  IconData _getSourceIcon(MemorySource source) {
    switch (source) {
      case MemorySource.user:
        return Icons.person;
      case MemorySource.ai:
        return Icons.smart_toy;
      case MemorySource.system:
        return Icons.settings;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 7) {
      return '${date.month}/${date.day}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
