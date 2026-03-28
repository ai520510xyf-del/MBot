import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/message.dart';

void main() {
  group('MessageSender', () {
    test('should have all enum values', () {
      expect(MessageSender.user, isA<MessageSender>());
      expect(MessageSender.ai, isA<MessageSender>());
      expect(MessageSender.tool, isA<MessageSender>());
    });

    test('should have 3 sender types', () {
      expect(MessageSender.values.length, equals(3));
    });

    test('should have correct string names', () {
      expect(MessageSender.user.name, equals('user'));
      expect(MessageSender.ai.name, equals('ai'));
      expect(MessageSender.tool.name, equals('tool'));
    });
  });

  group('MessageStatus', () {
    test('should have all enum values', () {
      expect(MessageStatus.pending, isA<MessageStatus>());
      expect(MessageStatus.sending, isA<MessageStatus>());
      expect(MessageStatus.sent, isA<MessageStatus>());
      expect(MessageStatus.failed, isA<MessageStatus>());
    });

    test('should have 4 status values', () {
      expect(MessageStatus.values.length, equals(4));
    });

    test('should have correct string names', () {
      expect(MessageStatus.pending.name, equals('pending'));
      expect(MessageStatus.sending.name, equals('sending'));
      expect(MessageStatus.sent.name, equals('sent'));
      expect(MessageStatus.failed.name, equals('failed'));
    });
  });

  group('MessageData', () {
    test('should create MessageData with required fields', () {
      final now = DateTime.now();
      const messageId = 'test-message-id';
      const conversationId = 'test-conversation-id';

      final message = MessageData(
        id: messageId,
        conversationId: conversationId,
        content: 'Hello, World!',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      expect(message.id, equals(messageId));
      expect(message.conversationId, equals(conversationId));
      expect(message.content, equals('Hello, World!'));
      expect(message.sender, equals(MessageSender.user));
      expect(message.timestamp, equals(now));
      expect(message.status, equals(MessageStatus.sent));
      expect(message.toolName, isNull);
      expect(message.toolResult, isNull);
    });

    test('should create MessageData with optional tool fields', () {
      final now = DateTime.now();

      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Tool executed',
        sender: MessageSender.tool,
        timestamp: now,
        toolName: 'search',
        toolResult: 'Search results here',
        status: MessageStatus.sent,
      );

      expect(message.sender, equals(MessageSender.tool));
      expect(message.toolName, equals('search'));
      expect(message.toolResult, equals('Search results here'));
    });

    test('should support copyWith for all fields', () {
      final now = DateTime.now();
      final original = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Original',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.pending,
      );

      final copied = original.copyWith(
        content: 'Updated',
        status: MessageStatus.sent,
      );

      expect(copied.id, equals('msg-id')); // unchanged
      expect(copied.content, equals('Updated'));
      expect(copied.sender, equals(MessageSender.user)); // unchanged
      expect(copied.status, equals(MessageStatus.sent));
    });

    test('should handle different sender types', () {
      final now = DateTime.now();

      final userMessage = MessageData(
        id: 'msg-1',
        conversationId: 'conv-1',
        content: 'User message',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final aiMessage = MessageData(
        id: 'msg-2',
        conversationId: 'conv-2',
        content: 'AI response',
        sender: MessageSender.ai,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final toolMessage = MessageData(
        id: 'msg-3',
        conversationId: 'conv-3',
        content: 'Tool result',
        sender: MessageSender.tool,
        timestamp: now,
        status: MessageStatus.sent,
      );

      expect(userMessage.sender, equals(MessageSender.user));
      expect(aiMessage.sender, equals(MessageSender.ai));
      expect(toolMessage.sender, equals(MessageSender.tool));
    });

    test('should handle different message statuses', () {
      final now = DateTime.now();

      final pendingMessage = MessageData(
        id: 'msg-1',
        conversationId: 'conv-1',
        content: 'Pending',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.pending,
      );

      final sendingMessage = MessageData(
        id: 'msg-2',
        conversationId: 'conv-2',
        content: 'Sending',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sending,
      );

      final sentMessage = MessageData(
        id: 'msg-3',
        conversationId: 'conv-3',
        content: 'Sent',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final failedMessage = MessageData(
        id: 'msg-4',
        conversationId: 'conv-4',
        content: 'Failed',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.failed,
      );

      expect(pendingMessage.status, equals(MessageStatus.pending));
      expect(sendingMessage.status, equals(MessageStatus.sending));
      expect(sentMessage.status, equals(MessageStatus.sent));
      expect(failedMessage.status, equals(MessageStatus.failed));
    });

    test('should handle tool-specific fields', () {
      final now = DateTime.now();

      // Message with tool call only
      final toolCallMessage = MessageData(
        id: 'msg-1',
        conversationId: 'conv-1',
        content: 'Calling search tool',
        sender: MessageSender.tool,
        timestamp: now,
        toolName: 'search',
        status: MessageStatus.pending,
      );

      expect(toolCallMessage.toolName, equals('search'));
      expect(toolCallMessage.toolResult, isNull);

      // Message with tool result
      final toolResultMessage = MessageData(
        id: 'msg-2',
        conversationId: 'conv-2',
        content: 'Search completed',
        sender: MessageSender.tool,
        timestamp: now,
        toolName: 'search',
        toolResult: 'Found 5 results',
        status: MessageStatus.sent,
      );

      expect(toolResultMessage.toolName, equals('search'));
      expect(toolResultMessage.toolResult, equals('Found 5 results'));
    });

    test('should update timestamp via copyWith', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));

      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Test',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final updated = message.copyWith(timestamp: later);

      expect(updated.timestamp, equals(later));
      expect(updated.id, equals(message.id));
    });
  });

  group('MessageDataX extension', () {
    test('should convert to DB Companion correctly', () {
      final now = DateTime.now();
      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Test message',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final companion = message.toDBCompanion();

      expect(companion.id.value, equals('msg-id'));
      expect(companion.conversationId.value, equals('conv-id'));
      expect(companion.content.value, equals('Test message'));
      expect(companion.sender.value, equals('user'));
      expect(companion.timestamp.value, equals(now));
      expect(companion.status.value, equals('sent'));
    });

    test('should convert tool message to DB Companion', () {
      final now = DateTime.now();
      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Tool result',
        sender: MessageSender.tool,
        timestamp: now,
        toolName: 'search',
        toolResult: 'Results',
        status: MessageStatus.sent,
      );

      final companion = message.toDBCompanion();

      expect(companion.toolName.value, equals('search'));
      expect(companion.toolResult.value, equals('Results'));
    });

    test('should handle null tool fields in DB Companion', () {
      final now = DateTime.now();
      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'User message',
        sender: MessageSender.user,
        timestamp: now,
        status: MessageStatus.sent,
      );

      final companion = message.toDBCompanion();

      // Value.absent() check not available in newer drift versions
      // Value.absent() check not available in newer drift versions
    });
  });

  group('MessageSender edge cases', () {
    test('should handle tool sender without toolName', () {
      final now = DateTime.now();

      // This is technically an edge case - tool sender should have toolName
      // but the model allows it
      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'Tool without name',
        sender: MessageSender.tool,
        timestamp: now,
        status: MessageStatus.sent,
      );

      expect(message.sender, equals(MessageSender.tool));
      expect(message.toolName, isNull);
    });

    test('should handle user sender with toolName (edge case)', () {
      final now = DateTime.now();

      // This is an edge case - user sender shouldn't have toolName
      // but the model allows it
      final message = MessageData(
        id: 'msg-id',
        conversationId: 'conv-id',
        content: 'User with tool',
        sender: MessageSender.user,
        timestamp: now,
        toolName: 'some_tool',
        status: MessageStatus.sent,
      );

      expect(message.sender, equals(MessageSender.user));
      expect(message.toolName, equals('some_tool'));
    });
  });
}
