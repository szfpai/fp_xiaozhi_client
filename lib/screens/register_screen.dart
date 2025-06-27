import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/language_switcher.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _captchaController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Uint8List? _captchaImage;
  bool _captchaError = false;

  @override
  void initState() {
    super.initState();
    // 使用addPostFrameCallback确保在Widget完全构建后再调用验证码接口
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateCaptcha();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _generateCaptcha() async {
    try {
      setState(() {
        _captchaError = false;
      });
      
      final l10n = AppLocalizations.of(context)!;
      final authService = context.read<AuthService>();
      final captchaImage = await authService.generateCaptcha(
        getCaptchaFailed: l10n.getCaptchaFailed,
      );
      
      if (mounted) {
        print('验证码图片获取成功: ${captchaImage.length} bytes');
        setState(() {
          _captchaImage = captchaImage;
          _captchaError = false;
        });
      }
    } catch (e) {
      print('生成验证码失败: $e');
      if (mounted) {
        setState(() {
          _captchaError = true;
        });
        // 显示错误提示
        final l10n = AppLocalizations.of(context)!;
        Fluttertoast.showToast(
          msg: l10n.getCaptchaFailed,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;
    final result = await context.read<AuthService>().register(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      captcha: _captchaController.text.trim(),
      pleaseGenerateCaptchaFirst: l10n.pleaseGenerateCaptchaFirst,
      registrationSuccess: l10n.registrationSuccess,
      networkError: l10n.networkError,
      registrationFailedGeneric: l10n.registrationFailedGeneric,
    );

    if (result['success'] && mounted) {
      // 显示注册成功提示
      Fluttertoast.showToast(
        msg: '🎉 注册成功！\n请使用您的用户名和密码登录',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
      
      // 延迟跳转，让用户看到成功提示
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // 跳转到登录界面
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      });
    } else if (mounted) {
      Fluttertoast.showToast(
        msg: result['message'] ?? l10n.registrationFailed,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      // 刷新验证码
      _generateCaptcha();
      _captchaController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.userRegistration),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: const [
          LanguageSwitcher(),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题
                        const Icon(
                          Icons.person_add,
                          size: 60,
                          color: Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.createNewAccount,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 用户名输入框
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: l10n.username,
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.pleaseEnterUsername;
                            }
                            if (value.length < 3) {
                              return l10n.usernameTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 密码输入框
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: l10n.password,
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseEnterPassword;
                            }
                            if (value.length < 6) {
                              return l10n.passwordTooShort;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 确认密码输入框
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: l10n.confirmPassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.pleaseConfirmPassword;
                            }
                            if (value != _passwordController.text) {
                              return l10n.passwordsDoNotMatch;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // 验证码输入框和图片
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _captchaController,
                                decoration: InputDecoration(
                                  labelText: l10n.captcha,
                                  prefixIcon: const Icon(Icons.security),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.pleaseEnterCaptcha;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: _generateCaptcha,
                              child: Container(
                                width: 150, // 固定宽度
                                height: 60,  // 固定高度
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _captchaError ? Colors.red : Colors.grey[400]!,
                                    width: _captchaError ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[50],
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: _captchaImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            Image.memory(
                                              _captchaImage!,
                                              fit: BoxFit.contain, // 保持比例，完整显示
                                              width: 150,
                                              height: 60,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('验证码图片显示错误: $error');
                                                return Container(
                                                  width: 150,
                                                  height: 60,
                                                  decoration: BoxDecoration(
                                                    color: Colors.red[50],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(
                                                          Icons.broken_image,
                                                          color: Colors.red,
                                                          size: 20,
                                                        ),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          '图片加载失败',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            // 添加刷新提示覆盖层
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: Container(
                                                padding: const EdgeInsets.all(2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Icon(
                                                  Icons.refresh,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : _captchaError
                                        ? Container(
                                            width: 150,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 20,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '获取失败',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 150,
                                            height: 60,
                                            child: const Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    '加载中...',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '点击图片刷新验证码',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            if (_captchaImage != null)
                              Text(
                                '${_captchaImage!.length} bytes',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 注册按钮
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authService.isLoading ? null : _register,
                                child: authService.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        l10n.register,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),

                        // 返回登录链接
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.alreadyHaveAccount),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                l10n.backToLogin,
                                style: const TextStyle(
                                  color: Color(0xFF667EEA),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 