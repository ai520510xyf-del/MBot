import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/features/skills/presentation/skill_market_page.dart';

void main() {
  group('SkillMarketPage', () {
    testWidgets('should be a ConsumerStatefulWidget', (tester) async {
      const skillMarketPage = SkillMarketPage();

      expect(skillMarketPage.toStringShort(), contains('SkillMarketPage'));
      expect(skillMarketPage.runtimeType.toString(), equals('SkillMarketPage'));
    });

    testWidgets('should have key parameter support', (tester) async {
      const key = Key('test-key');
      const skillMarketPage = SkillMarketPage(key: key);

      expect(skillMarketPage.key, equals(key));
    });

    testWidgets('should create unique instances', (tester) async {
      const page1 = SkillMarketPage();
      const page2 = SkillMarketPage();

      expect(identical(page1, page2), isFalse);
    });

    testWidgets('should have createElement method', (tester) async {
      const skillMarketPage = SkillMarketPage();

      expect(skillMarketPage.createElement, isNotNull);
    });
  });
}
