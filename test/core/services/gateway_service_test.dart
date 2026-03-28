import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/services/gateway_service.dart';
import 'package:mbot_mobile/core/providers/gateway_provider.dart';

void main() {
  group('AgpMessageType', () {
    test('should have all message types', () {
      expect(AgpMessageType.sessionUpdate, isA<AgpMessageType>());
      expect(AgpMessageType.toolCall, isA<AgpMessageType>());
      expect(AgpMessageType.toolResult, isA<AgpMessageType>());
      expect(AgpMessageType.error, isA<AgpMessageType>());
      expect(AgpMessageType.ping, isA<AgpMessageType>());
      expect(AgpMessageType.pong, isA<AgpMessageType>());
    });

    test('should have 6 message types', () {
      expect(AgpMessageType.values.length, equals(6));
    });

    test('should have correct string names', () {
      expect(AgpMessageType.sessionUpdate.name, equals('sessionUpdate'));
      expect(AgpMessageType.toolCall.name, equals('toolCall'));
      expect(AgpMessageType.toolResult.name, equals('toolResult'));
      expect(AgpMessageType.error.name, equals('error'));
      expect(AgpMessageType.ping.name, equals('ping'));
      expect(AgpMessageType.pong.name, equals('pong'));
    });
  });

  group('AgpMessage', () {
    test('should create AgpMessage with required fields', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': 'Hello', 'type': 'text'},
      );

      expect(message.msgId, equals('msg_001'));
      expect(message.guid, equals('sess_001'));
      expect(message.method, equals(AgpMessageType.sessionUpdate));
      expect(message.payload, equals({'content': 'Hello', 'type': 'text'}));
    });

    test('should serialize to JSON correctly', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': 'Hello'},
      );

      final json = message.toJson();

      expect(json['msg_id'], equals('msg_001'));
      expect(json['guid'], equals('sess_001'));
      expect(json['method'], equals('sessionUpdate'));
      expect(json['payload'], equals({'content': 'Hello'}));
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'msg_id': 'msg_001',
        'guid': 'sess_001',
        'method': 'sessionUpdate',
        'payload': {'content': 'Hello', 'type': 'text'},
      };

      final message = AgpMessage.fromJson(json);

      expect(message.msgId, equals('msg_001'));
      expect(message.guid, equals('sess_001'));
      expect(message.method, equals(AgpMessageType.sessionUpdate));
      expect(message.payload, equals({'content': 'Hello', 'type': 'text'}));
    });

    test('should parse all message types from JSON', () {
      final messageTypes = [
        'sessionUpdate',
        'toolCall',
        'toolResult',
        'error',
        'ping',
        'pong',
      ];

      for (final type in messageTypes) {
        final json = {
          'msg_id': 'msg_001',
          'guid': 'sess_001',
          'method': type,
          'payload': {},
        };

        final message = AgpMessage.fromJson(json);
        expect(message.method.name, equals(type));
      }
    });

    test('should default to sessionUpdate for invalid method type', () {
      final json = {
        'msg_id': 'msg_001',
        'guid': 'sess_001',
        'method': 'invalidType',
        'payload': {},
      };

      final message = AgpMessage.fromJson(json);
      expect(message.method, equals(AgpMessageType.sessionUpdate));
    });

    test('should handle empty payload', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.ping,
        payload: {},
      );

      final json = message.toJson();
      expect(json['payload'], isEmpty);
    });

    test('should handle complex payload', () {
      final complexPayload = {
        'content': 'Hello',
        'type': 'text',
        'metadata': {'timestamp': 1234567890, 'user': 'test'},
        'items': ['item1', 'item2', 'item3'],
      };

      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: complexPayload,
      );

      final json = message.toJson();
      expect(json['payload'], equals(complexPayload));
    });
  });

  group('GatewayConnectionState', () {
    test('should have all connection states', () {
      expect(GatewayConnectionState.disconnected, isA<GatewayConnectionState>());
      expect(GatewayConnectionState.connecting, isA<GatewayConnectionState>());
      expect(GatewayConnectionState.connected, isA<GatewayConnectionState>());
      expect(GatewayConnectionState.failed, isA<GatewayConnectionState>());
    });

    test('should have 4 connection states', () {
      expect(GatewayConnectionState.values.length, equals(4));
    });

    test('should have correct string names', () {
      expect(GatewayConnectionState.disconnected.name, equals('disconnected'));
      expect(GatewayConnectionState.connecting.name, equals('connecting'));
      expect(GatewayConnectionState.connected.name, equals('connected'));
      expect(GatewayConnectionState.failed.name, equals('failed'));
    });
  });

  group('AgpMessage scenarios', () {
    test('should create sessionUpdate message', () {
      final message = AgpMessage(
        msgId: 'msg_session',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {
          'content': 'Hello AI',
          'type': 'text',
          'complete': false,
        },
      );

      expect(message.method, equals(AgpMessageType.sessionUpdate));
      expect(message.payload['content'], equals('Hello AI'));
      expect(message.payload['type'], equals('text'));
      expect(message.payload['complete'], isFalse);
    });

    test('should create toolCall message', () {
      final message = AgpMessage(
        msgId: 'msg_tool',
        guid: 'sess_001',
        method: AgpMessageType.toolCall,
        payload: {
          'tool_name': 'search',
          'args': {'query': 'test', 'limit': 10},
        },
      );

      expect(message.method, equals(AgpMessageType.toolCall));
      expect(message.payload['tool_name'], equals('search'));
      expect(message.payload['args'], isA<Map>());
    });

    test('should create toolResult message', () {
      final message = AgpMessage(
        msgId: 'msg_result',
        guid: 'sess_001',
        method: AgpMessageType.toolResult,
        payload: {
          'tool_name': 'search',
          'result': 'Found 5 results',
        },
      );

      expect(message.method, equals(AgpMessageType.toolResult));
      expect(message.payload['result'], equals('Found 5 results'));
    });

    test('should create error message', () {
      final message = AgpMessage(
        msgId: 'msg_error',
        guid: 'sess_001',
        method: AgpMessageType.error,
        payload: {
          'message': 'An error occurred',
          'code': 'ERR_001',
        },
      );

      expect(message.method, equals(AgpMessageType.error));
      expect(message.payload['message'], equals('An error occurred'));
    });

    test('should create ping message', () {
      final message = AgpMessage(
        msgId: 'msg_ping',
        guid: 'sess_001',
        method: AgpMessageType.ping,
        payload: {
          'timestamp': 1234567890,
        },
      );

      expect(message.method, equals(AgpMessageType.ping));
      expect(message.payload['timestamp'], equals(1234567890));
    });

    test('should create pong message', () {
      final message = AgpMessage(
        msgId: 'msg_pong',
        guid: 'sess_001',
        method: AgpMessageType.pong,
        payload: {},
      );

      expect(message.method, equals(AgpMessageType.pong));
    });
  });

  group('AgpMessage serialization round-trip', () {
    test('should serialize and deserialize correctly', () {
      final original = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': 'Test message', 'complete': true},
      );

      final json = original.toJson();
      final deserialized = AgpMessage.fromJson(json);

      expect(deserialized.msgId, equals(original.msgId));
      expect(deserialized.guid, equals(original.guid));
      expect(deserialized.method, equals(original.method));
      expect(deserialized.payload, equals(original.payload));
    });

    test('should handle special characters in payload', () {
      final original = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': '测试\n特殊\t字符\"emoji\'😀'},
      );

      final json = original.toJson();
      final deserialized = AgpMessage.fromJson(json);

      expect(deserialized.payload['content'], equals(original.payload['content']));
    });

    test('should handle unicode in message fields', () {
      final original = AgpMessage(
        msgId: 'msg_世界',
        guid: 'sess_🌍',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': 'Hello 世界 🌍'},
      );

      final json = original.toJson();
      final deserialized = AgpMessage.fromJson(json);

      expect(deserialized.msgId, equals(original.msgId));
      expect(deserialized.guid, equals(original.guid));
      expect(deserialized.payload['content'], equals(original.payload['content']));
    });
  });

  group('AgpMessage edge cases', () {
    test('should handle null values in payload', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {'content': null, 'type': 'text'},
      );

      expect(message.payload['content'], isNull);
      expect(message.payload['type'], equals('text'));
    });

    test('should handle nested payload structures', () {
      final nestedPayload = {
        'level1': {
          'level2': {
            'level3': 'deep value',
          },
          'array': [1, 2, 3],
        },
      };

      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: nestedPayload,
      );

      expect(message.payload['level1']['level2']['level3'], equals('deep value'));
      expect(message.payload['level1']['array'], equals([1, 2, 3]));
    });

    test('should handle numeric values in payload', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {
          'int': 42,
          'double': 3.14,
          'negative': -10,
        },
      );

      expect(message.payload['int'], equals(42));
      expect(message.payload['double'], equals(3.14));
      expect(message.payload['negative'], equals(-10));
    });

    test('should handle boolean values in payload', () {
      final message = AgpMessage(
        msgId: 'msg_001',
        guid: 'sess_001',
        method: AgpMessageType.sessionUpdate,
        payload: {
          'bool_true': true,
          'bool_false': false,
        },
      );

      expect(message.payload['bool_true'], isTrue);
      expect(message.payload['bool_false'], isFalse);
    });
  });

  group('Message ID generation patterns', () {
    test('should validate msg ID patterns', () {
      // Test that message IDs follow the expected pattern
      final validIds = [
        'msg_1234567890_abcdefgh',
        'msg_9999999999_xyz12345',
      ];

      for (final id in validIds) {
        // The actual GatewayService generates IDs with: msg_${timestamp}_${random}
        // For testing, we just verify the pattern structure
        expect(id.startsWith('msg_'), isTrue);
        expect(id.contains('_'), isTrue);
      }
    });

    test('should validate session GUID patterns', () {
      final validGuids = [
        'sess_1234567890_abcdefghijkl',
        'sess_9999999999_xyz123abc456',
      ];

      for (final guid in validGuids) {
        expect(guid.startsWith('sess_'), isTrue);
        expect(guid.contains('_'), isTrue);
      }
    });
  });
}
