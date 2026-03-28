import 'package:flutter/material.dart';
import '../../../../core/models/conversation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/theme.dart';
import '../../../../core/repositories/conversation_repository.dart';

/// 对话列表页
class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() =>
      _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  @override
  Widget build(BuildContext context) {
    final conversationRepo = ref.watch(conversationRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('MBot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showNewConversationDialog(context);
            },
            tooltip: '新建对话',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        child: StreamBuilder<List<ConversationData>>(
          stream: conversationRepo.watchAll(),
          builder: (context, snapshot) {
            final conversations = snapshot.data ?? [];
            
            if (conversations.isEmpty && snapshot.connectionState == ConnectionState.active) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 64, color: DarkColors.textTertiary),
                    SizedBox(height: AppSpace.s4),
                    Text('暂无对话', style: TextStyle(color: DarkColors.textSecondary)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
              itemCount: conversations.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: AppSpace.s4 + 48 + AppSpace.s3,
                color: DarkColors.border,
              ),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return _buildConversationItem(conversation, index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildConversationItem(ConversationData conversation, int index) {
    return Dismissible(
      key: ValueKey(conversation.id),
      direction: DismissDirection.endToStart,
      background: _buildSwipeBackground(),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(conversation);
      },
      onDismissed: (direction) {
        _handleDeleteConversation(conversation, index);
      },
      child: Semantics(
        button: true,
        enabled: true,
        label: '对话：${conversation.title}',
        hint: '点击打开对话，长按显示更多选项',
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DarkColors.surfaceHighlight,
              borderRadius: AppRadius.radiusMD,
            ),
            child: Center(
              child: Text(
                '🤖',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            conversation.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: DarkColors.textPrimary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                '点击继续对话',
                style: const TextStyle(
                  fontSize: 14,
                  color: DarkColors.textSecondary,
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
                _formatTime(conversation.updatedAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: DarkColors.textTertiary,
                ),
              ),
            ],
          ),
          onTap: () => context.go('/chat/${conversation.id}'),
          onLongPress: () {
            _showConversationOptions(context, conversation, index);
          },
        ),
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
          Icon(Icons.delete_outline, color: DarkColors.surface, size: 28),
          SizedBox(height: 4),
          Text('删除', style: TextStyle(color: DarkColors.surface, fontSize: 12)),
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
    ConversationData conversation,
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

  void _showRenameDialog(ConversationData conversation, int index) {
    final controller = TextEditingController(text: conversation.title);

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
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final updated = conversation.copyWith(title: controller.text.trim());
                await ref.read(conversationRepositoryProvider).update(updated);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmDialog(
    ConversationData conversation,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('删除对话'),
            content: Text('确定要删除「${conversation.title}」吗？此操作不可恢复。'),
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

  void _handleDeleteConversation(ConversationData conversation, int index) async {
    await ref.read(conversationRepositoryProvider).delete(conversation.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已删除「${conversation.title}」'),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    // Refresh is handled by StreamBuilder automatically
    await ref.read(conversationRepositoryProvider).getAll();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${time.month}月${time.day}日';
    }
  }
}
