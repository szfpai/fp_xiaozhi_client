// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get userRegistration => 'User Registration';

  @override
  String get createNewAccount => 'Create New Account';

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get captcha => 'Captcha';

  @override
  String get register => 'Register';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get clickToRefreshCaptcha => 'Click image to refresh captcha';

  @override
  String get pleaseEnterUsername => 'Please enter username';

  @override
  String get usernameTooShort => 'Username must be at least 3 characters';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get pleaseConfirmPassword => 'Please confirm password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get pleaseEnterCaptcha => 'Please enter captcha';

  @override
  String get registrationFailed =>
      'Registration failed, please check your input or captcha';

  @override
  String get appTitle => 'Xiaozhi Manager';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get login => 'Login';

  @override
  String get noAccountYet => 'Don\'t have an account yet?';

  @override
  String get registerNow => 'Register Now';

  @override
  String get loginFailed =>
      'Login failed, please check your username and password';

  @override
  String get registrationFailedGeneric => 'Registration failed';

  @override
  String get pleaseGenerateCaptchaFirst => 'Please generate captcha first';

  @override
  String get networkError => 'Network error, please try again later';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get registrationSuccess => 'Registration successful';

  @override
  String get getCaptchaFailed => 'Failed to get captcha';
}
