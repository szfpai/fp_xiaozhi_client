import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';

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

class HomeService extends ChangeNotifier {
  final AuthService authService;

  HomeService({required this.authService});

  Future<List<Agent>> getAgents({int page = 1, int pageSize = 24}) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/agents?page=$page&pageSize=$pageSize');

    // 构建headers，包含Content-Type和可选的Authorization token
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // 从AuthService获取token
    final token = authService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => Agent.fromJson(item))
              .toList();
        } else {
          throw Exception('API返回数据格式错误: ${data['message']}');
        }
      } else {
        // 网络请求失败，返回mock数据以便测试
        print('网络请求失败: ${response.statusCode}, 返回mock数据');
        return _getMockAgents();
      }
    } catch (e) {
      print('捕获到异常: $e, 返回mock数据');
      return _getMockAgents();
    }
  }

  List<Agent> _getMockAgents() {
    return [
      Agent(id: 1, agentName: '小智', ttsVoice: '女神', llmModel: 'openAI', assistantName: '小助理', userName: '天平', character: '小河', language: '中文', deviceCount: 1),
      Agent(id: 2, agentName: '小梦', ttsVoice: '御姐', llmModel: 'Kimi', assistantName: '大助理', userName: '小芳', character: '小溪', language: '英文', deviceCount: 2),
      Agent(id: 3, agentName: '小慧', ttsVoice: '萝莉', llmModel: 'Gemini', assistantName: '中助理', userName: '小明', character: '小江', language: '日文', deviceCount: 3),
    ];
  }
}

