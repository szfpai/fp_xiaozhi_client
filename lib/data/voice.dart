class Voice {
  final String name; // The display name, e.g., "湾湾小何"
  final String? originalName; // Original name for multi-language voices
  final String? enName; // English name for bilingual voices
  final String voiceSource; // The voice provider, e.g., "volcengine"
  final String voiceId; // The actual ID used by the API
  final List<String> languages; // Supported languages, e.g., ["zh", "en"]
  final String? voiceDemo; // General demo audio URL (for single language voices)
  final String? zhVoiceDemo; // Chinese demo audio URL
  final String? enVoiceDemo; // English demo audio URL
  final String? createdAt; // Creation date

  Voice({
    required this.name,
    this.originalName,
    this.enName,
    required this.voiceSource,
    required this.voiceId,
    required this.languages,
    this.voiceDemo,
    this.zhVoiceDemo,
    this.enVoiceDemo,
    this.createdAt,
  });

  factory Voice.fromJson(Map<String, dynamic> json) {
    return Voice(
      name: json['name'] ?? '',
      originalName: json['original_name'],
      enName: json['en_name'],
      voiceSource: json['voice_source'] ?? '',
      voiceId: json['voice_id'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      voiceDemo: json['voice_demo'],
      zhVoiceDemo: json['zh_voice_demo'],
      enVoiceDemo: json['en_voice_demo'],
      createdAt: json['created_at'],
    );
  }

  /// Get demo URL for a specific language
  String? getDemoUrl(String language) {
    switch (language.toLowerCase()) {
      case 'zh':
      case 'zh-cn':
      case 'chinese':
        return zhVoiceDemo ?? voiceDemo;
      case 'en':
      case 'en-us':
      case 'english':
        return enVoiceDemo ?? voiceDemo;
      default:
        return voiceDemo;
    }
  }

  /// Check if voice supports a specific language
  bool supportsLanguage(String language) {
    return languages.contains(language.toLowerCase());
  }

  /// Get the primary demo URL (prioritizes language-specific demos)
  String? getPrimaryDemoUrl() {
    return zhVoiceDemo ?? enVoiceDemo ?? voiceDemo;
  }

  /// Get display name with language indication
  String getDisplayName() {
    if (enName != null && enName!.isNotEmpty) {
      return '$name / $enName';
    }
    return name;
  }
} 