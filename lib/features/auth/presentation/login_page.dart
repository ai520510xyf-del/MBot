import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/theme.dart';
import 'wechat_bind_page.dart';

/// 登录状态
enum LoginStep { phoneInput, verificationCode }

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
  int _countdown = 0;

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

  void _sendCode() {
    if (_formKey.currentState?.validate() ?? false) {
      // Send SMS verification code via API
      _startCountdown();
      setState(() {
        _currentStep = LoginStep.verificationCode;
      });
    }
  }

  void _verifyAndLogin() {
    if (_codeController.text.length == 6) {
      setState(() {
        _isVerifying = true;
      });

      // Verify SMS code via API
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isVerifying = false;
          });
          // 登录成功，跳转到主页
          GoRouter.of(context).go('/');
        }
      });
    }
  }

  void _backToPhoneInput() {
    setState(() {
      _currentStep = LoginStep.phoneInput;
      _codeController.clear();
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
                      hintText: '请输入手机号码',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入手机号码';
                      }
                      if (value.length != 11) {
                        return '请输入正确的手机号码';
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
                        (_agreeToTerms && _phoneController.text.length == 11)
                        ? _sendCode
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                    ),
                    child: const Text('获取验证码', style: TextStyle(fontSize: 16)),
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
                            '已发送至 +86 $_phoneController',
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
                          _countdown > 0 ? '$_countdown秒后重新发送' : '重新发送验证码',
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
                                      Colors.white,
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
