import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/theme.dart';

/// 对话列表页
class ConversationListPage extends StatelessWidget {
  const ConversationListPage({super.key});

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
            },
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.s2),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: AppSpace.s4 + 48 + AppSpace.s3,
          color: AppColors.border,
        ),
        itemBuilder: (context, index) {
          // 占位数据
          final items = [
            ('🤖', 'AI 写作助手', '帮我写一封邮件给客户...', '10:30'),
            ('💻', 'AI 编程助手', '这段代码为什么报错...', '09:15'),
            ('💬', '闲聊', '今天天气怎么样...', '昨天'),
            ('🎨', 'AI 绘画', '帮你生成一张精美图片...', '昨天'),
            ('📊', '数据分析', '帮我分析这份数据...', '周一'),
          ];
          final (emoji, title, msg, time) = items[index];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceHighlight,
                borderRadius: AppRadius.radiusMD,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              msg,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textTertiary,
              ),
            ),
            onTap: () => context.go('/chat/$index'),
          );
        },
      ),
    );
  }
}
