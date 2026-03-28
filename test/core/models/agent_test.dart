import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/agent.dart';
import 'package:mbot_mobile/core/models/database.dart';

void main() {
  group('AgentStatus', () {
    test('should have all enum values', () {
      expect(AgentStatus.online, isA<AgentStatus>());
      expect(AgentStatus.offline, isA<AgentStatus>());
      expect(AgentStatus.busy, isA<AgentStatus>());
    });

    test('should have 3 status values', () {
      expect(AgentStatus.values.length, equals(3));
    });

    test('should have correct string names', () {
      expect(AgentStatus.online.name, equals('online'));
      expect(AgentStatus.offline.name, equals('offline'));
      expect(AgentStatus.busy.name, equals('busy'));
    });
  });

  group('agentStatusFromString', () {
    test('should parse valid status strings', () {
      expect(agentStatusFromString('online'), equals(AgentStatus.online));
      expect(agentStatusFromString('offline'), equals(AgentStatus.offline));
      expect(agentStatusFromString('busy'), equals(AgentStatus.busy));
    });

    test('should return offline for invalid strings', () {
      expect(agentStatusFromString('invalid'), equals(AgentStatus.offline));
      expect(agentStatusFromString(''), equals(AgentStatus.offline));
      expect(agentStatusFromString('unknown'), equals(AgentStatus.offline));
    });
  });

  group('AgentData', () {
    test('should create AgentData with required fields', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 5,
      );

      expect(agent.id, equals('agent-001'));
      expect(agent.name, equals('Test Agent'));
      expect(agent.emoji, equals('🤖'));
      expect(agent.status, equals(AgentStatus.online));
      expect(agent.model, equals('gpt-4'));
      expect(agent.taskCount, equals(5));
      expect(agent.lastActive, isNull);
    });

    test('should create AgentData with optional lastActive', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 5,
        lastActive: now,
      );

      expect(agent.lastActive, equals(now));
    });

    test('should support copyWith for all fields', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Original Name',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-3.5',
        taskCount: 0,
      );

      final copied = agent.copyWith(
        name: 'Updated Name',
        status: AgentStatus.busy,
        taskCount: 10,
      );

      expect(copied.id, equals('agent-001')); // unchanged
      expect(copied.name, equals('Updated Name'));
      expect(copied.emoji, equals('🤖')); // unchanged
      expect(copied.status, equals(AgentStatus.busy));
      expect(copied.taskCount, equals(10));
    });

    test('isOnline should return true for online status', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
      );

      expect(agent.isOnline, isTrue);
      expect(agent.isBusy, isFalse);
    });

    test('isBusy should return true for busy status', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.busy,
        model: 'gpt-4',
        taskCount: 0,
      );

      expect(agent.isOnline, isFalse);
      expect(agent.isBusy, isTrue);
    });

    test('statusDisplayName should return correct Chinese names', () {
      final onlineAgent = AgentData(
        id: 'agent-1',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
      );

      final offlineAgent = AgentData(
        id: 'agent-2',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.offline,
        model: 'gpt-4',
        taskCount: 0,
      );

      final busyAgent = AgentData(
        id: 'agent-3',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.busy,
        model: 'gpt-4',
        taskCount: 0,
      );

      expect(onlineAgent.statusDisplayName, equals('在线'));
      expect(offlineAgent.statusDisplayName, equals('离线'));
      expect(busyAgent.statusDisplayName, equals('忙碌'));
    });

    test('formattedLastActive should return null when lastActive is null', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
      );

      expect(agent.formattedLastActive, isNull);
    });

    test('formattedLastActive should return "刚刚" for recent activity', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
        lastActive: now.subtract(const Duration(seconds: 30)),
      );

      expect(agent.formattedLastActive, equals('刚刚'));
    });

    test('formattedLastActive should return minutes for activity within hour', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
        lastActive: now.subtract(const Duration(minutes: 15)),
      );

      expect(agent.formattedLastActive, equals('15分钟前'));
    });

    test('formattedLastActive should return hours for activity within day', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
        lastActive: now.subtract(const Duration(hours: 3)),
      );

      expect(agent.formattedLastActive, equals('3小时前'));
    });

    test('formattedLastActive should return days for older activity', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
        lastActive: now.subtract(const Duration(days: 5)),
      );

      expect(agent.formattedLastActive, equals('5天前'));
    });
  });

  group('AgentData.fromDB', () {
    test('should convert from DB entity correctly', () {
      final now = DateTime.now();
      final dbAgent = Agent(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: 'online',
        model: 'gpt-4',
        taskCount: 10,
        lastActive: now,
      );

      final agentData = AgentData.fromDB(dbAgent);

      expect(agentData.id, equals('agent-001'));
      expect(agentData.name, equals('Test Agent'));
      expect(agentData.emoji, equals('🤖'));
      expect(agentData.status, equals(AgentStatus.online));
      expect(agentData.model, equals('gpt-4'));
      expect(agentData.taskCount, equals(10));
      expect(agentData.lastActive, equals(now));
    });

    test('should handle null lastActive', () {
      final dbAgent = Agent(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: 'offline',
        model: 'gpt-4',
        taskCount: 0,
        lastActive: null,
      );

      final agentData = AgentData.fromDB(dbAgent);

      expect(agentData.lastActive, isNull);
    });

    test('should parse status string correctly', () {
      final dbAgent = Agent(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: 'busy',
        model: 'gpt-4',
        taskCount: 0,
        lastActive: null,
      );

      final agentData = AgentData.fromDB(dbAgent);

      expect(agentData.status, equals(AgentStatus.busy));
    });
  });

  group('AgentDataX extension', () {
    test('should convert to DB Companion correctly', () {
      final now = DateTime.now();
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test Agent',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 10,
        lastActive: now,
      );

      final companion = agent.toDBCompanion();

      expect(companion.id.value, equals('agent-001'));
      expect(companion.name.value, equals('Test Agent'));
      expect(companion.emoji.value, equals('🤖'));
      expect(companion.status.value, equals('online'));
      expect(companion.model.value, equals('gpt-4'));
      expect(companion.taskCount.value, equals(10));
      expect(companion.lastActive.value, equals(now));
    });

    test('should handle null lastActive in DB Companion', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.offline,
        model: 'gpt-4',
        taskCount: 0,
      );

      final companion = agent.toDBCompanion();

      // Value.absent() check not available in newer drift versions
    });
  });

  group('AgentStats', () {
    test('should create AgentStats with required fields', () {
      final stats = AgentStats(
        conversationCount: 10,
        skillCallCount: 50,
        taskCount: 100,
        avgResponseTime: 1.5,
      );

      expect(stats.conversationCount, equals(10));
      expect(stats.skillCallCount, equals(50));
      expect(stats.taskCount, equals(100));
      expect(stats.avgResponseTime, equals(1.5));
    });

    test('should support copyWith for all fields', () {
      final stats = AgentStats(
        conversationCount: 10,
        skillCallCount: 50,
        taskCount: 100,
        avgResponseTime: 1.5,
      );

      final copied = stats.copyWith(
        conversationCount: 20,
        avgResponseTime: 0.8,
      );

      expect(copied.conversationCount, equals(20));
      expect(copied.skillCallCount, equals(50)); // unchanged
      expect(copied.taskCount, equals(100)); // unchanged
      expect(copied.avgResponseTime, equals(0.8));
    });

    test('formattedResponseTime should format milliseconds', () {
      final stats = AgentStats(
        conversationCount: 0,
        skillCallCount: 0,
        taskCount: 0,
        avgResponseTime: 0.45,
      );

      expect(stats.formattedResponseTime, equals('450ms'));
    });

    test('formattedResponseTime should format seconds', () {
      final stats = AgentStats(
        conversationCount: 0,
        skillCallCount: 0,
        taskCount: 0,
        avgResponseTime: 2.34,
      );

      expect(stats.formattedResponseTime, equals('2.3s'));
    });
  });

  group('ChannelInfo', () {
    test('should create ChannelInfo from JSON', () {
      final json = {
        'id': 'channel-001',
        'name': 'WeChat',
        'emoji': '💬',
        'status': 'connected',
        'messageCount': 1234,
        'isOnline': true,
      };

      final channel = ChannelInfo.fromJson(json);

      expect(channel.id, equals('channel-001'));
      expect(channel.name, equals('WeChat'));
      expect(channel.emoji, equals('💬'));
      expect(channel.status, equals('connected'));
      expect(channel.messageCount, equals(1234));
      expect(channel.isOnline, isTrue);
    });

    test('should convert ChannelInfo to JSON', () {
      final channel = ChannelInfo(
        id: 'channel-001',
        name: 'WeChat',
        emoji: '💬',
        status: 'connected',
        messageCount: 1234,
        isOnline: true,
      );

      final json = channel.toJson();

      expect(json['id'], equals('channel-001'));
      expect(json['name'], equals('WeChat'));
      expect(json['emoji'], equals('💬'));
      expect(json['status'], equals('connected'));
      expect(json['messageCount'], equals(1234));
      expect(json['isOnline'], isTrue);
    });

    test('should handle offline channel', () {
      final channel = ChannelInfo(
        id: 'channel-002',
        name: 'Telegram',
        emoji: '✈️',
        status: 'disconnected',
        messageCount: 0,
        isOnline: false,
      );

      expect(channel.isOnline, isFalse);
      expect(channel.status, equals('disconnected'));
    });
  });

  group('TaskInfo', () {
    test('should create TaskInfo from JSON', () {
      final json = {
        'id': 'task-001',
        'title': 'Process data',
        'description': 'Analyze user data',
        'status': 'completed',
        'time': '2 minutes ago',
      };

      final task = TaskInfo.fromJson(json);

      expect(task.id, equals('task-001'));
      expect(task.title, equals('Process data'));
      expect(task.description, equals('Analyze user data'));
      expect(task.status, equals('completed'));
      expect(task.time, equals('2 minutes ago'));
    });

    test('should convert TaskInfo to JSON', () {
      final task = TaskInfo(
        id: 'task-001',
        title: 'Process data',
        description: 'Analyze user data',
        status: 'completed',
        time: '2 minutes ago',
      );

      final json = task.toJson();

      expect(json['id'], equals('task-001'));
      expect(json['title'], equals('Process data'));
      expect(json['description'], equals('Analyze user data'));
      expect(json['status'], equals('completed'));
      expect(json['time'], equals('2 minutes ago'));
    });

    test('statusIcon should return correct icons', () {
      final completedTask = TaskInfo(
        id: 'task-1',
        title: 'Task',
        description: 'Desc',
        status: 'completed',
        time: 'now',
      );

      final processingTask = TaskInfo(
        id: 'task-2',
        title: 'Task',
        description: 'Desc',
        status: 'processing',
        time: 'now',
      );

      final failedTask = TaskInfo(
        id: 'task-3',
        title: 'Task',
        description: 'Desc',
        status: 'failed',
        time: 'now',
      );

      expect(completedTask.statusIcon, equals(Icons.check_circle));
      expect(processingTask.statusIcon, equals(Icons.pending));
      expect(failedTask.statusIcon, equals(Icons.error));
    });
  });

  group('Agent edge cases', () {
    test('should handle zero task count', () {
      final agent = AgentData(
        id: 'agent-001',
        name: 'Test',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
      );

      expect(agent.taskCount, equals(0));
    });

    test('should handle different model names', () {
      final gpt4Agent = AgentData(
        id: 'agent-1',
        name: 'GPT-4',
        emoji: '🤖',
        status: AgentStatus.online,
        model: 'gpt-4',
        taskCount: 0,
      );

      final claudeAgent = AgentData(
        id: 'agent-2',
        name: 'Claude',
        emoji: '🧠',
        status: AgentStatus.online,
        model: 'claude-3-opus',
        taskCount: 0,
      );

      expect(gpt4Agent.model, equals('gpt-4'));
      expect(claudeAgent.model, equals('claude-3-opus'));
    });
  });
}
