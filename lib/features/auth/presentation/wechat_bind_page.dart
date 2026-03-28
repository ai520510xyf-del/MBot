import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../theme/theme.dart';
import '../../../../core/services/mock_api_service.dart';
import 'providers/auth_provider.dart';
import 'login_page.dart';

/// 扫码状态
enum ScanStatus {
  /// 等待扫码
  waiting,
  /// 已扫码，等待确认
  scanned,
  /// 已确认，登录成功
  confirmed,
  /// 二维码已过期
  expired,
  /// 发生错误
  error,
}

/// 微信扫码绑定页面
class WechatBindPage extends ConsumerStatefulWidget {
  const WechatBindPage({super.key});

  @override
  ConsumerState<WechatBindPage> createState() => _WechatBindPageState();
}

class _WechatBindPageState extends ConsumerState<WechatBindPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // 二维码相关状态
  String? _qrCodeUrl;
  String? _qrCodeId;
  ScanStatus _scanStatus = ScanStatus.waiting;
  String? _errorMessage;

  // 轮询定时器
  Timer? _pollTimer;
  // 二维码过期倒计时
  int _expireCountdown = 0;
  Timer? _expireTimer;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _fetchQrCode();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pollTimer?.cancel();
    _expireTimer?.cancel();
    super.dispose();
  }

  /// 获取微信二维码
  Future<void> _fetchQrCode() async {
    setState(() {
      _isLoading = true;
      _scanStatus = ScanStatus.waiting;
      _errorMessage = null;
    });

    try {
      // 获取演示模式状态
      final demoMode = demoModeNotifier.value;

      if (demoMode) {
        // 演示模式：使用 Mock API
        final result = await mockApiService.getWechatQrCode();

        if (!mounted) return;

        if (result['success'] == true) {
          setState(() {
            _qrCodeUrl = result['qrCodeUrl'] as String;
            _qrCodeId = result['qrCodeId'] as String;
            _isLoading = false;
            _expireCountdown = result['expireSeconds'] as int;
          });

          _startExpireCountdown();
          _startPollingScanStatus();
        } else {
          setState(() {
            _isLoading = false;
            _scanStatus = ScanStatus.error;
            _errorMessage = result['message'] ?? '获取二维码失败';
          });
        }
      } else {
        // 真实 API 模式（暂未实现）
        // TODO: 调用真实 API 获取微信二维码
        // GET /api/auth/wechat/qrcode
        // Response: { "qrCodeUrl": "...", "qrCodeId": "...", "expireSeconds": 300 }
        await Future.delayed(const Duration(milliseconds: 800));

        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _scanStatus = ScanStatus.error;
          _errorMessage = '真实 API 尚未配置，请开启演示模式';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _scanStatus = ScanStatus.error;
          _errorMessage = '获取二维码失败: $e';
        });
      }
    }
  }

  /// 开始过期倒计时
  void _startExpireCountdown() {
    _expireTimer?.cancel();
    _expireTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _expireCountdown--;
      });

      if (_expireCountdown <= 0) {
        timer.cancel();
        setState(() {
          _scanStatus = ScanStatus.expired;
        });
        _pollTimer?.cancel();
      }
    });
  }

  /// 开始轮询扫码状态
  void _startPollingScanStatus() {
    _pollTimer?.cancel();

    if (_qrCodeId == null) return;

    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      // 如果已经不在等待状态，停止轮询
      if (_scanStatus != ScanStatus.waiting && _scanStatus != ScanStatus.scanned) {
        timer.cancel();
        return;
      }

      try {
        // 获取演示模式状态
        final demoMode = demoModeNotifier.value;

        if (demoMode && _qrCodeId != null) {
          // 演示模式：使用 Mock API 检查状态
          final result = await mockApiService.checkWechatScanStatus(_qrCodeId!);

          if (!mounted) return;

          if (result['success'] == true) {
            final status = result['status'] as String;

            if (status == 'confirmed') {
              // 已确认登录
              timer.cancel();
              await _handleScanConfirmed();
            } else if (status == 'scanned') {
              // 已扫码，等待确认
              setState(() {
                _scanStatus = ScanStatus.scanned;
              });
            } else if (status == 'expired') {
              // 二维码过期
              timer.cancel();
              setState(() {
                _scanStatus = ScanStatus.expired;
              });
            }
          }
        } else {
          // 真实 API 模式（暂未实现）
          // TODO: 调用真实 API 检查扫码状态
          // GET /api/auth/wechat/status?qrCodeId=xxx
          // Response: { "status": "waiting|scanned|confirmed", "userId": "...", "token": "..." }
        }
      } catch (e) {
        debugPrint('轮询扫码状态失败: $e');
      }
    });
  }

  /// 处理扫码确认
  Future<void> _handleScanConfirmed() async {
    _pollTimer?.cancel();
    _expireTimer?.cancel();

    setState(() {
      _scanStatus = ScanStatus.confirmed;
    });

    try {
      // 调用 auth_provider 完成登录
      await ref.read(authProvider.notifier).loginWithWechat(qrCode: _qrCodeId ?? '');

      if (mounted) {
        // 登录成功，跳转到主页
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _scanStatus = ScanStatus.error;
          _errorMessage = '登录失败: $e';
        });
      }
    }
  }

  /// 模拟扫码确认（测试用，仅演示模式可用）
  void _simulateScanConfirm() {
    final demoMode = demoModeNotifier.value;
    if (!demoMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先开启演示模式')),
      );
      return;
    }

    if (_qrCodeId != null) {
      mockApiService.confirmWechatScan(_qrCodeId!);
    }
  }

  /// 刷新二维码
  Future<void> _refreshQrCode() async {
    _pollTimer?.cancel();
    _expireTimer?.cancel();
    await _fetchQrCode();
  }

  String _formatCountdown(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // 返回时取消定时器
        if (didPop) {
          _pollTimer?.cancel();
          _expireTimer?.cancel();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('微信扫码绑定'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
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
                    // QR 码内容
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_errorMessage != null || _scanStatus == ScanStatus.error)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: AppSpace.s3),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                              child: Text(
                                _errorMessage ?? '获取二维码失败',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_scanStatus == ScanStatus.expired)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_off_outlined,
                              size: 64,
                              color: AppColors.warning,
                            ),
                            const SizedBox(height: AppSpace.s3),
                            const Text(
                              '二维码已过期',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: AppSpace.s3),
                            FilledButton.icon(
                              onPressed: _refreshQrCode,
                              icon: const Icon(Icons.refresh),
                              label: const Text('刷新二维码'),
                            ),
                          ],
                        ),
                      )
                    else if (_scanStatus == ScanStatus.confirmed)
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              size: 64,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: AppSpace.s3),
                            const Text(
                              '登录成功！',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpace.s2),
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(AppColors.success),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      // 显示二维码图片
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 使用 qr_flutter 生成真实二维码
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: AppRadius.radiusMD,
                              ),
                              child: Center(
                                child: _qrCodeUrl != null
                                    ? QrImageView(
                                        data: _qrCodeUrl!,
                                        version: QrVersions.auto,
                                        size: 180,
                                        backgroundColor: Colors.white,
                                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                                        eyeStyle: const QrEyeStyle(
                                          eyeShape: QrEyeShape.square,
                                          color: Colors.black,
                                        ),
                                        dataModuleStyle: const QrDataModuleStyle(
                                          dataModuleShape: QrDataModuleShape.square,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const CircularProgressIndicator(),
                              ),
                            ),
                            const SizedBox(height: AppSpace.s2),
                            Text(
                              '有效期 ${_formatCountdown(_expireCountdown)}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // 扫描线动画（仅在等待状态显示）
                    if (_scanStatus == ScanStatus.waiting && !_isLoading)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: 20 + (240 * _animationController.value).clamp(0.0, 240.0),
                            left: 20,
                            right: 20,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.success,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    // 四角边框
                    if (!_isLoading && _scanStatus == ScanStatus.waiting)
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
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Text(
                      _getStatusText(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (_scanStatus == ScanStatus.waiting)
                    TextButton.icon(
                      onPressed: _refreshQrCode,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('刷新'),
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

            // 测试用按钮（模拟扫码确认）
            if (_scanStatus == ScanStatus.waiting)
              OutlinedButton.icon(
                onPressed: _simulateScanConfirm,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('模拟扫码确认（测试用）'),
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
    ),
    );
  }

  Color _getStatusColor() {
    switch (_scanStatus) {
      case ScanStatus.waiting:
        return AppColors.success;
      case ScanStatus.scanned:
        return AppColors.info;
      case ScanStatus.confirmed:
        return AppColors.success;
      case ScanStatus.expired:
        return AppColors.warning;
      case ScanStatus.error:
        return AppColors.error;
    }
  }

  String _getStatusText() {
    switch (_scanStatus) {
      case ScanStatus.waiting:
        return '等待扫码...';
      case ScanStatus.scanned:
        return '已扫码，请在微信中确认...';
      case ScanStatus.confirmed:
        return '登录成功！';
      case ScanStatus.expired:
        return '二维码已过期，请刷新';
      case ScanStatus.error:
        return _errorMessage ?? '发生错误';
    }
  }
}

/// QR 码边框绘制器
class _QRBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.success
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
