import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// Title for user registration screen
  ///
  /// In en, this message translates to:
  /// **'User Registration'**
  String get userRegistration;

  /// Title for creating new account
  ///
  /// In en, this message translates to:
  /// **'Create New Account'**
  String get createNewAccount;

  /// Label for username field
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Label for email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for confirm password field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Label for captcha field
  ///
  /// In en, this message translates to:
  /// **'Captcha'**
  String get captcha;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Back to login link text
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Text for existing account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Hint text for captcha refresh
  ///
  /// In en, this message translates to:
  /// **'Click image to refresh captcha'**
  String get clickToRefreshCaptcha;

  /// Validation message for empty username
  ///
  /// In en, this message translates to:
  /// **'Please enter username'**
  String get pleaseEnterUsername;

  /// Validation message for short username
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get usernameTooShort;

  /// Validation message for empty email
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// Validation message for invalid email
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// Validation message for empty password
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// Validation message for short password
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// Validation message for empty confirm password
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get pleaseConfirmPassword;

  /// Validation message for mismatched passwords
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Validation message for empty captcha
  ///
  /// In en, this message translates to:
  /// **'Please enter captcha'**
  String get pleaseEnterCaptcha;

  /// Error message for registration failure
  ///
  /// In en, this message translates to:
  /// **'Registration failed, please check your input or captcha'**
  String get registrationFailed;

  /// App title
  ///
  /// In en, this message translates to:
  /// **'Xiaozhi Manager'**
  String get appTitle;

  /// Welcome message on login screen
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Text for new user prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account yet?'**
  String get noAccountYet;

  /// Register now link text
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get registerNow;

  /// Error message for login failure
  ///
  /// In en, this message translates to:
  /// **'Login failed, please check your username and password'**
  String get loginFailed;

  /// Generic registration failure message
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailedGeneric;

  /// Message when captcha is not generated
  ///
  /// In en, this message translates to:
  /// **'Please generate captcha first'**
  String get pleaseGenerateCaptchaFirst;

  /// Generic network error message
  ///
  /// In en, this message translates to:
  /// **'Network error, please try again later'**
  String get networkError;

  /// Login success message
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get loginSuccess;

  /// Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful'**
  String get registrationSuccess;

  /// Error message when getting captcha fails
  ///
  /// In en, this message translates to:
  /// **'Failed to get captcha'**
  String get getCaptchaFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
