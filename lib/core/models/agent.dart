import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;

import '../../theme/app_colors.dart';
import 'database.dart';

/// Agent 状态
enum AgentStatus {
  /// 在线
  online,

  /// 离线
  offline,

  /// 忙碌
  busy,
}

/// 从字符串解析 Agent 状态
AgentStatus agentStatusFromString(String value) {
  return AgentStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AgentStatus.offline,
  );
}

/// Agent 数据模型 (不可变)
class AgentData {
  final String id;
  final String name;
  final String emoji;
  final AgentStatus status;
  final String model;
  final int taskCount;
  final DateTime? lastActive;

  const AgentData({
    required this.id,
    required this.name,
    required this.emoji,
    required this.status,
    required this.model,
    required this.taskCount,
    this.lastActive,
  });

  /// 从数据库实体转换
  factory AgentData.fromDB(Agent agent) {
    return AgentData(
      id: agent.id,
      name: agent.name,
      emoji: agent.emoji,
      status: agentStatusFromString(agent.status),
      model: agent.model,
      taskCount: agent.taskCount,
      lastActive: agent.lastActive,
    );
  }

  /// 复制并修改部分字段
  AgentData copyWith({
    String? id,
    String? name,
    String? emoji,
    AgentStatus? status,
    String? model,
    int? taskCount,
    DateTime? lastActive,
  }) {
    return AgentData(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      status: status ?? this.status,
      model: model ?? this.model,
      taskCount: taskCount ?? this.taskCount,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// 是否在线
  bool get isOnline => status == AgentStatus.online;

  /// 是否忙碌
  bool get isBusy => status == AgentStatus.busy;

  /// 状态显示名称
  String get statusDisplayName {
    switch (status) {
      case AgentStatus.online:
        return '在线';
      case AgentStatus.offline:
        return '离线';
      case AgentStatus.busy:
        return '忙碌';
    }
  }

  /// 格式化最后活跃时间
  String? get formattedLastActive {
    if (lastActive == null) return null;

    final now = DateTime.now();
    final diff = now.difference(lastActive!);

    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else {
      return '${diff.inDays}天前';
    }
  }
}

/// AgentData 扩展方法
extension AgentDataX on AgentData {
  /// 转换为数据库插入实体
  AgentsCompanion toDBCompanion() {
    return AgentsCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      emoji: drift.Value(emoji),
      status: drift.Value(status.name),
      model: drift.Value(model),
      taskCount: drift.Value(taskCount),
      lastActive: lastActive == null
          ? const drift.Value.absent()
          : drift.Value(lastActive!),
    );
  }
}

/// Agent 统计数据
class AgentStats {
  final int conversationCount;
  final int skillCallCount;
  final int taskCount;
  final double avgResponseTime;

  const AgentStats({
    required this.conversationCount,
    required this.skillCallCount,
    required this.taskCount,
    required this.avgResponseTime,
  });

  /// 复制并修改部分字段
  AgentStats copyWith({
    int? conversationCount,
    int? skillCallCount,
    int? taskCount,
    double? avgResponseTime,
  }) {
    return AgentStats(
      conversationCount: conversationCount ?? this.conversationCount,
      skillCallCount: skillCallCount ?? this.skillCallCount,
      taskCount: taskCount ?? this.taskCount,
      avgResponseTime: avgResponseTime ?? this.avgResponseTime,
    );
  }

  /// 格式化响应时间
  String get formattedResponseTime {
    if (avgResponseTime < 1) {
      return '${(avgResponseTime * 1000).toStringAsFixed(0)}ms';
    }
    return '${avgResponseTime.toStringAsFixed(1)}s';
  }
}

/// 通道信息
class ChannelInfo {
  final String id;
  final String name;
  final String emoji;
  final String status;
  final int messageCount;
  final bool isOnline;

  const ChannelInfo({
    required this.id,
    required this.name,
    required this.emoji,
    required this.status,
    required this.messageCount,
    required this.isOnline,
  });

  /// 从 JSON 创建
  factory ChannelInfo.fromJson(Map<String, dynamic> json) {
    return ChannelInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      status: json['status'] as String,
      messageCount: json['messageCount'] as int,
      isOnline: json['isOnline'] as bool,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'status': status,
      'messageCount': messageCount,
      'isOnline': isOnline,
    };
  }
}

/// 任务信息
class TaskInfo {
  final String id;
  final String title;
  final String description;
  final String status; // 'completed', 'processing', 'failed'
  final String time;

  const TaskInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.time,
  });

  /// 从 JSON 创建
  factory TaskInfo.fromJson(Map<String, dynamic> json) {
    return TaskInfo(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      time: json['time'] as String,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'time': time,
    };
  }

  /// 获取状态图标
  IconData get statusIcon {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'processing':
        return Icons.pending;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  /// 获取状态颜色
  Color get statusColor {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'processing':
        return AppColors.primary;
      case 'failed':
        return AppColors.error;
      default:
        return DarkColors.textSecondary;
    }
  }
}
