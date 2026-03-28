import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/database.dart';
import 'package:uuid/uuid.dart';

void main() {
  late MBotDatabase database;

  setUp(() {
    // Create in-memory database for testing
    database = MBotDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Creation', () {
    test('should create database successfully', () {
      expect(database, isA<MBotDatabase>());
      expect(database.schemaVersion, equals(3));
    });

    test('should have all tables defined', () {
      expect(database.conversations, isA<TableInfo<Conversations, Conversation>>());
      expect(database.messages, isA<TableInfo<Messages, Message>>());
      expect(database.skills, isA<TableInfo<Skills, Skill>>());
      expect(database.agents, isA<TableInfo<Agents, Agent>>());
      expect(database.memories, isA<TableInfo<Memories, Memory>>());
    });
  });

  group('Conversations Table', () {
    test('should insert a conversation', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = ConversationsCompanion.insert(
        id: id,
        title: 'Test Conversation',
        createdAt: now,
        updatedAt: now,
      );

      await database.into(database.conversations).insert(companion);

      final result = await (database.select(database.conversations)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.title, equals('Test Conversation'));
    });

    test('should update a conversation', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = ConversationsCompanion.insert(
        id: id,
        title: 'Original Title',
        createdAt: now,
        updatedAt: now,
      );

      await database.into(database.conversations).insert(companion);

      final updated = ConversationsCompanion(
        id: Value(id),
        title: const Value('Updated Title'),
        lastMessage: const Value('Last message'),
        updatedAt: Value(DateTime.now()),
      );

      await database.update(database.conversations).replace(updated);

      final result = await (database.select(database.conversations)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.title, equals('Updated Title'));
      expect(result.lastMessage, equals('Last message'));
    });

    test('should delete a conversation', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = ConversationsCompanion.insert(
        id: id,
        title: 'Test Conversation',
        createdAt: now,
        updatedAt: now,
      );

      await database.into(database.conversations).insert(companion);

      await (database.delete(database.conversations)
            ..where((t) => t.id.equals(id)))
          .go();

      final result = await (database.select(database.conversations)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNull);
    });
  });

  group('Messages Table', () {
    test('should insert a message', () async {
      final id = const Uuid().v4();
      final conversationId = const Uuid().v4();
      final now = DateTime.now();

      final companion = MessagesCompanion.insert(
        id: id,
        conversationId: conversationId,
        content: 'Hello World',
        sender: 'user',
        timestamp: now,
        status: 'sent',
      );

      await database.into(database.messages).insert(companion);

      final result = await (database.select(database.messages)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.content, equals('Hello World'));
      expect(result.sender, equals('user'));
      expect(result.status, equals('sent'));
    });

    test('should insert a message with tool call data', () async {
      final id = const Uuid().v4();
      final conversationId = const Uuid().v4();
      final now = DateTime.now();

      final companion = MessagesCompanion.insert(
        id: id,
        conversationId: conversationId,
        content: 'Tool result',
        sender: 'tool',
        timestamp: now,
        toolName: const Value('search'),
        toolResult: const Value('Search results'),
        status: 'sent',
      );

      await database.into(database.messages).insert(companion);

      final result = await (database.select(database.messages)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.toolName, equals('search'));
      expect(result.toolResult, equals('Search results'));
    });

    test('should update message status', () async {
      final id = const Uuid().v4();
      final conversationId = const Uuid().v4();
      final now = DateTime.now();

      final companion = MessagesCompanion.insert(
        id: id,
        conversationId: conversationId,
        content: 'Test message',
        sender: 'user',
        timestamp: now,
        status: 'pending',
      );

      await database.into(database.messages).insert(companion);

      final updated = MessagesCompanion(
        id: Value(id),
        status: const Value('sent'),
      );

      await database.update(database.messages).replace(updated);

      final result = await (database.select(database.messages)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.status, equals('sent'));
    });
  });

  group('Skills Table', () {
    test('should insert a skill', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = SkillsCompanion.insert(
        id: id,
        name: 'Test Skill',
        description: 'A test skill',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test Author',
        status: 'available',
        category: 'ai',
        tags: const Value('test,skill'),
      );

      await database.into(database.skills).insert(companion);

      final result = await (database.select(database.skills)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Test Skill'));
      expect(result.status, equals('available'));
      expect(result.category, equals('ai'));
    });

    test('should update skill with installed timestamp', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = SkillsCompanion.insert(
        id: id,
        name: 'Test Skill',
        description: 'A test skill',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test Author',
        status: 'available',
        category: 'ai',
      );

      await database.into(database.skills).insert(companion);

      final installedTime = DateTime.now();
      final updated = SkillsCompanion(
        id: Value(id),
        status: const Value('installed'),
        installedAt: Value(installedTime),
      );

      await database.update(database.skills).replace(updated);

      final result = await (database.select(database.skills)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.status, equals('installed'));
      expect(result.installedAt, isNotNull);
    });
  });

  group('Agents Table', () {
    test('should insert an agent', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = AgentsCompanion.insert(
        id: id,
        name: 'Test Agent',
        emoji: '🤖',
        status: 'online',
        model: 'gpt-4',
        taskCount: const Value(0),
        lastActive: Value(now),
      );

      await database.into(database.agents).insert(companion);

      final result = await (database.select(database.agents)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.name, equals('Test Agent'));
      expect(result.status, equals('online'));
      expect(result.model, equals('gpt-4'));
    });

    test('should update agent task count', () async {
      final id = const Uuid().v4();

      final companion = AgentsCompanion.insert(
        id: id,
        name: 'Test Agent',
        emoji: '🤖',
        status: 'online',
        model: 'gpt-4',
        taskCount: const Value(0),
      );

      await database.into(database.agents).insert(companion);

      final updated = AgentsCompanion(
        id: Value(id),
        taskCount: const Value(5),
      );

      await database.update(database.agents).replace(updated);

      final result = await (database.select(database.agents)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.taskCount, equals(5));
    });
  });

  group('Memories Table', () {
    test('should insert a memory', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = MemoriesCompanion.insert(
        id: id,
        content: 'User prefers dark mode',
        category: 'preference',
        source: 'user',
        createdAt: now,
        updatedAt: now,
      );

      await database.into(database.memories).insert(companion);

      final result = await (database.select(database.memories)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.id, equals(id));
      expect(result.content, equals('User prefers dark mode'));
      expect(result.category, equals('preference'));
      expect(result.source, equals('user'));
    });

    test('should update memory content', () async {
      final id = const Uuid().v4();
      final now = DateTime.now();

      final companion = MemoriesCompanion.insert(
        id: id,
        content: 'Original memory',
        category: 'fact',
        source: 'ai',
        createdAt: now,
        updatedAt: now,
      );

      await database.into(database.memories).insert(companion);

      final updatedTime = DateTime.now();
      final updated = MemoriesCompanion(
        id: Value(id),
        content: const Value('Updated memory'),
        updatedAt: Value(updatedTime),
      );

      await database.update(database.memories).replace(updated);

      final result = await (database.select(database.memories)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      expect(result, isNotNull);
      expect(result!.content, equals('Updated memory'));
    });
  });

  group('Database Relationships', () {
    test('should cascade delete messages when conversation is deleted', () async {
      final conversationId = const Uuid().v4();
      final now = DateTime.now();

      // Insert conversation
      final conversation = ConversationsCompanion.insert(
        id: conversationId,
        title: 'Test Conversation',
        createdAt: now,
        updatedAt: now,
      );
      await database.into(database.conversations).insert(conversation);

      // Insert messages
      final message1 = MessagesCompanion.insert(
        id: const Uuid().v4(),
        conversationId: conversationId,
        content: 'Message 1',
        sender: 'user',
        timestamp: now,
        status: 'sent',
      );
      final message2 = MessagesCompanion.insert(
        id: const Uuid().v4(),
        conversationId: conversationId,
        content: 'Message 2',
        sender: 'ai',
        timestamp: now,
        status: 'sent',
      );
      await database.into(database.messages).insert(message1);
      await database.into(database.messages).insert(message2);

      // Verify messages exist
      var messages = await (database.select(database.messages)
            ..where((t) => t.conversationId.equals(conversationId)))
          .get();
      expect(messages.length, equals(2));

      // Delete conversation (application-level cascade)
      await database.transaction(() async {
        await (database.delete(database.messages)
              ..where((t) => t.conversationId.equals(conversationId)))
            .go();
        await (database.delete(database.conversations)
              ..where((t) => t.id.equals(conversationId)))
            .go();
      });

      // Verify messages are deleted
      messages = await (database.select(database.messages)
            ..where((t) => t.conversationId.equals(conversationId)))
          .get();
      expect(messages.length, equals(0));

      // Verify conversation is deleted
      final conversationResult = await (database.select(database.conversations)
            ..where((t) => t.id.equals(conversationId)))
          .getSingleOrNull();
      expect(conversationResult, isNull);
    });
  });
}
