import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/theme.dart';

/// 对话列表页
class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  final List<Map<String, dynamic>> _mockConversations = [
    {
      'id': '1',
      'emoji': '🤖',
      'title': 'AI 写作助手',
      'lastMessage': '帮我写一封邮件给客户，表达感谢并期待下次合作...',
      'time': '10:30',
      'updatedAt': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'id': '2',
      'emoji': '💻',
      'title': 'AI 编程助手',
      'lastMessage': '这段代码为什么报错？提示空指针异常...',
      'time': '09:15',
      'updatedAt': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': '3',
      'emoji': '💬',
      'title': '闲聊',
      'lastMessage': '今天天气怎么样？适合外出吗...',
      'time': '昨天',
      'updatedAt': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'id': '4',
      'emoji': '🎨',
      'title': 'AI 绘画',
      'lastMessage': '帮我生成一张精美的日落风景图...',
      'time': '昨天',
      'updatedAt': DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    },
    {
      'id': '5',
      'emoji': '📊',
      'title': '数据分析',
      'lastMessage': '帮我分析这份数据报表，提取关键指标...',
      'time': '周一',
      'updatedAt': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MBot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: 创建新对话
              _showNewConversationDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
          itemCount: _mockConversations.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            indent: AppSpace.s4 + 48 + AppSpace.s3,
            color: AppColors.border,
          ),
          itemBuilder: (context, index) {
            final conversation = _mockConversations[index];
            return _buildConversationItem(conversation, index);
          },
        ),
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation, int index) {
    return Dismissible(
      key: Key(conversation['id']),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(conversation);
      },
      onDismissed: (direction) {
        _handleDeleteConversation(conversation, index);
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighlight,
            borderRadius: AppRadius.radiusMD,
          ),
          child: Center(
            child: Text(
              conversation['emoji'],
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Text(
          conversation['title'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation['lastMessage'],
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              conversation['time'],
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusXS,
              ),
              child: Text(
                _formatMessageCount(conversation),
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () => context.go('/chat/${conversation['id']}'),
        onLongPress: () {
          _showConversationOptions(context, conversation, index);
        },
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: AppRadius.radiusMD,
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_outline, color: Colors.white, size: 28),
          SizedBox(height: 4),
          Text('删除', style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  void _showNewConversationDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建对话'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            hintText: '对话标题',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                // TODO: 创建新对话逻辑
                context.go('/chat/new');
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showConversationOptions(
    BuildContext context,
    Map<String, dynamic> conversation,
    int index,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('重命名'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(conversation, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.push_pin_outlined),
              title: const Text('置顶'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已置顶对话')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.mark_email_read_outlined),
              title: const Text('标为已读'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已标为已读')));
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text('删除', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                final confirmed = await _showDeleteConfirmDialog(conversation);
                if (confirmed) {
                  _handleDeleteConversation(conversation, index);
                }
              },
            ),
            const SizedBox(height: AppSpace.s4),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(Map<String, dynamic> conversation, int index) {
    final controller = TextEditingController(text: conversation['title']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名对话'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _mockConversations[index]['title'] = controller.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(
    Map<String, dynamic> conversation,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除对话'),
            content: Text('确定要删除「${conversation['title']}」吗？此操作不可恢复。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('删除'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _handleDeleteConversation(Map<String, dynamic> conversation, int index) {
    setState(() {
      _mockConversations.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已删除「${conversation['title']}」'),
        action: SnackBarAction(
          label: '撤销',
          textColor: AppColors.primary,
          onPressed: () {
            setState(() {
              _mockConversations.insert(index, conversation);
            });
          },
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // 模拟刷新
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {}
  }

  String _formatMessageCount(Map<String, dynamic> conversation) {
    // 模拟未读消息数
    final count = (int.parse(conversation['id']) * 2) % 10;
    return count > 0 ? '$count' : '';
  }
}
