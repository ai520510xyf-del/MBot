import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/models/message.dart';
import '../../../../theme/theme.dart';

/// 聊天页
class ChatPage extends ConsumerStatefulWidget {
  final String chatId;

  const ChatPage({super.key, required this.chatId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  String _pendingAiContent = '';
  StreamSubscription? _responseSubscription;

  @override
  void initState() {
    super.initState();
    // 启动聊天服务监听
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatService = ref.read(chatServiceProvider);
      chatService.startListening();
      _subscribeToResponses(chatService);
    });
  }

  @override
  void dispose() {
    _responseSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _subscribeToResponses(ChatService chatService) {
    _responseSubscription = chatService.responseStream.listen((response) {
      if (mounted && response.sender == MessageSender.ai) {
        setState(() {
          _pendingAiContent = response.content;
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _pendingAiContent = '';
    });

    _textController.clear();

    try {
      await ref
          .read(chatServiceProvider)
          .sendMessage(conversationId: widget.chatId, content: content);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('发送失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageRepo = ref.watch(messageRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: 更多选项
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MessageData>>(
        stream: messageRepo.watchByConversation(widget.chatId),
        builder: (context, snapshot) {
          final messages = snapshot.data ?? [];

          return Column(
            children: [
              // 消息列表
              Expanded(child: _buildMessagesList(messages)),

              // 输入区域
              _buildInputArea(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList(List<MessageData> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s3,
      ),
      itemCount:
          messages.length +
          (_isSending || _pendingAiContent.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        // 显示待发送的 AI 消息
        if (index >= messages.length) {
          if (_pendingAiContent.isNotEmpty) {
            return _buildAiBubble(context, _pendingAiContent, isTyping: true);
          }
          return _buildAiBubble(context, '...', isTyping: true);
        }

        final message = messages[index];
        final content =
            message.content.isEmpty && message.sender == MessageSender.ai
            ? '...'
            : message.content;

        switch (message.sender) {
          case MessageSender.user:
            return _buildUserBubble(context, content);
          case MessageSender.ai:
            return _buildAiBubble(context, content);
          case MessageSender.tool:
            return _buildToolBubble(context, message);
        }
      },
    );
  }

  Widget _buildAiBubble(
    BuildContext context,
    String content, {
    bool isTyping = false,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s3,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.aiBubbleGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'MBot',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (isTyping) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(BuildContext context, String content) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s3,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.userBubbleGradient,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildToolBubble(BuildContext context, MessageData message) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s3,
          vertical: AppSpace.s2,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceHighlight,
          borderRadius: AppRadius.radiusMD,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.build,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    message.toolName ?? '工具调用',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                if (message.status == MessageStatus.pending) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (message.toolResult != null) ...[
              const SizedBox(height: AppSpace.s1),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpace.s2),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.radiusSM,
                ),
                child: Text(
                  message.toolResult!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpace.s2,
        right: AppSpace.s2,
        top: AppSpace.s2,
        bottom: MediaQuery.of(context).padding.bottom + AppSpace.s2,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.attach_file,
                color: AppColors.textTertiary,
              ),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
                enabled: !_isSending,
                decoration: InputDecoration(
                  hintText: '输入消息...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  filled: true,
                  fillColor: AppColors.surfaceHighlight,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s4,
                    vertical: AppSpace.s3,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.radiusFull,
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppSpace.s1),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: _isSending
                      ? AppColors.disabledGradient
                      : AppColors.primaryGradient,
                  borderRadius: AppRadius.radiusFull,
                  boxShadow: AppShadow.glow,
                ),
                child: Icon(
                  _isSending ? Icons.hourglass_empty : Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
