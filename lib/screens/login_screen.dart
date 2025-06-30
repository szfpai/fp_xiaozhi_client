import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:typed_data';
import '../l10n/app_localizations.dart';
import '../services/auth_service.dart';
import '../widgets/language_switcher.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool showWelcome;
  const LoginScreen({super.key, this.showWelcome = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  bool _obscurePassword = true;
  bool _showWelcomeMessage = false; // 是否显示欢迎消息
  Uint8List? _captchaImage;
  bool _captchaError = false;
  String? _loginErrorMessage; // 登录错误消息
  bool _showLoginError = false; // 是否显示登录错误

  @override
  void initState() {
    super.initState();
    // 检查登录状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthService>().checkLoginStatus().then((_) {
        if (context.read<AuthService>().isLoggedIn && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          // 显示欢迎消息（如果是从注册页面跳转过来的）
          setState(() {
            _showWelcomeMessage = widget.showWelcome;
          });
          
          // 3秒后隐藏欢迎消息
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showWelcomeMessage = false;
              });
            }
          });
          
          // 自动生成验证码
          _generateCaptcha();
        }
      });
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // 清除之前的错误状态
    setState(() {
      _showLoginError = false;
      _loginErrorMessage = null;
    });

    final l10n = AppLocalizations.of(context)!;
    final result = await context.read<AuthService>().login(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      captcha: _captchaController.text.trim(),
      loginSuccess: l10n.loginSuccess,
      networkError: l10n.networkError,
      loginFailedGeneric: l10n.loginFailed,
    );

    if (result['success'] && mounted) {
      // 登录成功，跳转到首页
      print('登录成功，准备跳转到首页');
      
      // 打印缓存状态调试信息
      await context.read<AuthService>().debugPrintCacheStatus();
      
      // 显示成功提示
      Fluttertoast.showToast(
        msg: result['message'] ?? l10n.loginSuccess,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
      );
      
      // 延迟跳转，让用户看到成功提示
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      });
    } else if (mounted) {
      // 登录失败，停留在登录页面
      final errorMessage = result['message'] ?? l10n.loginFailed;
      
      // 设置错误状态
      setState(() {
        _showLoginError = true;
        _loginErrorMessage = errorMessage;
      });
      
      // 显示错误提示
      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
      
      // 刷新验证码
      _generateCaptcha();
      _captchaController.clear();
      
      // 5秒后自动隐藏错误消息
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showLoginError = false;
            _loginErrorMessage = null;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
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
                        // Logo和标题
                        const Icon(
                          Icons.account_circle,
                          size: 80,
                          color: Color(0xFF667EEA),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.appTitle,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.welcomeBack,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 欢迎消息（注册成功后显示）
                        if (_showWelcomeMessage)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              border: Border.all(color: Colors.green[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '欢迎！您的账户已创建成功，请登录',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // 登录错误消息
                        if (_showLoginError && _loginErrorMessage != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red[200]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _loginErrorMessage!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

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

                        // 登录按钮
                        Consumer<AuthService>(
                          builder: (context, authService, child) {
                            return SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authService.isLoading ? null : _login,
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
                                        l10n.login,
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

                        // 注册链接
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.noAccountYet),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.registerNow,
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