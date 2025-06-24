import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';
import '../services/agent_service.dart';

class AgentService {
  final AuthService authService;
  AgentService({required this.authService});

  /// 获取某个agent的聊天历史
  Future<AgentHistory> getHistory(int agentId) async {
    final token = authService.token;
    if (token == null) {
      // 返回 mock 数据
      return AgentHistory(
        userName: '测试hero',
        deviceId: 'B7:FE:63:5F:23:63',
        userAvatarUrl: '',
        messages: [
          ChatMessage(isUser: true, text: '今天是什么日子', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '嗨', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '今天啊，是2023年11月8日哦', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '你有没有什么特别的计划呀?', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '对了，你知道吗，今天也是立冬呢', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '天气可能会变冷，记得多穿衣服哦~', time: '今天 15:36'),
        ],
      );
    }
    final url = Uri.parse('${AppConfig.baseUrl}/api/agents/$agentId/history');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data['success'] == true && data['data'] != null) {
        return AgentHistory.fromJson(data['data']);
      } else {
        // 返回 mock 数据
        return AgentHistory(
          userName: '测试hero',
          deviceId: 'B7:FE:63:5F:23:63',
          userAvatarUrl: '',
          messages: [
            ChatMessage(isUser: true, text: '今天是什么日子', time: '今天 15:36'),
            ChatMessage(isUser: false, text: '嗨', time: '今天 15:36'),
            ChatMessage(isUser: false, text: '今天啊，是2023年11月8日哦', time: '今天 15:36'),
            ChatMessage(isUser: false, text: '你有没有什么特别的计划呀?', time: '今天 15:36'),
            ChatMessage(isUser: false, text: '对了，你知道吗，今天也是立冬呢', time: '今天 15:36'),
            ChatMessage(isUser: false, text: '天气可能会变冷，记得多穿衣服哦~', time: '今天 15:36'),
          ],
        );
      }
    } else {
      // 返回 mock 数据
      return AgentHistory(
        userName: '测试hero',
        deviceId: 'B7:FE:63:5F:23:63',
        userAvatarUrl: '',
        messages: [
          ChatMessage(isUser: true, text: '今天是什么日子', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '嗨', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '今天啊，是2023年11月8日哦', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '你有没有什么特别的计划呀?', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '对了，你知道吗，今天也是立冬呢', time: '今天 15:36'),
          ChatMessage(isUser: false, text: '天气可能会变冷，记得多穿衣服哦~', time: '今天 15:36'),
        ],
      );
    }
  }
}

class AgentHistory {
  final String userName;
  final String deviceId;
  final String userAvatarUrl;
  final List<ChatMessage> messages;

  AgentHistory({
    required this.userName,
    required this.deviceId,
    required this.userAvatarUrl,
    required this.messages,
  });

  factory AgentHistory.fromJson(Map<String, dynamic> json) {
    return AgentHistory(
      userName: json['userName'] ?? '',
      deviceId: json['deviceId'] ?? '',
      userAvatarUrl: json['userAvatarUrl'] ?? '',
      messages: (json['messages'] as List? ?? []).map((e) => ChatMessage.fromJson(e)).toList(),
    );
  }
}

class ChatMessage {
  final bool isUser;
  final String text;
  final String time;

  ChatMessage({required this.isUser, required this.text, required this.time});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isUser: json['isUser'] ?? false,
      text: json['text'] ?? '',
      time: json['time'] ?? '',
    );
  }
} 