import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/agent.dart';
import '../services/agent_service.dart';
import 'skill_providers.dart';

part 'agent_providers.g.dart';

/// Agent 服务 Provider
@riverpod
AgentService agentService(Ref ref) {
  final db = ref.watch(databaseProvider);
  return AgentService(db);
}

/// Agent 列表 Provider
@riverpod
Future<List<AgentData>> agentList(Ref ref) async {
  final service = ref.watch(agentServiceProvider);

  // 初始化默认 Agent 数据
  await service.initializeDefaultAgents();

  return service.getAgents();
}

/// 在线 Agent 列表 Provider
@riverpod
Future<List<AgentData>> onlineAgentList(Ref ref) async {
  final service = ref.watch(agentServiceProvider);
  return service.getOnlineAgents();
}

/// Agent 详情 Provider
@riverpod
Future<AgentData?> agentDetail(Ref ref, String agentId) async {
  final service = ref.watch(agentServiceProvider);
  return service.getAgentDetail(agentId);
}

/// Agent 统计数据 Provider
@riverpod
Future<AgentStats> agentStats(Ref ref) async {
  final service = ref.watch(agentServiceProvider);
  return service.getAgentStats();
}

/// 活跃通道列表 Provider
@riverpod
Future<List<ChannelInfo>> activeChannels(Ref ref) async {
  final service = ref.watch(agentServiceProvider);
  return service.getActiveChannels();
}

/// 最近任务列表 Provider
@riverpod
Future<List<TaskInfo>> recentTasks(Ref ref) async {
  final service = ref.watch(agentServiceProvider);
  return service.getRecentTasks();
}

/// 是否正在加载状态
@riverpod
class IsLoading extends _$IsLoading {
  @override
  bool build() {
    return false;
  }

  void setLoading(bool value) {
    state = value;
  }
}
