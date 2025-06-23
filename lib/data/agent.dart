class Agent {
  final int id;
  final String agentName;
  final String ttsVoice;
  final String llmModel;
  final String assistantName;
  final String userName;
  final String character;
  final String language;
  final int deviceCount;

  Agent({
    required this.id,
    required this.agentName,
    required this.ttsVoice,
    required this.llmModel,
    required this.assistantName,
    required this.userName,
    required this.character,
    required this.language,
    required this.deviceCount,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      agentName: json['agent_name'] ?? '',
      ttsVoice: json['tts_voice'] ?? '',
      llmModel: json['llm_model'] ?? '',
      assistantName: json['assistant_name'] ?? '',
      userName: json['user_name'] ?? '',
      character: json['character'] ?? '',
      language: json['language'] ?? '',
      deviceCount: json['deviceCount'] ?? 0,
    );
  }
} 