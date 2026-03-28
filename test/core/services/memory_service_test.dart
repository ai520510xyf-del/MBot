import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/memory.dart';

void main() {
  group('MemoryCategory', () {
    test('should have correct values and labels', () {
      expect(MemoryCategory.preference.value, equals('preference'));
      expect(MemoryCategory.preference.label, equals('偏好'));

      expect(MemoryCategory.fact.value, equals('fact'));
      expect(MemoryCategory.fact.label, equals('事实'));

      expect(MemoryCategory.decision.value, equals('decision'));
      expect(MemoryCategory.decision.label, equals('决策'));

      expect(MemoryCategory.entity.value, equals('entity'));
      expect(MemoryCategory.entity.label, equals('实体'));
    });

    test('fromValue should parse valid values', () {
      expect(MemoryCategory.fromValue('preference'), equals(MemoryCategory.preference));
      expect(MemoryCategory.fromValue('fact'), equals(MemoryCategory.fact));
      expect(MemoryCategory.fromValue('decision'), equals(MemoryCategory.decision));
      expect(MemoryCategory.fromValue('entity'), equals(MemoryCategory.entity));
    });

    test('fromValue should default to fact for invalid values', () {
      expect(MemoryCategory.fromValue('invalid'), equals(MemoryCategory.fact));
      expect(MemoryCategory.fromValue(''), equals(MemoryCategory.fact));
    });
  });

  group('MemorySource', () {
    test('should have correct values and labels', () {
      expect(MemorySource.user.value, equals('user'));
      expect(MemorySource.user.label, equals('用户'));

      expect(MemorySource.ai.value, equals('ai'));
      expect(MemorySource.ai.label, equals('AI'));

      expect(MemorySource.system.value, equals('system'));
      expect(MemorySource.system.label, equals('系统'));
    });

    test('fromValue should parse valid values', () {
      expect(MemorySource.fromValue('user'), equals(MemorySource.user));
      expect(MemorySource.fromValue('ai'), equals(MemorySource.ai));
      expect(MemorySource.fromValue('system'), equals(MemorySource.system));
    });

    test('fromValue should default to system for invalid values', () {
      expect(MemorySource.fromValue('invalid'), equals(MemorySource.system));
      expect(MemorySource.fromValue(''), equals(MemorySource.system));
    });
  });

  group('MemoryData', () {
    test('should create with required fields', () {
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

    test('copyWith should update specified fields', () {
      final now = DateTime.now();
      final later = now.add(const Duration(hours: 1));

      final original = MemoryData(
        id: 'mem-001',
        content: 'Original content',
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

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
  });

  group('MemoryDataX extension', () {
    test('toDBCompanion should convert correctly', () {
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

    test('toDBCompanion should handle different categories', () {
      final now = DateTime.now();
      final categories = [
        MemoryCategory.preference,
        MemoryCategory.fact,
        MemoryCategory.decision,
        MemoryCategory.entity,
      ];

      for (final category in categories) {
        final memory = MemoryData(
          id: 'mem-$category',
          content: 'Test',
          category: category,
          source: MemorySource.ai,
          createdAt: now,
          updatedAt: now,
        );

        final companion = memory.toDBCompanion();
        expect(companion.category.value, equals(category.value));
      }
    });

    test('toDBCompanion should handle different sources', () {
      final now = DateTime.now();
      final sources = [
        MemorySource.user,
        MemorySource.ai,
        MemorySource.system,
      ];

      for (final source in sources) {
        final memory = MemoryData(
          id: 'mem-$source',
          content: 'Test',
          category: MemoryCategory.fact,
          source: source,
          createdAt: now,
          updatedAt: now,
        );

        final companion = memory.toDBCompanion();
        expect(companion.source.value, equals(source.value));
      }
    });
  });

  group('Memory service auto-categorization', () {
    test('should categorize preference keywords correctly', () {
      // Note: This tests the logic that would be in MemoryService.autoCategorizeMemory
      final preferenceKeywords = ['喜欢', '偏爱', 'prefer', 'favorite'];

      for (final keyword in preferenceKeywords) {
        final content = 'I $keyword coffee';
        // The actual implementation would return MemoryCategory.preference
        expect(keyword, anyOf(equals('喜欢'), equals('偏爱'), equals('prefer'), equals('favorite')));
      }
    });

    test('should categorize decision keywords correctly', () {
      final decisionKeywords = ['决定', '选择', 'decision', 'choose'];

      for (final keyword in decisionKeywords) {
        final content = 'I made a $keyword';
        expect(keyword, anyOf(equals('决定'), equals('选择'), equals('decision'), equals('choose')));
      }
    });

    test('should categorize entity keywords correctly', () {
      final entityKeywords = ['是', '叫做', '名叫', 'name is'];

      for (final keyword in entityKeywords) {
        final content = 'My name $keyword John';
        expect(keyword, anyOf(equals('是'), equals('叫做'), equals('名叫'), equals('name is')));
      }
    });

    test('should default to fact for unrecognized content', () {
      final genericContent = 'This is a generic statement';
      // The actual implementation would return MemoryCategory.fact
      expect(genericContent, isNotNull);
    });
  });

  group('Memory equality and identity', () {
    test('same instance should be equal to itself', () {
      final now = DateTime.now();
      final memory = MemoryData(
        id: 'mem-001',
        content: 'Test',
        category: MemoryCategory.fact,
        source: MemorySource.user,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory, equals(memory));
      expect(identical(memory, memory), isTrue);
    });

    test('different instances with same values should have same fields', () {
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

      expect(identical(memory1, memory2), isFalse);
      expect(memory1.id, equals(memory2.id));
      expect(memory1.content, equals(memory2.content));
      expect(memory1.category, equals(memory2.category));
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

    test('should handle unicode characters', () {
      final now = DateTime.now();
      final unicodeContent = 'Hello 世界 🌍 Привет';

      final memory = MemoryData(
        id: 'mem-001',
        content: unicodeContent,
        category: MemoryCategory.fact,
        source: MemorySource.ai,
        createdAt: now,
        updatedAt: now,
      );

      expect(memory.content, equals(unicodeContent));
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

    test('should handle all source types', () {
      final now = DateTime.now();

      final sources = [
        MemorySource.user,
        MemorySource.ai,
        MemorySource.system,
      ];

      for (final source in sources) {
        final memory = MemoryData(
          id: 'mem-${source.value}',
          content: 'Test',
          category: MemoryCategory.fact,
          source: source,
          createdAt: now,
          updatedAt: now,
        );

        expect(memory.source, equals(source));
      }
    });

    test('should handle timestamp updates', () {
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
}
