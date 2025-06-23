import 'dart:convert';

class Agent {
  final int id;
  final int userId;
  final String agentName;
  final String ttsVoice;
  final String llmModel;
  final String assistantName;
  final String userName;
  final String? memory;
  final String character;
  final int longMemorySwitch;
  final String langCode;
  final String language;
  final String ttsSpeechSpeed;
  final String asrSpeed;
  final int ttsPitch;
  final int deviceCount;
  final String createdAt;
  final String updatedAt;

  Agent({
    required this.id,
    required this.userId,
    required this.agentName,
    required this.ttsVoice,
    required this.llmModel,
    required this.assistantName,
    required this.userName,
    this.memory,
    required this.character,
    required this.longMemorySwitch,
    required this.langCode,
    required this.language,
    required this.ttsSpeechSpeed,
    required this.asrSpeed,
    required this.ttsPitch,
    required this.deviceCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      agentName: json['agent_name'] ?? '',
      ttsVoice: json['tts_voice'] ?? '',
      llmModel: json['llm_model'] ?? '',
      assistantName: json['assistant_name'] ?? '',
      userName: json['user_name'] ?? '',
      memory: json['memory'],
      character: json['character'] ?? '',
      longMemorySwitch: json['long_memory_switch'] ?? 0,
      langCode: json['lang_code'] ?? '',
      language: json['language'] ?? '',
      ttsSpeechSpeed: json['tts_speech_speed'] ?? 'normal',
      asrSpeed: json['asr_speed'] ?? 'normal',
      ttsPitch: json['tts_pitch'] ?? 0,
      deviceCount: json['deviceCount'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agent_name': agentName,
      'tts_voice': ttsVoice,
      'llm_model': llmModel,
      'assistant_name': assistantName,
      'user_name': userName,
      'memory': memory,
      'character': character,
      'long_memory_switch': longMemorySwitch,
      'lang_code': langCode,
      'language': language,
      'tts_speech_speed': ttsSpeechSpeed,
      'asr_speed': asrSpeed,
      'tts_pitch': ttsPitch,
      'deviceCount': deviceCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
} 
            