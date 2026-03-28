import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../theme/theme.dart';
import 'providers/auth_provider.dart';
import 'wechat_bind_page.dart';

/// 登录状态
enum LoginStep { phoneInput, verificationCode }

/// API 服务类 - 处理认证相关的网络请求
class AuthApiService {
  // TODO: 替换为真实的 API 地址
  static const String baseUrl = 'https://api.mbot.ai';
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  /// 发送短信验证码
  /// 返回 {success: bool, message: String}
  static Future<Map<String, dynamic>> sendSmsCode(String phone) async {
    try {
      final response = await _dio.post(
        '/api/auth/send-sms',
        data: {'phone': phone},
      );
      return {
        'success': response.data['success'] ?? true,
        'message': response.data['message'] ?? '验证码已发送，请注意查收',
      };
    } on DioException catch (e) {
      // 根据错误类型返回友好的错误信息
      String errorMessage;
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage = '网络连接超时，请检查网络后重试';
          break;
        case DioExceptionType.connectionError:
          errorMessage = '网络连接失败，请检查网络设置';
          break;
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode == 429) {
            errorMessage = '请求过于频繁，请 60 秒后重试';
          } else if (statusCode == 400) {
            errorMessage = e.response?.data['message'] ?? '手机号格式不正确';
          } else {
            errorMessage = '服务器错误 ($statusCode)，请稍后重试';
          }
          break;
        default:
          errorMessage = '发送验证码失败，请重试';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      return {'success': false, 'message': '发送验证码失败: $e'};
    }
  }
}

/// 登录页面
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LoginStep _currentStep = LoginStep.phoneInput;
  bool _agreeToTerms = false;
  bool _isVerifying = false;
  bool _isSendingCode = false;
  int _countdown = 0;
  String? _statusMessage; // 状态提示信息

  @override
  void initState() {
    super.initState();
    // 监听手机号输入变化，更新按钮状态
    _phoneController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        _countdown--;
      });
      return _countdown > 0;
    });
  }

  /// 显示状态提示
  void _showStatusMessage(String message, {bool isError = false}) {
    setState(() {
      _statusMessage = message;
    });
    // 3秒后自动清除提示
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _statusMessage = null;
        });
      }
    });
  }

  Future<void> _sendCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSendingCode = true;
        _statusMessage = null;
      });

      try {
        // 调用真实 API 发送验证码
        final result = await AuthApiService.sendSmsCode(_phoneController.text);

        if (!mounted) return;

        if (result['success'] == true) {
          // 发送成功
          _showStatusMessage(result['message'] ?? '验证码已发送');
          _startCountdown();
          setState(() {
            _currentStep = LoginStep.verificationCode;
          });
        } else {
          // 发送失败，显示错误信息
          _showStatusMessage(result['message'] ?? '发送验证码失败', isError: true);
        }
      } catch (e) {
        if (mounted) {
          _showStatusMessage('发送验证码失败: $e', isError: true);
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSendingCode = false;
          });
        }
      }
    }
  }

  Future<void> _verifyAndLogin() async {
    if (_codeController.text.length != 6) {
      _showStatusMessage('请输入 6 位验证码', isError: true);
      return;
    }

    setState(() {
      _isVerifying = true;
      _statusMessage = null;
    });

    try {
      // 调用 auth_provider 进行登录验证
      await ref.read(authProvider.notifier).loginWithPhone(
        phone: _phoneController.text,
        code: _codeController.text,
      );

      if (mounted) {
        // 登录成功，跳转到主页
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _showStatusMessage('登录失败: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  void _backToPhoneInput() {
    setState(() {
      _currentStep = LoginStep.phoneInput;
      _codeController.clear();
      _statusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.s6),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpace.s8),

                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🦞', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpace.s6),

                // 标题
                const Text(
                  '欢迎使用 MBot',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpace.s2),

                const Text(
                  '口袋里的 AI Agent',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpace.s10),

                // 状态提示信息
                if (_statusMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSpace.s4),
                    padding: const EdgeInsets.all(AppSpace.s3),
                    decoration: BoxDecoration(
                      color: _statusMessage!.contains('失败') || _statusMessage!.contains('错误')
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: AppRadius.radiusMD,
                      border: Border.all(
                        color: _statusMessage!.contains('失败') || _statusMessage!.contains('错误')
                            ? AppColors.error.withValues(alpha: 0.3)
                            : AppColors.success.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _statusMessage!.contains('失败') || _statusMessage!.contains('错误')
                              ? Icons.error_outline
                              : Icons.check_circle_outline,
                          size: 20,
                          color: _statusMessage!.contains('失败') || _statusMessage!.contains('错误')
                              ? AppColors.error
                              : AppColors.success,
                        ),
                        const SizedBox(width: AppSpace.s2),
                        Expanded(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: _statusMessage!.contains('失败') || _statusMessage!.contains('错误')
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_currentStep == LoginStep.phoneInput) ...[
                  // 手机号输入
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    decoration: const InputDecoration(
                      labelText: '手机号码',
                      hintText: '请输入 11 位手机号码',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入手机号码';
                      }
                      if (value.length != 11) {
                        return '请输入正确的 11 位手机号码';
                      }
                      // 简单的中国手机号格式校验
                      if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                        return '请输入有效的手机号码';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpace.s6),

                  // 服务条款
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _agreeToTerms = !_agreeToTerms;
                            });
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: '我已阅读并同意',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: '《用户协议》',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                TextSpan(text: '和'),
                                TextSpan(
                                  text: '《隐私政策》',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpace.s6),

                  // 发送验证码按钮
                  FilledButton(
                    onPressed:
                        (_agreeToTerms && _phoneController.text.length == 11 && !_isSendingCode)
                        ? _sendCode
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                    child: _isSendingCode
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('获取验证码', style: TextStyle(fontSize: 16)),
                  ),

                  const SizedBox(height: AppSpace.s4),

                  // 微信绑定入口
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WechatBindPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.wechat_outlined),
                    label: const Text('微信扫码登录'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.success,
                      side: const BorderSide(
                        color: AppColors.success,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                  ),
                ] else ...[
                  // 验证码输入
                  Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            '验证码已发送至 +86 ${_phoneController.text}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _backToPhoneInput,
                            child: const Text('修改号码'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpace.s4),

                      // PIN 输入
                      Pinput(
                        controller: _codeController,
                        length: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        defaultPinTheme: PinTheme(
                          width: 48,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.radiusMD,
                            border: Border.all(color: AppColors.border),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 48,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: AppRadius.radiusMD,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 48,
                          height: 56,
                          textStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: AppRadius.radiusMD,
                            border: Border.all(
                              color: AppColors.success,
                              width: 2,
                            ),
                          ),
                        ),
                        onCompleted: (pin) => _verifyAndLogin(),
                      ),

                      const SizedBox(height: AppSpace.s6),

                      // 重新发送倒计时
                      TextButton(
                        onPressed: _countdown > 0 ? null : _sendCode,
                        child: Text(
                          _countdown > 0 ? '$_countdown 秒后可重新发送' : '重新发送验证码',
                          style: TextStyle(
                            color: _countdown > 0
                                ? AppColors.textTertiary
                                : AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpace.s4),

                      // 登录按钮
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isVerifying ? null : _verifyAndLogin,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMD,
                            ),
                          ),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.surface,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpace.s4),

                // 底部提示
                Center(
                  child: Text(
                    '登录即表示同意《用户协议》和《隐私政策》',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
