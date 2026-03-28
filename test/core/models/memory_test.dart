import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/memory.dart';
import 'package:mbot_mobile/core/models/database.dart';

void main() {
  group('MemoryCategory', () {
    test('should have all enum values', () {
      expect(MemoryCategory.preference, isA<MemoryCategory>());
      expect(MemoryCategory.fact, isA<MemoryCategory>());
      expect(MemoryCategory.decision, isA<MemoryCategory>());
      expect(MemoryCategory.entity, isA<MemoryCategory>());
    });

    test('should have 4 category values', () {
      expect(MemoryCategory.values.length, equals(4));
    });

    test('should have correct value and label', () {
      expect(MemoryCategory.preference.value, equals('preference'));
      expect(MemoryCategory.preference.label, equals('偏好'));

      expect(MemoryCategory.fact.value, equals('fact'));
      expect(MemoryCategory.fact.label, equals('事实'));

      expect(MemoryCategory.decision.value, equals('decision'));
      expect(MemoryCategory.decision.label, equals('决策'));

      expect(MemoryCategory.entity.value, equals('entity'));
      expect(MemoryCategory.entity.label, equals('实体'));
    });
  });

  group('MemoryCategory.fromValue', () {
    test('should parse valid category values', () {
      expect(MemoryCategory.fromValue('preference'), equals(MemoryCategory.preference));
      expect(MemoryCategory.fromValue('fact'), equals(MemoryCategory.fact));
      expect(MemoryCategory.fromValue('decision'), equals(MemoryCategory.decision));
      expect(MemoryCategory.fromValue('entity'), equals(MemoryCategory.entity));
    });

    test('should return fact for invalid values', () {
      expect(MemoryCategory.fromValue('invalid'), equals(MemoryCategory.fact));
      expect(MemoryCategory.fromValue(''), equals(MemoryCategory.fact));
      expect(MemoryCategory.fromValue('unknown'), equals(MemoryCategory.fact));
    });
  });

  group('MemorySource', () {
    test('should have all enum values', () {
      expect(MemorySource.user, isA<MemorySource>());
      expect(MemorySource.ai, isA<MemorySource>());
      expect(MemorySource.system, isA<MemorySource>());
    });

    test('should have 3 source values', () {
      expect(MemorySource.values.length, equals(3));
    });

    test('should have correct value and label', () {
      expect(MemorySource.user.value, equals('user'));
      expect(MemorySource.user.label, equals('用户'));

      expect(MemorySource.ai.value, equals('ai'));
      expect(MemorySource.ai.label, equals('AI'));

      expect(MemorySource.system.value, equals('system'));
      expect(MemorySource.system.label, equals('系统'));
    });
  });

  group('MemorySource.fromValue', () {
    test('should parse valid source values', () {
      expect(MemorySource.fromValue('user'), equals(MemorySource.user));
      expect(MemorySource.fromValue('ai'), equals(MemorySource.ai));
      expect(MemorySource.fromValue('system'), equals(MemorySource.system));
    });

    test('should return system for invalid values', () {
      expect(MemorySource.fromValue('invalid'), equals(MemorySource.system));
      expect(MemorySource.fromValue(''), equals(MemorySource.system));
      expect(MemorySource.fromValue('unknown'), equals(MemorySource.system));
    });
  });

  group('MemoryData', () {
    test('should create MemoryData with required fields', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: 'User prefers dark mode',
        category: MemoryCategory.preference,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory.id, equals('mem-001'));
      expect(memory.content, equals('User prefers dark mode'));
      expect(memory.category, equals(MemoryCategory.preference));
      expect(memory.source, equals(MemorySource.user));
      expect(memory.createdAt, equals(now));
      expect(memory.updatedAt, equals(now));
    });

    test('should support copyWith for all fields', () {
      final now = DateTime.now();
      final original = MemoryData(
        id: 'mem-001',
        content: 'Original content',
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      final later = now.add(const Duration(hours: 1));
      final copied = original.copyWith(
        content: 'Updated content',
        category: MemoryCategory.preference,
        updatedAt: later,
      );

      expect(copied.id, equals('mem-001')); // unchanged
      expect(copied.content, equals('Updated content'));
      expect(copied.category, equals(MemoryCategory.preference));
      expect(copied.source, equals(MemorySource.ai)); // unchanged
      expect(copied.createdAt, equals(now)); // unchanged
      expect(copied.updatedAt, equals(later));
    });

    test('should handle different categories', () {
      final now = DateTime.now();

      final preferenceMemory = MemoryData(
        id: 'mem-1',
        content: 'Likes coffee',
        category: MemoryCategory.preference,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      final factMemory = MemoryData(
        id: 'mem-2',
        content: 'Lives in Tokyo',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      final decisionMemory = MemoryData(
        id: 'mem-3',
        content: 'Chose plan B',
        category: MemoryCategory.decision,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      final entityMemory = MemoryData(
        id: 'mem-4',
        content: 'Friend is John',
        category: MemoryCategory.entity,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      expect(preferenceMemory.category, equals(MemoryCategory.preference));
      expect(factMemory.category, equals(MemoryCategory.fact));
      expect(decisionMemory.category, equals(MemoryCategory.decision));
      expect(entityMemory.category, equals(MemoryCategory.entity));
    });

    test('should handle different sources', () {
      final now = DateTime.now();

      final userMemory = MemoryData(
        id: 'mem-1',
        content: 'User said',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      final aiMemory = MemoryData(
        id: 'mem-2',
        content: 'AI learned',
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      final systemMemory = MemoryData(
        id: 'mem-3',
        content: 'System note',
        category: MemoryCategory.fact,
        source: MemorySource.system,
        createdAt: now,
        updatedAt: now,
      );

      expect(userMemory.source, equals(MemorySource.user));
      expect(aiMemory.source, equals(MemorySource.ai));
      expect(systemMemory.source, equals(MemorySource.system));
    });

    test('should handle empty content', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: '',
        category: MemoryCategory.fact,
        source: MemorySource.system,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory.content, isEmpty);
    });

    test('should handle long content', () {
      final now = DateTime.now();
      final longContent = 'A' * 1000;
      final memory = MemoryData(
        id: 'mem-001',
        content: longContent,
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory.content.length, equals(1000));
    });

    test('should handle different timestamps', () {
      final created = DateTime(2024, 1, 1, 10, 0, 0);
      final updated = DateTime(2024, 1, 1, 11, 0, 0);

      final memory = MemoryData(
        id: 'mem-001',
        content: 'Test',
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: created,
        updatedAt: updated,
      );

      expect(memory.createdAt, equals(created));
      expect(memory.updatedAt, equals(updated));
      expect(memory.updatedAt.isAfter(memory.createdAt), isTrue);
    });
  });

  group('MemoryData.fromDB', () {
    test('should convert from DB entity correctly', () {
      final now = DateTime.now();
      final dbMemory = Memory(
        id: 'mem-001',
        content: 'User prefers dark mode',
        category: 'preference',
        source: 'user',
        createdAt: now,
        updatedAt: now,
      );

      final memoryData = MemoryData.fromDB(dbMemory);

      expect(memoryData.id, equals('mem-001'));
      expect(memoryData.content, equals('User prefers dark mode'));
      expect(memoryData.category, equals(MemoryCategory.preference));
      expect(memoryData.source, equals(MemorySource.user));
      expect(memoryData.createdAt, equals(now));
      expect(memoryData.updatedAt, equals(now));
    });

    test('should parse category value correctly', () {
      final now = DateTime.now();
      final dbMemory = Memory(
        id: 'mem-001',
        content: 'Test',
        category: 'decision',
        source: 'ai',
        createdAt: now,
        updatedAt: now,
      );

      final memoryData = MemoryData.fromDB(dbMemory);

      expect(memoryData.category, equals(MemoryCategory.decision));
    });

    test('should parse source value correctly', () {
      final now = DateTime.now();
      final dbMemory = Memory(
        id: 'mem-001',
        content: 'Test',
        category: 'fact',
        source: 'system',
        createdAt: now,
        updatedAt: now,
      );

      final memoryData = MemoryData.fromDB(dbMemory);

      expect(memoryData.source, equals(MemorySource.system));
    });
  });

  group('MemoryDataX extension', () {
    test('should convert to DB Companion correctly', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: 'User prefers dark mode',
        category: MemoryCategory.preference,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      final companion = memory.toDBCompanion();

      expect(companion.id.value, equals('mem-001'));
      expect(companion.content.value, equals('User prefers dark mode'));
      expect(companion.category.value, equals('preference'));
      expect(companion.source.value, equals('user'));
      expect(companion.createdAt.value, equals(now));
      expect(companion.updatedAt.value, equals(now));
    });

    test('should handle different categories in Companion', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: 'Test',
        category: MemoryCategory.entity,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      final companion = memory.toDBCompanion();

      expect(companion.category.value, equals('entity'));
    });

    test('should handle different sources in Companion', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: 'Test',
        category: MemoryCategory.fact,
        source: MemorySource.system,
        createdAt: now,
        updatedAt: now,
      );

      final companion = memory.toDBCompanion();

      expect(companion.source.value, equals('system'));
    });
  });

  group('MemoryData equality', () {
    test('should have same identity for same instance', () {
      final now = DateTime.now();

      final memory1 = MemoryData(
        id: 'mem-001',
        content: 'Test content',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      // MemoryData is a regular class, so same instance is equal
      expect(memory1, equals(memory1));
      expect(identical(memory1, memory1), isTrue);
    });

    test('should have different identity for different instances with same values', () {
      final now = DateTime.now();

      final memory1 = MemoryData(
        id: 'mem-001',
        content: 'Test content',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      final memory2 = MemoryData(
        id: 'mem-001',
        content: 'Test content',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      // Different instances are not equal (no value equality override)
      expect(identical(memory1, memory2), isFalse);
      // But fields are the same
      expect(memory1.id, equals(memory2.id));
      expect(memory1.content, equals(memory2.content));
    });
  });

  group('Memory edge cases', () {
    test('should handle special characters in content', () {
      final now = DateTime.now();
      final specialContent = '测试\n特殊\t字符\"emoji\'😀';

      final memory = MemoryData(
        id: 'mem-001',
        content: specialContent,
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory.content, equals(specialContent));
    });

    test('should handle all category types', () {
      final now = DateTime.now();

      final categories = [
        MemoryCategory.preference,
        MemoryCategory.fact,
        MemoryCategory.decision,
        MemoryCategory.entity,
      ];

      for (final category in categories) {
        final memory = MemoryData(
          id: 'mem-${category.value}',
          content: 'Test',
          category: category,
          source: MemorySource.ai,
          createdAt: now,
          updatedAt: now,
        );

        expect(memory.category, equals(category));
      }
    });
  });
}
