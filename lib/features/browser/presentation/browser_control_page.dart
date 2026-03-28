import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../../theme/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 浏览器控制状态
enum BrowserStatus {
  disconnected('disconnected', '未连接', AppColors.textTertiary),
  connecting('connecting', '连接中', AppColors.warning),
  connected('connected', '已连接', AppColors.success),
  error('error', '错误', AppColors.error);

  final String value;
  final String label;
  final Color color;

  const BrowserStatus(this.value, this.label, this.color);
}

/// 浏览器导航历史项
class NavigationItem {
  final String title;
  final String url;
  final DateTime timestamp;

  NavigationItem({
    required this.title,
    required this.url,
    required this.timestamp,
  });
}

/// 远程浏览器控制页面
class BrowserControlPage extends ConsumerStatefulWidget {
  const BrowserControlPage({super.key});

  @override
  ConsumerState<BrowserControlPage> createState() => _BrowserControlPageState();
}

class _BrowserControlPageState extends ConsumerState<BrowserControlPage> {
  final TextEditingController _urlController = TextEditingController();
  final List<NavigationItem> _history = [];
  
  BrowserStatus _status = BrowserStatus.disconnected;
  String _currentUrl = 'https://example.com';
  String _pageTitle = '示例网站';
  Uint8List? _screenshot;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('浏览器控制'),
        actions: [
          // 连接状态指示器
          _buildStatusIndicator(),
          const SizedBox(width: AppSpace.s3),
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          // URL 栏
          _buildUrlBar(),

          // 截图显示区域
          Expanded(
            child: _buildScreenshotArea(),
          ),

          // 控制按钮区域
          _buildControlPanel(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s3,
        vertical: AppSpace.s2,
      ),
      decoration: BoxDecoration(
        color: _status.color.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusFull,
        border: Border.all(color: _status.color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _status.label,
            style: TextStyle(
              fontSize: 12,
              color: _status.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // 后退按钮
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _canGoBack() ? _goBack : null,
            color: _canGoBack() ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          // 前进按钮
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _canGoForward() ? _goForward : null,
            color: _canGoForward() ? AppColors.textPrimary : AppColors.textTertiary,
          ),
          // 主页按钮
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: _goHome,
          ),
          // URL 输入框
          Expanded(
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: '输入网址...',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.radiusMD,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.s3,
                  vertical: AppSpace.s2,
                ),
              ),
              onSubmitted: (url) => _navigate(url),
            ),
          ),
          // 跳转按钮
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: () => _navigate(_urlController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenshotArea() {
    return Container(
      color: AppColors.background,
      child: _status == BrowserStatus.disconnected
          ? _buildDisconnectedState()
          : _status == BrowserStatus.connecting
              ? _buildConnectingState()
              : _status == BrowserStatus.error
                  ? _buildErrorState()
                  : _buildConnectedState(),
    );
  }

  Widget _buildDisconnectedState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: AppSpace.s4),
          const Text(
            '浏览器未连接',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          const Text(
            '点击下方按钮连接到远程浏览器',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpace.s4),
          Text(
            '正在连接...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpace.s4),
          const Text(
            '连接失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpace.s4),
          FilledButton.icon(
            onPressed: _connect,
            icon: const Icon(Icons.refresh),
            label: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedState() {
    return Column(
      children: [
        // 页面标题和URL信息
        Container(
          padding: const EdgeInsets.all(AppSpace.s3),
          color: AppColors.surface,
          child: Row(
            children: [
              const Icon(
                Icons.language,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _pageTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _currentUrl,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // 截图区域
        Expanded(
          child: _screenshot != null
              ? InteractiveViewer(
                  child: Image.memory(
                    _screenshot!,
                    fit: BoxFit.contain,
                  ),
                )
              : Container(
                  color: AppColors.background,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: AppSpace.s4),
                        Text(
                          '加载中...',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSpace.s4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // 主要控制按钮
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: Icons.screenshot,
                  label: '截图',
                  onPressed: _status == BrowserStatus.connected ? _takeScreenshot : null,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.refresh,
                  label: '刷新',
                  onPressed: _status == BrowserStatus.connected ? _reload : null,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.stop,
                  label: '停止',
                  onPressed: _status == BrowserStatus.connected ? _stop : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s3),
          // 次要控制按钮
          Row(
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: Icons.touch_app,
                  label: '点击',
                  onPressed: _status == BrowserStatus.connected ? _showClickDialog : null,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.keyboard,
                  label: '输入',
                  onPressed: _status == BrowserStatus.connected ? _showInputDialog : null,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.unfold_more,
                  label: '滚动',
                  onPressed: _status == BrowserStatus.connected ? _showScrollDialog : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s3),
          // 连接/断开按钮
          FilledButton.tonal(
            onPressed: _status == BrowserStatus.connected ? _disconnect : _connect,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              backgroundColor: _status == BrowserStatus.connected
                  ? AppColors.error.withValues(alpha: 0.1)
                  : null,
            ),
            child: Text(
              _status == BrowserStatus.connected ? '断开连接' : '连接浏览器',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        foregroundColor: onPressed != null ? AppColors.textPrimary : AppColors.textTertiary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _connect() {
    setState(() => _status = BrowserStatus.connecting);

    // 模拟连接
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _status = BrowserStatus.connected;
          _urlController.text = _currentUrl;
        });
      }
    });
  }

  void _disconnect() {
    setState(() {
      _status = BrowserStatus.disconnected;
      _screenshot = null;
    });
  }

  void _navigate(String url) {
    if (url.isEmpty) return;

    // 添加协议前缀
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    setState(() {
      _currentUrl = url;
      _history.add(NavigationItem(
        title: _pageTitle,
        url: url,
        timestamp: DateTime.now(),
      ));
      _screenshot = null; // 清除截图，触发重新加载
    });

    // 模拟加载
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _pageTitle = '网页 - ${Uri.parse(url).host}';
        });
      }
    });
  }

  void _goBack() {
    if (_history.isNotEmpty) {
      final item = _history.removeLast();
      setState(() {
        _currentUrl = item.url;
        _pageTitle = item.title;
        _urlController.text = item.url;
      });
    }
  }

  void _goForward() {
    // TODO: 实现前进功能
  }

  void _goHome() {
    _navigate('https://www.google.com');
  }

  bool _canGoBack() => _history.isNotEmpty;
  bool _canGoForward() => false;

  void _reload() {
    setState(() => _screenshot = null);
    // 模拟重新加载
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        // 模拟截图
        _takeScreenshot();
      }
    });
  }

  void _stop() {
    // TODO: 实现停止加载功能
  }

  void _refresh() {
    if (_status == BrowserStatus.connected) {
      _reload();
    }
  }

  void _takeScreenshot() {
    // 模拟截图
    setState(() {
      // 这里应该是实际的截图数据
      // _screenshot = await GatewayService.takeScreenshot();
    });
  }

  void _showClickDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('点击元素'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'CSS 选择器或坐标 (x,y)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('点击指令已发送')),
              );
            },
            child: const Text('执行'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('输入文本'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: '输入要发送的文本',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('输入指令已发送')),
              );
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  void _showScrollDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('滚动页面'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('向上滚动'),
              trailing: const Icon(Icons.arrow_upward),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('向上滚动')),
                );
              },
            ),
            ListTile(
              title: const Text('向下滚动'),
              trailing: const Icon(Icons.arrow_downward),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('向下滚动')),
                );
              },
            ),
            ListTile(
              title: const Text('滚动到顶部'),
              trailing: const Icon(Icons.vertical_align_top),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('滚动到顶部')),
                );
              },
            ),
            ListTile(
              title: const Text('滚动到底部'),
              trailing: const Icon(Icons.vertical_align_bottom),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('滚动到底部')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
