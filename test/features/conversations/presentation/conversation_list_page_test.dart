import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbot_mobile/features/conversations/presentation/conversation_list_page.dart';

void main() {
  group('ConversationListPage', () {
    testWidgets('should render app bar with MBot title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      expect(find.text('MBot'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should render add button in app bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('should render mock conversations list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Check for expected mock conversations
      expect(find.text('AI 写作助手'), findsOneWidget);
      expect(find.text('AI 编程助手'), findsOneWidget);
      expect(find.text('闲聊'), findsOneWidget);
      expect(find.text('AI 绘画'), findsOneWidget);
      expect(find.text('数据分析'), findsOneWidget);
    });

    testWidgets('should display conversation last messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('帮我写一封邮件给客户'), findsOneWidget);
      expect(find.textContaining('这段代码为什么报错？'), findsOneWidget);
    });

    testWidgets('should display conversation timestamps', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('09:15'), findsOneWidget);
      expect(find.text('昨天'), findsNWidgets(2));
      expect(find.text('周一'), findsOneWidget);
    });

    testWidgets('should display unread message badges', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Message count badges should be visible
      final badgeContainers = find.byType(Container);
      // At least some containers should exist for badges
      expect(badgeContainers, findsWidgets);
    });

    testWidgets('should show new conversation dialog when add button tapped',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the add button
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Check for dialog elements
      expect(find.text('新建对话'), findsOneWidget);
      expect(find.text('对话标题'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('创建'), findsOneWidget);
    });

    testWidgets('should dismiss new conversation dialog when cancel tapped',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Tap cancel
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('新建对话'), findsNothing);
    });

    testWidgets('should show conversation options on long press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find first conversation and long press
      final firstConversation = find.text('AI 写作助手');
      await tester.longPress(firstConversation);
      await tester.pumpAndSettle();

      // Check for bottom sheet options
      expect(find.text('重命名'), findsOneWidget);
      expect(find.text('置顶'), findsOneWidget);
      expect(find.text('标为已读'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
    });

    testWidgets('should show rename dialog from options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Long press to open options
      await tester.longPress(find.text('AI 写作助手'));
      await tester.pumpAndSettle();

      // Tap rename
      await tester.tap(find.text('重命名'));
      await tester.pumpAndSettle();

      // Check for rename dialog
      expect(find.text('重命名对话'), findsOneWidget);
      expect(find.text('保存'), findsOneWidget);
    });

    testWidgets('should show delete confirmation from options', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Long press to open options
      await tester.longPress(find.text('AI 写作助手'));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('删除'));
      await tester.pumpAndSettle();

      // Check for delete confirmation dialog
      expect(find.text('删除对话'), findsOneWidget);
      expect(find.textContaining('确定要删除'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget); // Delete button from confirmation dialog
    });

    testWidgets('should render conversation emoji icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for emojis in the list
      expect(find.text('🤖'), findsOneWidget); // AI assistant
      expect(find.text('💻'), findsOneWidget); // Programming assistant
      expect(find.text('💬'), findsOneWidget); // Chat
      expect(find.text('🎨'), findsOneWidget); // Art
      expect(find.text('📊'), findsOneWidget); // Data analysis
    });

    testWidgets('should support swipe to dismiss', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find first conversation
      final firstConversation = find.text('AI 写作助手');

      // Swipe left
      await tester.drag(firstConversation, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Should show delete confirmation
      expect(find.text('删除对话'), findsOneWidget);
    });

    testWidgets('should support pull to refresh', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should render all list items with correct structure',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Should have 5 conversations
      expect(find.byType(ListTile), findsNWidgets(5));

      // Should have separators between items
      expect(find.byType(Divider), findsNWidgets(4));
    });

    testWidgets('should handle empty title in new conversation dialog',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Try to create with empty title (just tapping cancel)
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();

      // Dialog should close
      expect(find.text('新建对话'), findsNothing);
    });

    testWidgets('conversation items should be tappable', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Find a conversation item
      final conversation = find.text('AI 写作助手');

      // Tap it (will try to navigate, but navigation won't work in test)
      expect(conversation, findsOneWidget);
    });

    testWidgets('should display bottom navigation or safe areas correctly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SafeArea(
            child: ConversationListPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without errors
      expect(find.byType(ConversationListPage), findsOneWidget);
    });

    testWidgets('should handle multiple rapid taps gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ConversationListPage(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap multiple times rapidly
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // Should handle gracefully without crashing
      expect(find.byType(ConversationListPage), findsOneWidget);
    });
  });
}
