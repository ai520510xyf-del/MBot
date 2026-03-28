import 'package:flutter/material.dart';
import '../../../../theme/theme.dart';

/// 微信扫码绑定页面
class WechatBindPage extends StatefulWidget {
  const WechatBindPage({super.key});

  @override
  State<WechatBindPage> createState() => _WechatBindPageState();
}

class _WechatBindPageState extends State<WechatBindPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });
    if (_isScanning) {
      _animationController.repeat();
    } else {
      _animationController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('微信扫码绑定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpace.s6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 说明卡片
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusLG,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: AppRadius.radiusMD,
                        ),
                        child: const Icon(
                          Icons.wechat_outlined,
                          color: AppColors.success,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s3),
                      const Expanded(
                        child: Text(
                          '使用微信扫码快速绑定',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s3),
                  const Text(
                    '打开微信扫描下方二维码，即可快速绑定您的微信账号，实现微信内直接与 AI 对话。',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s6),

            // QR 码容器
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.radiusLG,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // QR 码占位图
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2_outlined,
                            size: 200,
                            color: AppColors.surface.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: AppSpace.s2),
                          const Text(
                            'QR Code Placeholder',
                            style: TextStyle(
                              color: AppColors.surface,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 扫描线动画
                    if (_isScanning)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top:
                                20 +
                                (240 * _animationController.value).clamp(
                                  0.0,
                                  240.0,
                                ),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.primary,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.8,
                                    ),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // 四角边框
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: CustomPaint(painter: _QRBorderPainter()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpace.s6),

            // 状态信息
            Container(
              padding: const EdgeInsets.all(AppSpace.s4),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.radiusMD,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  const Expanded(
                    child: Text(
                      '等待扫码...',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _toggleScanning,
                    icon: Icon(
                      _isScanning ? Icons.pause : Icons.play_arrow,
                      size: 18,
                    ),
                    label: Text(_isScanning ? '暂停' : '继续'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s3,
                        vertical: AppSpace.s1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpace.s4),

            // 操作按钮
            OutlinedButton.icon(
              onPressed: () {
                // Refresh QR code from server
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('刷新二维码'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMD),
              ),
            ),

            const SizedBox(height: AppSpace.s4),

            // 帮助提示
            Container(
              padding: const EdgeInsets.all(AppSpace.s3),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.radiusMD,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: AppSpace.s2),
                  const Expanded(
                    child: Text(
                      '扫码后请在微信中确认绑定，绑定成功后即可使用。',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// QR 码边框绘制器
class _QRBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerSize = 20.0;

    // 左上角
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerSize)
        ..lineTo(0, 0)
        ..lineTo(cornerSize, 0),
      paint,
    );

    // 右上角
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerSize, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, cornerSize),
      paint,
    );

    // 右下角
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerSize)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width - cornerSize, size.height),
      paint,
    );

    // 左下角
    canvas.drawPath(
      Path()
        ..moveTo(cornerSize, size.height)
        ..lineTo(0, size.height)
        ..lineTo(0, size.height - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
