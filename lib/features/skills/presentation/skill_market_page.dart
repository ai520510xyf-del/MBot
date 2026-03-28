import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/theme.dart';
import '../../../../core/models/skill.dart';
import '../../../../core/providers/skill_providers.dart';

/// 技能广场页
class SkillMarketPage extends ConsumerStatefulWidget {
  const SkillMarketPage({super.key});

  @override
  ConsumerState<SkillMarketPage> createState() => _SkillMarketPageState();
}

class _SkillMarketPageState extends ConsumerState<SkillMarketPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    final categories = ref.read(categoryListProvider);
    _tabController = TabController(length: categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final categories = ref.read(categoryListProvider);
      ref
          .read(selectedCategoryProvider.notifier)
          .setCategory(categories[_tabController.index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoryListProvider);
    final availableSkillsAsync = ref.watch(availableSkillsProvider);
    final installedSkillsAsync = ref.watch(installedSkillsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('技能广场'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: _SkillSearchDelegate(ref));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(availableSkillsProvider);
              ref.invalidate(installedSkillsProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类标签
          _buildCategoryTabs(categories),

          // 技能网格
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                return _buildSkillGrid(availableSkillsAsync, category);
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildInstalledTab(installedSkillsAsync),
    );
  }

  Widget _buildCategoryTabs(List<SkillCategory> categories) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      labelColor: AppColors.primary,
      unselectedLabelColor: DarkColors.textTertiary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      onTap: (index) {
        ref
            .read(selectedCategoryProvider.notifier)
            .setCategory(categories[index]);
      },
      tabs: categories.map((c) => Tab(text: categoryDisplayName(c))).toList(),
    );
  }

  Widget _buildSkillGrid(
    AsyncValue<List<SkillData>> skillsAsync,
    SkillCategory category,
  ) {
    return skillsAsync.when(
      data: (skills) {
        // 过滤当前分类的技能
        final filteredSkills = category == SkillCategory.all
            ? skills
            : skills.where((s) => s.category == category).toList();

        if (filteredSkills.isEmpty) {
          return Center(
            child: Text(
              '暂无${categoryDisplayName(category)}技能',
              style: const TextStyle(
                fontSize: 14,
                color: DarkColors.textSecondary,
              ),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpace.s4),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpace.s3,
            mainAxisSpacing: AppSpace.s3,
          ),
          itemCount: filteredSkills.length,
          itemBuilder: (context, index) {
            final skill = filteredSkills[index];
            return _SkillCard(
              skill: skill,
              onTap: () => _showSkillDetail(skill),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: AppSpace.s3),
            Text(
              '加载失败: $error',
              style: const TextStyle(color: DarkColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstalledTab(AsyncValue<List<SkillData>> installedSkillsAsync) {
    return installedSkillsAsync.when(
      data: (installedSkills) {
        if (installedSkills.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 60,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s2,
          ),
          decoration: BoxDecoration(
            color: DarkColors.surface,
            border: Border(top: BorderSide(color: DarkColors.border, width: 1)),
          ),
          child: Row(
            children: [
              Text(
                '已安装 ${installedSkills.length} 个技能',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: DarkColors.textSecondary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  _showInstalledSkillsBottomSheet(installedSkills);
                },
                child: const Text('查看'),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showSkillDetail(SkillData skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SkillDetailSheet(skill: skill),
    );
  }

  void _showInstalledSkillsBottomSheet(List<SkillData> installedSkills) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _InstalledSkillsSheet(skills: installedSkills),
    );
  }
}

/// 技能卡片
class _SkillCard extends ConsumerWidget {
  final SkillData skill;
  final VoidCallback onTap;

  const _SkillCard({required this.skill, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInstalled = skill.isInstalled;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: DarkColors.cardGradient,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: DarkColors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标和状态
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: DarkColors.surfaceHighlight,
                      borderRadius: AppRadius.radiusMD,
                    ),
                    child: Center(
                      child: Text(
                        skill.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (isInstalled)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.s3),
              // 名称
              Text(
                skill.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DarkColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 描述
              Text(
                skill.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: DarkColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              // 评分和安装数
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    skill.formattedRating,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DarkColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Text(
                    skill.formattedInstallCount,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DarkColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 技能详情底部弹窗
class _SkillDetailSheet extends ConsumerStatefulWidget {
  final SkillData skill;

  const _SkillDetailSheet({required this.skill});

  @override
  ConsumerState<_SkillDetailSheet> createState() => _SkillDetailSheetState();
}

class _SkillDetailSheetState extends ConsumerState<_SkillDetailSheet> {
  bool _isInstalling = false;

  @override
  Widget build(BuildContext context) {
    final skillState = ref.watch(skillStateProvider);
    final isInstalled =
        skillState[widget.skill.id] == SkillStatus.installed ||
        widget.skill.isInstalled;

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: DarkColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 拖动手柄
          Container(
            margin: const EdgeInsets.only(top: AppSpace.s3),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DarkColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 内容
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s5),
              children: [
                // 图标和名称
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: DarkColors.surfaceHighlight,
                        borderRadius: AppRadius.radiusLG,
                      ),
                      child: Center(
                        child: Text(
                          widget.skill.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.s4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.skill.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: DarkColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v${widget.skill.version} · ${widget.skill.author}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: DarkColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s5),
                // 描述
                Text(
                  widget.skill.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: DarkColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpace.s5),
                // 统计信息
                Row(
                  children: [
                    _StatItem(
                      icon: Icons.star,
                      label: widget.skill.formattedRating,
                    ),
                    const SizedBox(width: AppSpace.s4),
                    _StatItem(
                      icon: Icons.download,
                      label: widget.skill.formattedInstallCount,
                    ),
                    const SizedBox(width: AppSpace.s4),
                    _StatItem(
                      icon: Icons.category,
                      label: categoryDisplayName(widget.skill.category),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.s5),
                // 标签
                if (widget.skill.tags.isNotEmpty) ...[
                  Text(
                    '标签',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DarkColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpace.s2),
                  Wrap(
                    spacing: AppSpace.s2,
                    runSpacing: AppSpace.s2,
                    children: widget.skill.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.s3,
                          vertical: AppSpace.s1,
                        ),
                        decoration: BoxDecoration(
                          color: DarkColors.surfaceHighlight,
                          borderRadius: AppRadius.radiusSM,
                          border: Border.all(color: DarkColors.border, width: 1),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 12,
                            color: DarkColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          // 底部按钮
          Padding(
            padding: const EdgeInsets.all(AppSpace.s5),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _isInstalling
                    ? null
                    : () async {
                        setState(() => _isInstalling = true);
                        try {
                          if (isInstalled) {
                            await ref
                                .read(skillStateProvider.notifier)
                                .uninstallSkill(widget.skill.id);
                          } else {
                            await ref
                                .read(skillStateProvider.notifier)
                                .installSkill(widget.skill.id);
                          }
                          // 刷新列表
                          ref.invalidate(availableSkillsProvider);
                          ref.invalidate(installedSkillsProvider);
                        } finally {
                          if (mounted) {
                            setState(() => _isInstalling = false);
                          }
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: isInstalled
                      ? DarkColors.surface
                      : AppColors.primary,
                  foregroundColor: isInstalled
                      ? DarkColors.textPrimary
                      : DarkColors.surface,
                ),
                child: _isInstalling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isInstalled ? '卸载技能' : '安装技能',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 统计信息项
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: DarkColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: DarkColors.textSecondary),
        ),
      ],
    );
  }
}

/// 已安装技能底部弹窗
class _InstalledSkillsSheet extends StatelessWidget {
  final List<SkillData> skills;

  const _InstalledSkillsSheet({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: DarkColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: AppSpace.s3),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: DarkColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpace.s5),
            child: Row(
              children: [
                Text(
                  '已安装技能 (${skills.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DarkColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
              itemCount: skills.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s2),
              itemBuilder: (context, index) {
                final skill = skills[index];
                return Container(
                  padding: const EdgeInsets.all(AppSpace.s4),
                  decoration: BoxDecoration(
                    color: DarkColors.surface,
                    borderRadius: AppRadius.radiusMD,
                    border: Border.all(color: DarkColors.border, width: 1),
                  ),
                  child: Row(
                    children: [
                      Text(skill.emoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: AppSpace.s3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              skill.name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: DarkColors.textPrimary,
                              ),
                            ),
                            Text(
                              'v${skill.version}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: DarkColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 技能搜索委托
class _SkillSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _SkillSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          ref.read(searchQueryProvider.notifier).clear();
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
        ref.read(searchQueryProvider.notifier).clear();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    ref.read(searchQueryProvider.notifier).setQuery(query);
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      ref.read(searchQueryProvider.notifier).setQuery(query);
    }
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final availableSkillsAsync = ref.watch(availableSkillsProvider);

    return availableSkillsAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return Center(
            child: Text(
              '未找到 "$query" 相关技能',
              style: const TextStyle(color: DarkColors.textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpace.s4),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _SkillCard(
              skill: skill,
              onTap: () {
                close(context, '');
                // Navigate to skill detail page
              },
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (error, stack) => Center(
        child: Text(
          '加载失败: $error',
          style: const TextStyle(color: AppColors.error),
        ),
      ),
    );
  }
}
