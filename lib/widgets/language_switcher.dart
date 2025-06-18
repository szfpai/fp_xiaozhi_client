import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);
    final isChinese = currentLocale.languageCode == 'zh';

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (Locale locale) {
        final languageService = context.read<LanguageService>();
        languageService.changeLanguage(locale);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<Locale>(
          value: const Locale('zh'),
          child: Row(
            children: [
              Text(
                '🇨🇳 中文',
                style: TextStyle(
                  fontWeight: isChinese ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isChinese) const Icon(Icons.check, size: 16),
            ],
          ),
        ),
        PopupMenuItem<Locale>(
          value: const Locale('en'),
          child: Row(
            children: [
              Text(
                '🇺🇸 English',
                style: TextStyle(
                  fontWeight: !isChinese ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!isChinese) const Icon(Icons.check, size: 16),
            ],
          ),
        ),
      ],
    );
  }
} 