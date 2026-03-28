import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/skill.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing
class MockSkillService {
  Future<List<SkillData>> fetchAvailableSkills({
    SkillCategory? category,
    String? searchQuery,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 10));

    // Mock skills data
    final mockSkills = [
      SkillData(
        id: 'skill_001',
        name: 'AI 写作助手',
        description: '智能文章生成与优化，支持多种文体风格',
        emoji: '🤖',
        version: '2.1.0',
        author: 'ClawHub Official',
        installCount: 12453,
        rating: 4.8,
        status: SkillStatus.available,
        category: SkillCategory.ai,
        tags: ['写作', '生成', '优化', 'AI', '文章'],
      ),
      SkillData(
        id: 'skill_002',
        name: '文本摘要',
        description: '长文本快速提取要点，支持中英文',
        emoji: '📝',
        version: '1.5.2',
        author: 'TextMaster',
        installCount: 8567,
        rating: 4.6,
        status: SkillStatus.available,
        category: SkillCategory.text,
        tags: ['摘要', '提取', '文本', '总结'],
      ),
      SkillData(
        id: 'skill_003',
        name: 'AI 绘画',
        description: '文字描述生成精美图片，支持多种风格',
        emoji: '🎨',
        version: '3.0.1',
        author: 'ArtBot',
        installCount: 23421,
        rating: 4.9,
        status: SkillStatus.available,
        category: SkillCategory.image,
        tags: ['绘画', '生成', '图片', 'AI', '艺术'],
      ),
    ];

    // Filter by category
    var filtered = category != null && category != SkillCategory.all
        ? mockSkills.where((s) => s.category == category).toList()
        : mockSkills;

    // Filter by search
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query) ||
                s.tags.any((t) => t.toLowerCase().contains(query)),
          )
          .toList();
    }

    return filtered;
  }
}

void main() {
  group('SkillService', () {
    late MockSkillService skillService;

    setUp(() {
      skillService = MockSkillService();
    });

    group('fetchAvailableSkills', () {
      test('should return all skills when no filters applied', () async {
        final skills = await skillService.fetchAvailableSkills();

        expect(skills.length, equals(3));
        expect(skills[0].id, equals('skill_001'));
        expect(skills[1].id, equals('skill_002'));
        expect(skills[2].id, equals('skill_003'));
      });

      test('should filter by AI category', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.ai,
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_001'));
        expect(skills[0].category, equals(SkillCategory.ai));
      });

      test('should filter by text category', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.text,
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_002'));
        expect(skills[0].category, equals(SkillCategory.text));
      });

      test('should filter by image category', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.image,
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_003'));
        expect(skills[0].category, equals(SkillCategory.image));
      });

      test('should return all skills for all category', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.all,
        );

        expect(skills.length, equals(3));
      });

      test('should filter by search query in name', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: '写作',
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_001'));
        expect(skills[0].name, contains('写作'));
      });

      test('should filter by search query in description', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: '摘要',
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_002'));
      });

      test('should filter by search query in tags', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: '生成',
        );

        expect(skills.length, greaterThan(0));
        expect(skills.any((s) => s.tags.contains('生成')), isTrue);
      });

      test('should be case insensitive for search', () async {
        final skills1 = await skillService.fetchAvailableSkills(
          searchQuery: 'AI',
        );
        final skills2 = await skillService.fetchAvailableSkills(
          searchQuery: 'ai',
        );

        expect(skills1.length, equals(skills2.length));
      });

      test('should return empty list for non-matching search', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: 'nonexistent',
        );

        expect(skills, isEmpty);
      });

      test('should combine category and search filters', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.ai,
          searchQuery: '写作',
        );

        expect(skills.length, equals(1));
        expect(skills[0].id, equals('skill_001'));
      });

      test('should return empty when category and search dont match', () async {
        final skills = await skillService.fetchAvailableSkills(
          category: SkillCategory.text,
          searchQuery: '绘画',
        );

        expect(skills, isEmpty);
      });
    });

    group('SkillData properties', () {
      test('should correctly format install count for millions', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 1500000,
          rating: 0,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        expect(skill.formattedInstallCount, equals('1.5M'));
      });

      test('should correctly format install count for thousands', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 12345,
          rating: 0,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        expect(skill.formattedInstallCount, equals('12.3K'));
      });

      test('should return raw install count for small numbers', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 999,
          rating: 0,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        expect(skill.formattedInstallCount, equals('999'));
      });

      test('should correctly format rating', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 0,
          rating: 4.5678,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        expect(skill.formattedRating, equals('4.6'));
      });

      test('isInstalled should return true for installed status', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 0,
          rating: 0,
          status: SkillStatus.installed,
          category: SkillCategory.ai,
        );

        expect(skill.isInstalled, isTrue);
        expect(skill.isAvailable, isFalse);
      });

      test('isInstalled should return true for updateAvailable status', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 0,
          rating: 0,
          status: SkillStatus.updateAvailable,
          category: SkillCategory.ai,
        );

        expect(skill.isInstalled, isTrue);
        expect(skill.isAvailable, isFalse);
      });

      test('isAvailable should return true for available status', () {
        final skill = SkillData(
          id: 'skill_001',
          name: 'Test',
          description: 'Test',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Test',
          installCount: 0,
          rating: 0,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        expect(skill.isAvailable, isTrue);
        expect(skill.isInstalled, isFalse);
      });
    });

    group('SkillCategory helpers', () {
      test('statusFromString should parse valid statuses', () {
        expect(statusFromString('available'), equals(SkillStatus.available));
        expect(statusFromString('installed'), equals(SkillStatus.installed));
        expect(statusFromString('updateAvailable'), equals(SkillStatus.updateAvailable));
        expect(statusFromString('disabled'), equals(SkillStatus.disabled));
      });

      test('statusFromString should default to available for invalid', () {
        expect(statusFromString('invalid'), equals(SkillStatus.available));
      });

      test('categoryFromString should parse valid categories', () {
        expect(categoryFromString('all'), equals(SkillCategory.all));
        expect(categoryFromString('ai'), equals(SkillCategory.ai));
        expect(categoryFromString('text'), equals(SkillCategory.text));
        expect(categoryFromString('image'), equals(SkillCategory.image));
        expect(categoryFromString('code'), equals(SkillCategory.code));
        expect(categoryFromString('productivity'), equals(SkillCategory.productivity));
      });

      test('categoryFromString should default to all for invalid', () {
        expect(categoryFromString('invalid'), equals(SkillCategory.all));
      });

      test('categoryDisplayName should return correct Chinese names', () {
        expect(categoryDisplayName(SkillCategory.all), equals('全部'));
        expect(categoryDisplayName(SkillCategory.ai), equals('AI'));
        expect(categoryDisplayName(SkillCategory.text), equals('文本'));
        expect(categoryDisplayName(SkillCategory.image), equals('图像'));
        expect(categoryDisplayName(SkillCategory.code), equals('编程'));
        expect(categoryDisplayName(SkillCategory.productivity), equals('效率'));
      });
    });

    group('SkillData copyWith', () {
      test('should create copy with updated fields', () {
        final original = SkillData(
          id: 'skill_001',
          name: 'Original Name',
          description: 'Original Description',
          emoji: '🧪',
          version: '1.0.0',
          author: 'Author',
          installCount: 100,
          rating: 4.0,
          status: SkillStatus.available,
          category: SkillCategory.ai,
        );

        final copied = original.copyWith(
          name: 'Updated Name',
          status: SkillStatus.installed,
          installCount: 101,
        );

        expect(copied.id, equals('skill_001')); // unchanged
        expect(copied.name, equals('Updated Name'));
        expect(copied.description, equals('Original Description')); // unchanged
        expect(copied.status, equals(SkillStatus.installed));
        expect(copied.installCount, equals(101));
      });
    });

    group('Skill service edge cases', () {
      test('should handle empty search query', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: '',
        );

        expect(skills.length, equals(3)); // Should return all
      });

      test('should handle whitespace search query', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: '   ',
        );

        expect(skills.length, equals(3)); // Should return all
      });

      test('should handle special characters in search', () async {
        final skills = await skillService.fetchAvailableSkills(
          searchQuery: 'AI',
        );

        expect(skills.isNotEmpty, isTrue);
      });
    });
  });
}
