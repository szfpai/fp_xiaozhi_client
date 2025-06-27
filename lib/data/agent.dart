import 'dart:convert';

class Agent {
  final String id;
  final String agentName;
  final String ttsModelName;
  final String ttsVoiceName;
  final String llmModelName;
  final String vllmModelName;
  final String memModelId;
  final String systemPrompt;
  final String? summaryMemory;
  final String? lastConnectedAt;
  final int deviceCount;

  Agent({
    required this.id,
    required this.agentName,
    required this.ttsModelName,
    required this.ttsVoiceName,
    required this.llmModelName,
    required this.vllmModelName,
    required this.memModelId,
    required this.systemPrompt,
    this.summaryMemory,
    this.lastConnectedAt,
    required this.deviceCount,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? '',
      agentName: json['agentName'] ?? '',
      ttsModelName: json['ttsModelName'] ?? '',
      ttsVoiceName: json['ttsVoiceName'] ?? '',
      llmModelName: json['llmModelName'] ?? '',
      vllmModelName: json['vllmModelName'] ?? '',
      memModelId: json['memModelId'] ?? '',
      systemPrompt: json['systemPrompt'] ?? '',
      summaryMemory: json['summaryMemory'],
      lastConnectedAt: json['lastConnectedAt'],
      deviceCount: json['deviceCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentName': agentName,
      'ttsModelName': ttsModelName,
      'ttsVoiceName': ttsVoiceName,
      'llmModelName': llmModelName,
      'vllmModelName': vllmModelName,
      'memModelId': memModelId,
      'systemPrompt': systemPrompt,
      'summaryMemory': summaryMemory,
      'lastConnectedAt': lastConnectedAt,
      'deviceCount': deviceCount,
    };
  }

  // 为了保持向后兼容，添加一些 getter 方法
  String get ttsVoice => ttsVoiceName;
  String get llmModel => llmModelName;
  String get character => systemPrompt;
  String? get memory => summaryMemory;
  String get assistantName => agentName; // 使用 agentName 作为 assistantName
  String get userName => ''; // 暂时返回空字符串
  String get language => '中文'; // 默认中文
  String get langCode => 'zh'; // 默认中文代码
  String get ttsSpeechSpeed => 'normal'; // 默认正常速度
  String get asrSpeed => 'normal'; // 默认正常速度
  int get ttsPitch => 0; // 默认音调
  int get userId => 0; // 暂时返回 0
  String get createdAt => ''; // 暂时返回空字符串
  String get updatedAt => ''; // 暂时返回空字符串
  int get longMemorySwitch => 1; // 默认开启长记忆
} 
            