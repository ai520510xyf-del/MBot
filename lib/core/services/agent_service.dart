import 'package:drift/drift.dart';
import '../models/agent.dart';
import '../models/database.dart';

/// Agent 服务
class AgentService {
  final MBotDatabase _db;

  AgentService(this._db);

  /// 获取所有 Agent 列表
  Future<List<AgentData>> getAgents() async {
    final agents = await _db.select(_db.agents).get();

    // 按名称排序
    final sorted = agents..sort((a, b) => a.name.compareTo(b.name));

    return sorted.map((a) => AgentData.fromDB(a)).toList();
  }

  /// 获取在线 Agent 列表
  Future<List<AgentData>> getOnlineAgents() async {
    final agents = await (_db.select(_db.agents)
          ..where((tbl) => tbl.status.equals('online')))
        .get();

    return agents.map((a) => AgentData.fromDB(a)).toList();
  }

  /// 获取 Agent 详情
  Future<AgentData?> getAgentDetail(String agentId) async {
    final agent = await (_db.select(_db.agents)
          ..where((tbl) => tbl.id.equals(agentId)))
        .getSingleOrNull();

    return agent != null ? AgentData.fromDB(agent) : null;
  }

  /// 更新 Agent 状态
  Future<void> updateAgentStatus(String agentId, AgentStatus status) async {
    await (_db.update(_db.agents)..where((tbl) => tbl.id.equals(agentId)))
        .write(AgentsCompanion(
      status: Value(status.name),
      lastActive: Value(DateTime.now()),
    ));
  }

  /// 增加任务计数
  Future<void> incrementTaskCount(String agentId) async {
    final agent = await (_db.select(_db.agents)
          ..where((tbl) => tbl.id.equals(agentId)))
        .getSingleOrNull();

    if (agent != null) {
      await (_db.update(_db.agents)..where((tbl) => tbl.id.equals(agentId)))
          .write(AgentsCompanion(
        taskCount: Value(agent.taskCount + 1),
        lastActive: Value(DateTime.now()),
      ));
    }
  }

  /// 获取 Agent 统计数据 (Mock)
  Future<AgentStats> getAgentStats() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    return const AgentStats(
      conversationCount: 128,
      skillCallCount: 56,
      taskCount: 23,
      avgResponseTime: 1.2,
    );
  }

  /// 获取活跃通道列表 (Mock)
  Future<List<ChannelInfo>> getActiveChannels() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      ChannelInfo(
        id: 'wechat',
        name: '微信',
        emoji: '💬',
        status: 'online',
        messageCount: 23,
        isOnline: true,
      ),
      ChannelInfo(
        id: 'qq',
        name: 'QQ',
        emoji: '🐧',
        status: 'online',
        messageCount: 12,
        isOnline: true,
      ),
      ChannelInfo(
        id: 'telegram',
        name: 'Telegram',
        emoji: '✈️',
        status: 'online',
        messageCount: 8,
        isOnline: true,
      ),
    ];
  }

  /// 获取最近任务列表 (Mock)
  Future<List<TaskInfo>> getRecentTasks() async {
    // 模拟网络延迟
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      TaskInfo(
        id: 'task_001',
        title: 'AI 写作助手',
        description: '已完成：生成邮件草稿',
        status: 'completed',
        time: '10:30',
      ),
      TaskInfo(
        id: 'task_002',
        title: '网页摘要',
        description: '处理中：正在分析网页内容...',
        status: 'processing',
        time: '10:25',
      ),
      TaskInfo(
        id: 'task_003',
        title: '数据查询',
        description: '失败：网络连接超时',
        status: 'failed',
        time: '10:20',
      ),
    ];
  }

  /// 初始化默认 Agent 数据
  Future<void> initializeDefaultAgents() async {
    // 检查是否已有 Agent 数据
    final existingCount = await (_db.select(_db.agents).get()).then((a) => a.length);
    if (existingCount > 0) return;

    // 插入默认 Agent
    final defaultAgents = _getDefaultAgents();
    for (final agent in defaultAgents) {
      await _db.into(_db.agents).insert(agent.toDBCompanion());
    }
  }

  /// 获取默认 Agent 列表
  List<AgentData> _getDefaultAgents() {
    return [
      AgentData(
        id: 'agent_001',
        name: 'MBot 主控',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'DeepSeek-V3',
        taskCount: 128,
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      AgentData(
        id: 'agent_002',
        name: '写作助手',
        emoji: '✍️',
        status: AgentStatus.online,
        model: 'Claude-3.5',
        taskCount: 45,
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      AgentData(
        id: 'agent_003',
        name: '代码专家',
        emoji: '💻',
        status: AgentStatus.busy,
        model: 'GPT-4o',
        taskCount: 23,
        lastActive: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ];
  }
}
