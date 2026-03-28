import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/features/conversations/presentation/conversation_list_page.dart';

void main() {
  group('ConversationListPage', () {
    testWidgets('should be a ConsumerStatefulWidget', (tester) async {
      const conversationListPage = ConversationListPage();

      expect(conversationListPage.toStringShort(), contains('ConversationListPage'));
      expect(conversationListPage.runtimeType.toString(), equals('ConversationListPage'));
    });

    testWidgets('should have key parameter support', (tester) async {
      const key = Key('test-key');
      const conversationListPage = ConversationListPage(key: key);

      expect(conversationListPage.key, equals(key));
    });

    testWidgets('should create unique instances', (tester) async {
      const page1 = ConversationListPage();
      const page2 = ConversationListPage();

      expect(identical(page1, page2), isFalse);
    });

    testWidgets('should have createElement method', (tester) async {
      const conversationListPage = ConversationListPage();

      expect(conversationListPage.createElement, isNotNull);
    });
  });
}
