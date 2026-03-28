import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/conversation.dart';

void main() {
  group('ConversationStatus', () {
    test('should have correct enum values', () {
      expect(ConversationStatus.active, isA<ConversationStatus>());
      expect(ConversationStatus.archived, isA<ConversationStatus>());
      expect(ConversationStatus.deleted, isA<ConversationStatus>());
    });

    test('should have 3 status values', () {
      expect(ConversationStatus.values.length, equals(3));
    });
  });

  group('ConversationData', () {
    test('should create ConversationData with required fields', () {
      final now = DateTime.now();
      const conversationId = 'test-conversation-id';

      final conversation = ConversationData(
        id: conversationId,
        title: 'Test Conversation',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(conversation.id, equals(conversationId));
      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.agentId, equals('agent-123'));
      expect(conversation.status, equals(ConversationStatus.active));
      expect(conversation.createdAt, equals(now));
      expect(conversation.updatedAt, equals(now));
      expect(conversation.messageCount, equals(0));
    });

    test('should create ConversationData with optional fields', () {
      final now = DateTime.now();
      final lastMessageAt = now.add(const Duration(minutes: 5));

      final conversation = ConversationData(
        id: 'test-id',
        title: 'Test',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
        lastMessageAt: lastMessageAt,
        messageCount: 10,
      );

      expect(conversation.lastMessageAt, equals(lastMessageAt));
      expect(conversation.messageCount, equals(10));
    });

    test('should serialize to JSON correctly', () {
      final now = DateTime.now();
      final conversation = ConversationData(
        id: 'test-id',
        title: 'Test Conversation',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final json = conversation.toJson();

      expect(json['id'], equals('test-id'));
      expect(json['title'], equals('Test Conversation'));
      expect(json['agentId'], equals('agent-123'));
      expect(json['status'], equals('active'));
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['updatedAt'], equals(now.toIso8601String()));
    });

    test('should deserialize from JSON correctly', () {
      final now = DateTime.now();
      final json = {
        'id': 'test-id',
        'title': 'Test Conversation',
        'agentId': 'agent-123',
        'status': 'active',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'lastMessageAt': null,
        'messageCount': 0,
      };

      final conversation = ConversationData.fromJson(json);

      expect(conversation.id, equals('test-id'));
      expect(conversation.title, equals('Test Conversation'));
      expect(conversation.agentId, equals('agent-123'));
      expect(conversation.status, equals(ConversationStatus.active));
      expect(conversation.messageCount, equals(0));
    });

    test('should support copyWith for all fields', () {
      final now = DateTime.now();
      final original = ConversationData(
        id: 'original-id',
        title: 'Original Title',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final copied = original.copyWith(
        id: 'new-id',
        title: 'New Title',
        status: ConversationStatus.archived,
      );

      expect(copied.id, equals('new-id'));
      expect(copied.title, equals('New Title'));
      expect(copied.agentId, equals('agent-123')); // unchanged
      expect(copied.status, equals(ConversationStatus.archived));
      expect(copied.createdAt, equals(now)); // unchanged
    });

    test('should handle different status values', () {
      final now = DateTime.now();

      final activeConversation = ConversationData(
        id: 'id-1',
        title: 'Active',
        agentId: 'agent-1',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final archivedConversation = ConversationData(
        id: 'id-2',
        title: 'Archived',
        agentId: 'agent-2',
        status: ConversationStatus.archived,
        createdAt: now,
        updatedAt: now,
      );

      final deletedConversation = ConversationData(
        id: 'id-3',
        title: 'Deleted',
        agentId: 'agent-3',
        status: ConversationStatus.deleted,
        createdAt: now,
        updatedAt: now,
      );

      expect(activeConversation.status, equals(ConversationStatus.active));
      expect(archivedConversation.status, equals(ConversationStatus.archived));
      expect(deletedConversation.status, equals(ConversationStatus.deleted));
    });

    test('should handle messageCount correctly', () {
      final now = DateTime.now();

      final conversation = ConversationData(
        id: 'test-id',
        title: 'Test',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
        messageCount: 100,
      );

      expect(conversation.messageCount, equals(100));

      final updated = conversation.copyWith(messageCount: 101);
      expect(updated.messageCount, equals(101));
      expect(updated.id, equals(conversation.id)); // unchanged
    });
  });

  group('ConversationCreateParams', () {
    test('should create params with title and agentId', () {
      const params = ConversationCreateParams(
        title: 'New Conversation',
        agentId: 'agent-456',
      );

      expect(params.title, equals('New Conversation'));
      expect(params.agentId, equals('agent-456'));
    });

    test('should be const constructible', () {
      const params = ConversationCreateParams(
        title: 'Test',
        agentId: 'agent-1',
      );

      expect(params.title, equals('Test'));
      expect(params.agentId, equals('agent-1'));
    });
  });

  group('ConversationData equality', () {
    test('should be equal when all fields match', () {
      final now = DateTime.now();

      final conversation1 = ConversationData(
        id: 'test-id',
        title: 'Test',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final conversation2 = ConversationData(
        id: 'test-id',
        title: 'Test',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(conversation1, equals(conversation2));
      expect(conversation1.hashCode, equals(conversation2.hashCode));
    });

    test('should not be equal when fields differ', () {
      final now = DateTime.now();

      final conversation1 = ConversationData(
        id: 'test-id-1',
        title: 'Test 1',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      final conversation2 = ConversationData(
        id: 'test-id-2',
        title: 'Test 2',
        agentId: 'agent-123',
        status: ConversationStatus.active,
        createdAt: now,
        updatedAt: now,
      );

      expect(conversation1, isNot(equals(conversation2)));
    });
  });
}
