import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  Locale _currentLocale = const Locale('zh'); // 默认中文

  Locale get currentLocale => _currentLocale;

  LanguageService() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    if (languageCode != null) {
      _currentLocale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(Locale newLocale) async {
    if (_currentLocale != newLocale) {
      _currentLocale = newLocale;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, newLocale.languageCode);
      notifyListeners();
    }
  }

  bool get isChinese => _currentLocale.languageCode == 'zh';
  bool get isEnglish => _currentLocale.languageCode == 'en';
} 