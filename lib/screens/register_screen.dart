import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/language_switcher.dart';
import 'home_screen.dart';

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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
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
                                width: 120,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _captchaImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          _captchaImage!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            print('图片显示错误: $error');
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                color: Colors.red,
                                                size: 24,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : _captchaError
                                        ? const Center(
                                            child: Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 24,
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.clickToRefreshCaptcha,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
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