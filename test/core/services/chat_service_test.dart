import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/message.dart';
import 'package:mbot_mobile/core/services/chat_service.dart';

void main() {
  group('ChatResponse', () {
    test('should create ChatResponse with required fields', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello, how can I help?',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.messageId, equals('msg_001'));
      expect(response.content, equals('Hello, how can I help?'));
      expect(response.sender, equals(MessageSender.ai));
      expect(response.isComplete, isTrue);
      expect(response.toolName, isNull);
      expect(response.toolResult, isNull);
    });

    test('should create ChatResponse with tool fields', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Searching...',
        sender: MessageSender.ai,
        toolName: 'search',
        isComplete: false,
      );

      expect(response.toolName, equals('search'));
      expect(response.toolResult, isNull);
      expect(response.isComplete, isFalse);
    });

    test('should create ChatResponse with tool result', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Search complete',
        sender: MessageSender.ai,
        toolName: 'search',
        toolResult: 'Found 5 results',
        isComplete: false,
      );

      expect(response.toolName, equals('search'));
      expect(response.toolResult, equals('Found 5 results'));
    });

    test('copyWith should update specified fields', () {
      final original = ChatResponse(
        messageId: 'msg_001',
        content: 'Partial',
        sender: MessageSender.ai,
        isComplete: false,
      );

      final updated = original.copyWith(
        content: 'Complete response',
        isComplete: true,
      );

      expect(updated.messageId, equals('msg_001')); // unchanged
      expect(updated.content, equals('Complete response'));
      expect(updated.isComplete, isTrue);
    });

    test('should handle different sender types', () {
      final userResponse = ChatResponse(
        messageId: 'msg_001',
        content: 'User message',
        sender: MessageSender.user,
        isComplete: true,
      );

      final aiResponse = ChatResponse(
        messageId: 'msg_002',
        content: 'AI response',
        sender: MessageSender.ai,
        isComplete: true,
      );

      final toolResponse = ChatResponse(
        messageId: 'msg_003',
        content: 'Tool result',
        sender: MessageSender.tool,
        isComplete: true,
      );

      expect(userResponse.sender, equals(MessageSender.user));
      expect(aiResponse.sender, equals(MessageSender.ai));
      expect(toolResponse.sender, equals(MessageSender.tool));
    });

    test('should handle streaming responses', () {
      final partial = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello',
        sender: MessageSender.ai,
        isComplete: false,
      );

      final complete = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello, world!',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(partial.isComplete, isFalse);
      expect(complete.isComplete, isTrue);
      expect(complete.content.length, greaterThan(partial.content.length));
    });
  });

  group('MessageSender', () {
    test('should have all sender types', () {
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
    test('should have all status values', () {
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

  group('Message parsing edge cases', () {
    test('should handle empty content', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: '',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.content, isEmpty);
    });

    test('should handle special characters', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: '测试\n特殊\t字符\"emoji\'😀',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.content, contains('测试'));
      expect(response.content, contains('😀'));
    });

    test('should handle long content', () {
      final longContent = 'A' * 10000;

      final response = ChatResponse(
        messageId: 'msg_001',
        content: longContent,
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.content.length, equals(10000));
    });

    test('should handle markdown content', () {
      final markdownContent = '''
# Heading

**Bold text** and *italic text*

- List item 1
- List item 2

[Link](https://example.com)
''';

      final response = ChatResponse(
        messageId: 'msg_001',
        content: markdownContent,
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.content, contains('# Heading'));
      expect(response.content, contains('**Bold text**'));
    });
  });

  group('ChatResponse equality scenarios', () {
    test('same instance should equal itself', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Test',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response, equals(response));
    });

    test('should have different identities for different instances', () {
      final response1 = ChatResponse(
        messageId: 'msg_001',
        content: 'Test',
        sender: MessageSender.ai,
        isComplete: true,
      );

      final response2 = ChatResponse(
        messageId: 'msg_001',
        content: 'Test',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(identical(response1, response2), isFalse);
    });
  });

  group('Tool call scenarios', () {
    test('should represent tool initiation', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: '',
        sender: MessageSender.ai,
        toolName: 'search',
        isComplete: false,
      );

      expect(response.toolName, equals('search'));
      expect(response.toolResult, isNull);
      expect(response.isComplete, isFalse);
    });

    test('should represent tool completion with result', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Search completed',
        sender: MessageSender.ai,
        toolName: 'search',
        toolResult: 'Found 10 results',
        isComplete: false,
      );

      expect(response.toolName, equals('search'));
      expect(response.toolResult, equals('Found 10 results'));
    });

    test('should handle multiple tool calls in sequence', () {
      final tool1 = ChatResponse(
        messageId: 'msg_001',
        content: 'Calling tool 1',
        sender: MessageSender.ai,
        toolName: 'search',
        isComplete: false,
      );

      final tool2 = ChatResponse(
        messageId: 'msg_001',
        content: 'Calling tool 2',
        sender: MessageSender.ai,
        toolName: 'calculate',
        isComplete: false,
      );

      expect(tool1.toolName, equals('search'));
      expect(tool2.toolName, equals('calculate'));
    });

    test('should handle tool with null result', () {
      final response = ChatResponse(
        messageId: 'msg_001',
        content: 'Tool executed',
        sender: MessageSender.ai,
        toolName: 'search',
        toolResult: null,
        isComplete: false,
      );

      expect(response.toolResult, isNull);
    });
  });

  group('Message lifecycle scenarios', () {
    test('should represent message lifecycle states', () {
      final pending = ChatResponse(
        messageId: 'msg_001',
        content: '',
        sender: MessageSender.ai,
        isComplete: false,
      );

      final streaming = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello',
        sender: MessageSender.ai,
        isComplete: false,
      );

      final complete = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello, world!',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(pending.content, isEmpty);
      expect(pending.isComplete, isFalse);

      expect(streaming.content, isNotEmpty);
      expect(streaming.isComplete, isFalse);

      expect(complete.content, isNotEmpty);
      expect(complete.isComplete, isTrue);
    });

    test('should handle content accumulation during streaming', () {
      var response = ChatResponse(
        messageId: 'msg_001',
        content: 'Hello',
        sender: MessageSender.ai,
        isComplete: false,
      );

      // Simulate streaming updates
      response = response.copyWith(content: 'Hello,');
      expect(response.content, equals('Hello,'));

      response = response.copyWith(content: 'Hello, world');
      expect(response.content, equals('Hello, world'));

      response = response.copyWith(
        content: 'Hello, world!',
        isComplete: true,
      );
      expect(response.content, equals('Hello, world!'));
      expect(response.isComplete, isTrue);
    });
  });

  group('ChatResponse edge cases', () {
    test('should handle very long message IDs', () {
      final longId = 'a' * 1000;

      final response = ChatResponse(
        messageId: longId,
        content: 'Test',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.messageId.length, equals(1000));
    });

    test('should handle special tool names', () {
      final specialToolNames = [
        'tool_with_underscores',
        'tool-with-dashes',
        'tool.with.dots',
        'tool@with#special',
      ];

      for (final toolName in specialToolNames) {
        final response = ChatResponse(
          messageId: 'msg_001',
          content: 'Test',
          sender: MessageSender.ai,
          toolName: toolName,
          isComplete: false,
        );

        expect(response.toolName, equals(toolName));
      }
    });

    test('should handle multiline content', () {
      final multiline = '''
Line 1
Line 2
Line 3
''';

      final response = ChatResponse(
        messageId: 'msg_001',
        content: multiline,
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(response.content.split('\n').length, equals(4)); // 3 lines + 1 empty
    });
  });

  group('Response flow scenarios', () {
    test('should handle user message followed by AI response', () {
      final userMessage = ChatResponse(
        messageId: 'msg_user',
        content: 'Hello AI',
        sender: MessageSender.user,
        isComplete: true,
      );

      final aiResponse = ChatResponse(
        messageId: 'msg_ai',
        content: 'Hello! How can I help?',
        sender: MessageSender.ai,
        isComplete: true,
      );

      expect(userMessage.sender, equals(MessageSender.user));
      expect(aiResponse.sender, equals(MessageSender.ai));
      expect(userMessage.messageId, isNot(equals(aiResponse.messageId)));
    });

    test('should handle AI response with tool calls', () {
      final aiResponse = ChatResponse(
        messageId: 'msg_ai',
        content: 'Let me search for that',
        sender: MessageSender.ai,
        isComplete: false,
      );

      final toolCall = ChatResponse(
        messageId: 'msg_ai',
        content: 'Let me search for that',
        sender: MessageSender.ai,
        toolName: 'search',
        isComplete: false,
      );

      final toolResult = ChatResponse(
        messageId: 'msg_ai',
        content: 'Let me search for that',
        sender: MessageSender.ai,
        toolName: 'search',
        toolResult: 'Found results',
        isComplete: false,
      );

      final finalResponse = ChatResponse(
        messageId: 'msg_ai',
        content: 'Let me search for that\nHere are the results',
        sender: MessageSender.ai,
        isComplete: true,
      );

      // All have the same messageId (same conversation turn)
      expect(aiResponse.messageId, equals(toolCall.messageId));
      expect(toolCall.messageId, equals(toolResult.messageId));
      expect(toolResult.messageId, equals(finalResponse.messageId));
    });
  });
}
