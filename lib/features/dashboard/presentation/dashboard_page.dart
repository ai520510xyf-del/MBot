import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';

/// Agent 仪表盘页
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent 仪表盘'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('配置'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.s4),
        children: [
          // 状态卡片行
          Row(
            children: [
              Expanded(child: _StatusCard.running()),
              const SizedBox(width: AppSpace.s3),
              Expanded(child: _StatusCard.resources()),
            ],
          ),

          const SizedBox(height: AppSpace.s6),

          // 今日统计
          _buildSectionTitle('今日统计'),
          const SizedBox(height: AppSpace.s3),
          const Row(
            children: [
              Expanded(child: _StatCard(icon: '💬', value: '128', label: '对话数')),
              SizedBox(width: AppSpace.s3),
              Expanded(child: _StatCard(icon: '⚙️', value: '56', label: '技能调用')),
              SizedBox(width: AppSpace.s3),
              Expanded(child: _StatCard(icon: '🎯', value: '23', label: '任务数')),
              SizedBox(width: AppSpace.s3),
              Expanded(child: _StatCard(icon: '⏱️', value: '1.2s', label: '响应时间')),
            ],
          ),

          const SizedBox(height: AppSpace.s6),

          // 活跃通道
          _buildSectionTitle('活跃通道'),
          const SizedBox(height: AppSpace.s3),
          _ChannelCard(
            icon: '💬',
            name: '微信',
            status: '在线',
            count: 23,
            isOnline: true,
          ),
          const SizedBox(height: AppSpace.s2),
          _ChannelCard(
            icon: '🐧',
            name: 'QQ',
            status: '在线',
            count: 12,
            isOnline: true,
          ),
          const SizedBox(height: AppSpace.s2),
          _ChannelCard(
            icon: '✈️',
            name: 'Telegram',
            status: '在线',
            count: 8,
            isOnline: true,
          ),

          const SizedBox(height: AppSpace.s6),

          // 最近任务
          _buildSectionTitle('最近任务'),
          const SizedBox(height: AppSpace.s3),
          _TaskItem(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            title: 'AI 写作助手',
            desc: '已完成：生成邮件草稿',
            time: '10:30',
          ),
          _TaskItem(
            icon: Icons.pending,
            iconColor: AppColors.primary,
            title: '网页摘要',
            desc: '处理中：正在分析网页内容...',
            time: '10:25',
          ),
          _TaskItem(
            icon: Icons.error,
            iconColor: AppColors.error,
            title: '数据查询',
            desc: '失败：网络连接超时',
            time: '10:20',
          ),

          const SizedBox(height: AppSpace.s8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textTertiary,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _StatusCard.running()
      : title = '运行状态',
        children = const [
          _StatusDot(isOnline: true, label: '运行中'),
          SizedBox(height: 4),
          Text('内存: 156MB',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ];

  const _StatusCard.resources()
      : title = '资源使用',
        children = const [
          Text('CPU: 12%',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('内存: 8%',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          ...children,
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isOnline;
  final String label;

  const _StatusDot({required this.isOnline, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isOnline ? AppColors.success : AppColors.error,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isOnline ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  final String icon;
  final String name;
  final String status;
  final int count;
  final bool isOnline;

  const _ChannelCard({
    required this.icon,
    required this.name,
    required this.status,
    required this.count,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StatusDot(isOnline: isOnline, label: status),
          const SizedBox(width: AppSpace.s3),
          Text(
            '$count 条',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final String time;

  const _TaskItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s2),
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
