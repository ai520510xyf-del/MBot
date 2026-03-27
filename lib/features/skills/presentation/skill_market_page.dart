import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';

/// 技能广场页
class SkillMarketPage extends StatefulWidget {
  const SkillMarketPage({super.key});

  @override
  State<SkillMarketPage> createState() => _SkillMarketPageState();
}

class _SkillMarketPageState extends State<SkillMarketPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _categories = ['全部', 'AI', '文本', '图像', '编程', '效率'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('技能广场'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 搜索技能
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 分类标签
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textTertiary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),

          // 技能网格
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((_) => _buildSkillGrid()).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillGrid() {
    final skills = [
      ('🤖', 'AI 写作', '智能文章生成与优化', 4.8, 1200),
      ('📝', '文本摘要', '长文本快速提取要点', 4.6, 856),
      ('🎨', 'AI 绘画', '文字描述生成图片', 4.9, 2300),
      ('💻', '代码助手', '代码生成与调试', 4.7, 1500),
      ('🌐', '网页总结', '网页内容快速总结', 4.5, 623),
      ('📊', '数据分析', '智能数据分析报告', 4.8, 945),
      ('📎', '文档处理', 'PDF/Word 文档解析', 4.4, 780),
      ('🎵', '音乐推荐', '基于喜好的音乐推荐', 4.3, 420),
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(AppSpace.s4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: AppSpace.s3,
        mainAxisSpacing: AppSpace.s3,
      ),
      itemCount: skills.length,
      itemBuilder: (context, index) {
        final (emoji, name, desc, rating, installs) = skills[index];
        return _SkillCard(
          emoji: emoji,
          name: name,
          description: desc,
          rating: rating,
          installCount: installs,
          onTap: () {
            // TODO: 查看技能详情
          },
        );
      },
    );
  }
}

class _SkillCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String description;
  final double rating;
  final int installCount;
  final VoidCallback onTap;

  const _SkillCard({
    required this.emoji,
    required this.name,
    required this.description,
    required this.rating,
    required this.installCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: AppRadius.radiusLG,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighlight,
                  borderRadius: AppRadius.radiusMD,
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: AppSpace.s3),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.star, size: 12, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Text(
                    '${(installCount / 1000).toStringAsFixed(1)}K',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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
