import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/theme.dart';
import '../../../../core/models/agent.dart';
import '../../../../core/providers/agent_providers.dart';

/// Agent 仪表盘页
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agentsAsync = ref.watch(agentListProvider);
    final statsAsync = ref.watch(agentStatsProvider);
    final channelsAsync = ref.watch(activeChannelsProvider);
    final tasksAsync = ref.watch(recentTasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent 仪表盘'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(agentListProvider);
              ref.invalidate(agentStatsProvider);
              ref.invalidate(activeChannelsProvider);
              ref.invalidate(recentTasksProvider);
            },
          ),
          TextButton(
            onPressed: () {
              // Navigate to model configuration
            },
            child: const Text('配置'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(agentListProvider);
          ref.invalidate(agentStatsProvider);
          ref.invalidate(activeChannelsProvider);
          ref.invalidate(recentTasksProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.s4),
          children: [
            // Agent 状态卡片行
            agentsAsync.when(
              data: (agents) {
                final onlineCount = agents.where((a) => a.isOnline).length;
                final busyCount = agents.where((a) => a.isBusy).length;
                final offlineCount = agents
                    .where((a) => !a.isOnline && !a.isBusy)
                    .length;

                return Row(
                  children: [
                    Expanded(
                      child: _AgentStatusCard.online(count: onlineCount),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(child: _AgentStatusCard.busy(count: busyCount)),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: _AgentStatusCard.offline(count: offlineCount),
                    ),
                  ],
                );
              },
              loading: () => const _ShimmerRow(3),
              error: (_, _) => const _ShimmerRow(3),
            ),

            const SizedBox(height: AppSpace.s6),

            // 今日统计
            _buildSectionTitle('今日统计'),
            const SizedBox(height: AppSpace.s3),
            statsAsync.when(
              data: (stats) {
                return Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: '💬',
                        value: stats.conversationCount.toString(),
                        label: '对话数',
                      ),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: _StatCard(
                        icon: '⚙️',
                        value: stats.skillCallCount.toString(),
                        label: '技能调用',
                      ),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: _StatCard(
                        icon: '🎯',
                        value: stats.taskCount.toString(),
                        label: '任务数',
                      ),
                    ),
                    const SizedBox(width: AppSpace.s3),
                    Expanded(
                      child: _StatCard(
                        icon: '⏱️',
                        value: stats.formattedResponseTime,
                        label: '响应时间',
                      ),
                    ),
                  ],
                );
              },
              loading: () => const _ShimmerRow(4),
              error: (_, _) => const _ShimmerRow(4),
            ),

            const SizedBox(height: AppSpace.s6),

            // Agent 列表
            _buildSectionTitle('Agent 列表'),
            const SizedBox(height: AppSpace.s3),
            agentsAsync.when(
              data: (agents) {
                if (agents.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无 Agent',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return Column(
                  children: agents
                      .map((agent) => _AgentCard(agent: agent))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (error, _) => Center(
                child: Text(
                  '加载失败: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s6),

            // 活跃通道
            _buildSectionTitle('活跃通道'),
            const SizedBox(height: AppSpace.s3),
            channelsAsync.when(
              data: (channels) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: channels.length,
                  itemBuilder: (context, index) {
                    return _ChannelCard(channel: channels[index]);
                  },
                );
              },
              loading: () => const _ShimmerColumn(3),
              error: (_, _) => const _ShimmerColumn(3),
            ),

            const SizedBox(height: AppSpace.s6),

            // 最近任务
            _buildSectionTitle('最近任务'),
            const SizedBox(height: AppSpace.s3),
            tasksAsync.when(
              data: (tasks) {
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text(
                      '暂无任务',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return _TaskItem(task: tasks[index]);
                  },
                );
              },
              loading: () => const _ShimmerColumn(3),
              error: (error, _) => Center(
                child: Text(
                  '加载失败: $error',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s8),
          ],
        ),
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

/// Agent 状态卡片
class _AgentStatusCard extends StatelessWidget {
  final String title;
  final String status;
  final int count;
  final Color color;

  const _AgentStatusCard.online({required this.count})
    : title = '在线',
      status = '运行中',
      color = AppColors.success;

  const _AgentStatusCard.busy({required this.count})
    : title = '忙碌',
      status = '处理中',
      color = AppColors.warning;

  const _AgentStatusCard.offline({required this.count})
    : title = '离线',
      status = '未连接',
      color = AppColors.error;

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
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            '$count 个 Agent',
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

/// 统计卡片
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
            style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Agent 卡片
class _AgentCard extends ConsumerWidget {
  final AgentData agent;

  const _AgentCard({required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.s3),
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusLG,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surfaceHighlight,
              borderRadius: AppRadius.radiusMD,
            ),
            child: Center(
              child: Text(agent.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: AppSpace.s3),
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      agent.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppSpace.s2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          agent.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: AppRadius.radiusSM,
                      ),
                      child: Text(
                        agent.statusDisplayName,
                        style: TextStyle(
                          fontSize: 11,
                          color: _getStatusColor(agent.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${agent.model} · ${agent.taskCount} 个任务',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (agent.formattedLastActive != null)
                  Text(
                    '活跃于 ${agent.formattedLastActive}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          // 状态点
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(agent.status),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.online:
        return AppColors.success;
      case AgentStatus.busy:
        return AppColors.warning;
      case AgentStatus.offline:
        return AppColors.error;
    }
  }
}

/// 通道卡片
class _ChannelCard extends StatelessWidget {
  final ChannelInfo channel;

  const _ChannelCard({required this.channel});

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
          Text(channel.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Text(
              channel.name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _StatusDot(isOnline: channel.isOnline, label: channel.status),
          const SizedBox(width: AppSpace.s3),
          Text(
            '${channel.messageCount} 条',
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

/// 状态点
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

/// 任务项
class _TaskItem extends StatelessWidget {
  final TaskInfo task;

  const _TaskItem({required this.task});

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
          Icon(task.statusIcon, color: task.statusColor, size: 20),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  task.description,
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
            task.time,
            style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Shimmer 行占位符
class _ShimmerRow extends StatelessWidget {
  final int count;

  const _ShimmerRow(this.count);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (index) => Expanded(
          child: Container(
            height: 80,
            margin: EdgeInsets.only(right: index < count - 1 ? AppSpace.s3 : 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.radiusLG,
              border: Border.all(color: AppColors.border),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer 列占位符
class _ShimmerColumn extends StatelessWidget {
  final int count;

  const _ShimmerColumn(this.count);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (index) => Container(
          height: 60,
          margin: const EdgeInsets.only(bottom: AppSpace.s2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusMD,
            border: Border.all(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
