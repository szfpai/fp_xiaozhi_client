// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get userRegistration => '用户注册';

  @override
  String get createNewAccount => '创建新账号';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get captcha => '验证码';

  @override
  String get register => '注册';

  @override
  String get backToLogin => '返回登录';

  @override
  String get alreadyHaveAccount => '已有账号？';

  @override
  String get clickToRefreshCaptcha => '点击图片刷新验证码';

  @override
  String get pleaseEnterUsername => '请输入用户名';

  @override
  String get usernameTooShort => '用户名长度至少3位';

  @override
  String get pleaseEnterEmail => '请输入邮箱';

  @override
  String get invalidEmail => '请输入有效的邮箱地址';

  @override
  String get pleaseEnterPassword => '请输入密码';

  @override
  String get passwordTooShort => '密码长度至少6位';

  @override
  String get pleaseConfirmPassword => '请确认密码';

  @override
  String get passwordsDoNotMatch => '两次输入的密码不一致';

  @override
  String get pleaseEnterCaptcha => '请输入验证码';

  @override
  String get registrationFailed => '注册失败，请检查输入信息或验证码';

  @override
  String get appTitle => '小智管家';

  @override
  String get welcomeBack => '欢迎回来';

  @override
  String get login => '登录';

  @override
  String get noAccountYet => '还没有账号？';

  @override
  String get registerNow => '立即注册';

  @override
  String get loginFailed => '登录失败，请检查用户名和密码';

  @override
  String get registrationFailedGeneric => '注册失败';

  @override
  String get pleaseGenerateCaptchaFirst => '请先生成验证码';

  @override
  String get networkError => '网络错误，请稍后重试';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get registrationSuccess => '注册成功';

  @override
  String get getCaptchaFailed => '获取验证码失败';
}
