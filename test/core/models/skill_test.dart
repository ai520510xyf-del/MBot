import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/core/models/skill.dart';
import 'package:mbot_mobile/core/models/database.dart';

void main() {
  group('SkillStatus', () {
    test('should have all enum values', () {
      expect(SkillStatus.available, isA<SkillStatus>());
      expect(SkillStatus.installed, isA<SkillStatus>());
      expect(SkillStatus.updateAvailable, isA<SkillStatus>());
      expect(SkillStatus.disabled, isA<SkillStatus>());
    });

    test('should have 4 status values', () {
      expect(SkillStatus.values.length, equals(4));
    });
  });

  group('SkillCategory', () {
    test('should have all enum values', () {
      expect(SkillCategory.all, isA<SkillCategory>());
      expect(SkillCategory.ai, isA<SkillCategory>());
      expect(SkillCategory.text, isA<SkillCategory>());
      expect(SkillCategory.image, isA<SkillCategory>());
      expect(SkillCategory.code, isA<SkillCategory>());
      expect(SkillCategory.productivity, isA<SkillCategory>());
    });

    test('should have 6 category values', () {
      expect(SkillCategory.values.length, equals(6));
    });
  });

  group('statusFromString', () {
    test('should parse valid status strings', () {
      expect(statusFromString('available'), equals(SkillStatus.available));
      expect(statusFromString('installed'), equals(SkillStatus.installed));
      expect(statusFromString('updateAvailable'), equals(SkillStatus.updateAvailable));
      expect(statusFromString('disabled'), equals(SkillStatus.disabled));
    });

    test('should return available for invalid strings', () {
      expect(statusFromString('invalid'), equals(SkillStatus.available));
      expect(statusFromString(''), equals(SkillStatus.available));
      expect(statusFromString('unknown'), equals(SkillStatus.available));
    });
  });

  group('categoryFromString', () {
    test('should parse valid category strings', () {
      expect(categoryFromString('all'), equals(SkillCategory.all));
      expect(categoryFromString('ai'), equals(SkillCategory.ai));
      expect(categoryFromString('text'), equals(SkillCategory.text));
      expect(categoryFromString('image'), equals(SkillCategory.image));
      expect(categoryFromString('code'), equals(SkillCategory.code));
      expect(categoryFromString('productivity'), equals(SkillCategory.productivity));
    });

    test('should return all for invalid strings', () {
      expect(categoryFromString('invalid'), equals(SkillCategory.all));
      expect(categoryFromString(''), equals(SkillCategory.all));
      expect(categoryFromString('unknown'), equals(SkillCategory.all));
    });
  });

  group('SkillData', () {
    test('should create SkillData with required fields', () {
      final skill = SkillData(
        id: 'skill-001',
        name: 'AI Assistant',
        description: 'An AI assistant skill',
        emoji: '🤖',
        version: '1.0.0',
        author: 'Test Author',
        installCount: 1000,
        rating: 4.5,
        status: SkillStatus.available,
        category: SkillCategory.ai,
      );

      expect(skill.id, equals('skill-001'));
      expect(skill.name, equals('AI Assistant'));
      expect(skill.description, equals('An AI assistant skill'));
      expect(skill.emoji, equals('🤖'));
      expect(skill.version, equals('1.0.0'));
      expect(skill.author, equals('Test Author'));
      expect(skill.installCount, equals(1000));
      expect(skill.rating, equals(4.5));
      expect(skill.installedAt, isNull);
      expect(skill.status, equals(SkillStatus.available));
      expect(skill.category, equals(SkillCategory.ai));
      expect(skill.tags, isEmpty);
    });

    test('should create SkillData with optional fields', () {
      final now = DateTime.now();
      final skill = SkillData(
        id: 'skill-001',
        name: 'AI Assistant',
        description: 'An AI assistant skill',
        emoji: '🤖',
        version: '1.0.0',
        author: 'Test Author',
        installCount: 1000,
        rating: 4.5,
        installedAt: now,
        status: SkillStatus.installed,
        category: SkillCategory.ai,
        tags: ['ai', 'assistant', 'chat'],
      );

      expect(skill.installedAt, equals(now));
      expect(skill.tags, equals(['ai', 'assistant', 'chat']));
    });

    test('should support copyWith for all fields', () {
      final skill = SkillData(
        id: 'skill-001',
        name: 'Original Name',
        description: 'Original Description',
        emoji: '🤖',
        version: '1.0.0',
        author: 'Author',
        installCount: 100,
        rating: 4.0,
        status: SkillStatus.available,
        category: SkillCategory.ai,
      );

      final copied = skill.copyWith(
        name: 'Updated Name',
        status: SkillStatus.installed,
        installCount: 101,
      );

      expect(copied.id, equals('skill-001')); // unchanged
      expect(copied.name, equals('Updated Name'));
      expect(copied.description, equals('Original Description')); // unchanged
      expect(copied.status, equals(SkillStatus.installed));
      expect(copied.installCount, equals(101));
    });

    test('isInstalled should return true for installed status', () {
      final skill = SkillData(
        id: 'skill-001',
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
        id: 'skill-001',
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
        id: 'skill-001',
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

    test('formattedInstallCount should format millions', () {
      final skill = SkillData(
        id: 'skill-001',
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

    test('formattedInstallCount should format thousands', () {
      final skill = SkillData(
        id: 'skill-001',
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

    test('formattedInstallCount should return raw number for small counts', () {
      final skill = SkillData(
        id: 'skill-001',
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

    test('formattedRating should format correctly', () {
      final skill = SkillData(
        id: 'skill-001',
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
  });

  group('SkillData.fromDB', () {
    test('should convert from DB entity correctly', () {
      final now = DateTime.now();
      final dbSkill = Skill(
        id: 'skill-001',
        name: 'Test Skill',
        description: 'Test Description',
        emoji: '🧪',
        version: '2.0.0',
        author: 'Test Author',
        installCount: 5000,
        rating: 4.7,
        installedAt: now,
        status: 'installed',
        category: 'ai',
        tags: 'ai,test,skill',
      );

      final skillData = SkillData.fromDB(dbSkill);

      expect(skillData.id, equals('skill-001'));
      expect(skillData.name, equals('Test Skill'));
      expect(skillData.description, equals('Test Description'));
      expect(skillData.emoji, equals('🧪'));
      expect(skillData.version, equals('2.0.0'));
      expect(skillData.author, equals('Test Author'));
      expect(skillData.installCount, equals(5000));
      expect(skillData.rating, equals(4.7));
      expect(skillData.installedAt, equals(now));
      expect(skillData.status, equals(SkillStatus.installed));
      expect(skillData.category, equals(SkillCategory.ai));
      expect(skillData.tags, equals(['ai', 'test', 'skill']));
    });

    test('should parse empty tags string', () {
      final dbSkill = Skill(
        id: 'skill-001',
        name: 'Test',
        description: 'Test',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test',
        installCount: 0,
        rating: 0,
        installedAt: null,
        status: 'available',
        category: 'ai',
        tags: '',
      );

      final skillData = SkillData.fromDB(dbSkill);

      expect(skillData.tags, isEmpty);
    });

    test('should parse status string correctly', () {
      final dbSkill = Skill(
        id: 'skill-001',
        name: 'Test',
        description: 'Test',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test',
        installCount: 0,
        rating: 0,
        installedAt: null,
        status: 'updateAvailable',
        category: 'ai',
        tags: '',
      );

      final skillData = SkillData.fromDB(dbSkill);

      expect(skillData.status, equals(SkillStatus.updateAvailable));
    });

    test('should parse category string correctly', () {
      final dbSkill = Skill(
        id: 'skill-001',
        name: 'Test',
        description: 'Test',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test',
        installCount: 0,
        rating: 0,
        installedAt: null,
        status: 'available',
        category: 'productivity',
        tags: '',
      );

      final skillData = SkillData.fromDB(dbSkill);

      expect(skillData.category, equals(SkillCategory.productivity));
    });
  });

  group('SkillDataX extension', () {
    test('should convert to DB Companion correctly', () {
      final now = DateTime.now();
      final skill = SkillData(
        id: 'skill-001',
        name: 'Test Skill',
        description: 'Test Description',
        emoji: '🧪',
        version: '2.0.0',
        author: 'Test Author',
        installCount: 5000,
        rating: 4.7,
        installedAt: now,
        status: SkillStatus.installed,
        category: SkillCategory.ai,
        tags: ['ai', 'test'],
      );

      final companion = skill.toDBCompanion();

      expect(companion.id.value, equals('skill-001'));
      expect(companion.name.value, equals('Test Skill'));
      expect(companion.description.value, equals('Test Description'));
      expect(companion.emoji.value, equals('🧪'));
      expect(companion.version.value, equals('2.0.0'));
      expect(companion.author.value, equals('Test Author'));
      expect(companion.installCount.value, equals(5000));
      expect(companion.rating.value, equals(4.7));
      expect(companion.installedAt.value, equals(now));
      expect(companion.status.value, equals('installed'));
      expect(companion.category.value, equals('ai'));
      expect(companion.tags.value, equals('ai,test'));
    });

    test('should handle null installedAt in DB Companion', () {
      final skill = SkillData(
        id: 'skill-001',
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

      final companion = skill.toDBCompanion();

      // In newer drift, absent is represented by a specific Value type
      expect(companion.installedAt is Value<DateTime>, isFalse);
    });

    test('should handle empty tags in DB Companion', () {
      final skill = SkillData(
        id: 'skill-001',
        name: 'Test',
        description: 'Test',
        emoji: '🧪',
        version: '1.0.0',
        author: 'Test',
        installCount: 0,
        rating: 0,
        status: SkillStatus.available,
        category: SkillCategory.ai,
        tags: [],
      );

      final companion = skill.toDBCompanion();

      expect(companion.tags.value, equals(''));
    });
  });

  group('categoryDisplayName', () {
    test('should return correct display names', () {
      expect(categoryDisplayName(SkillCategory.all), equals('全部'));
      expect(categoryDisplayName(SkillCategory.ai), equals('AI'));
      expect(categoryDisplayName(SkillCategory.text), equals('文本'));
      expect(categoryDisplayName(SkillCategory.image), equals('图像'));
      expect(categoryDisplayName(SkillCategory.code), equals('编程'));
      expect(categoryDisplayName(SkillCategory.productivity), equals('效率'));
    });
  });
}
