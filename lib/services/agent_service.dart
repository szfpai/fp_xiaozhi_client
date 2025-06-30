import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'auth_service.dart';

class AgentService {
  final AuthService authService;
  AgentService({required this.authService});

  /// 获取某个agent的会话列表
  Future<SessionListResponse> getSessionList(String agentId) async {
    print('=== AgentService.getSessionList 开始 ===');
    print('Agent ID: $agentId');
    
    final token = await authService.getToken();
    if (token == null) {
      print('用户未登录，抛出异常');
      throw Exception('用户未登录');
    }

    final url = Uri.parse('${AppConfig.baseUrl}/xiaozhi/agent/$agentId/sessions?page=1&limit=20');
    print('请求URL: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 0 && data['data'] != null) {
          final sessionList = SessionListResponse.fromJson(data['data']);
          print('成功解析会话列表，总数: ${sessionList.total}');
          return sessionList;
        } else {
          print('API返回错误: ${data['msg']}');
          throw Exception('获取会话列表失败: ${data['msg']}');
        }
      } else {
        print('HTTP请求失败: ${response.statusCode}');
        throw Exception('网络请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('捕获到异常: $e');
      rethrow;
    } finally {
      print('=== AgentService.getSessionList 结束 ===');
    }
  }

  /// 获取某个agent的聊天历史
  Future<List<ChatHistoryItem>> getChatHistory(String agentId, String sessionId) async {
    print('=== AgentService.getChatHistory 开始 ===');
    print('Agent ID: $agentId, Session ID: $sessionId');
    
    final token = await authService.getToken();
    if (token == null) {
      print('用户未登录，抛出异常');
      throw Exception('用户未登录');
    }

    final url = Uri.parse('${AppConfig.baseUrl}/xiaozhi/agent/$agentId/chat-history/$sessionId');
    print('请求URL: $url');

    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      print('响应状态码: ${response.statusCode}');
      print('响应体: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['code'] == 0 && data['data'] != null) {
          final chatHistory = (data['data'] as List)
              .map((item) => ChatHistoryItem.fromJson(item))
              .toList();
          print('成功解析聊天历史，消息数: ${chatHistory.length}');
          return chatHistory;
        } else {
          print('API返回错误: ${data['msg']}');
          throw Exception('获取聊天历史失败: ${data['msg']}');
        }
      } else {
        print('HTTP请求失败: ${response.statusCode}');
        throw Exception('网络请求失败: ${response.statusCode}');
      }
    } catch (e) {
      print('捕获到异常: $e');
      rethrow;
    } finally {
      print('=== AgentService.getChatHistory 结束 ===');
    }
  }

  /// 获取某个agent的聊天历史（旧版本，保持向后兼容）
  Future<AgentHistory> getHistory(String agentId) async {
    final token = await authService.getToken();
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

  /// 创建新的Agent
  Future<bool> createAgent(String agentName) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('用户未登录');
    }
    final url = Uri.parse('${AppConfig.baseUrl}/xiaozhi/agent');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'agentName': agentName}),
      );
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['code'] == 0) {
        return true;
      } else {
        throw Exception('创建失败: \\${data['msg'] ?? response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Agent 详情数据模型
  Future<AgentDetail> getAgentDetail(String id) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('用户未登录');
    }
    final url = Uri.parse('${AppConfig.baseUrl}/xiaozhi/agent/$id');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['code'] == 0) {
        return AgentDetail.fromJson(data['data'] ?? {});
      } else {
        throw Exception('获取Agent详情失败: \\${data['msg'] ?? response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// 会话列表响应数据模型
class SessionListResponse {
  final int total;
  final List<Session> list;

  SessionListResponse({
    required this.total,
    required this.list,
  });

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    return SessionListResponse(
      total: json['total'] ?? 0,
      list: (json['list'] as List? ?? [])
          .map((e) => Session.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'list': list.map((e) => e.toJson()).toList(),
    };
  }
}

/// 会话数据模型
class Session {
  final String sessionId;
  final String createdAt;
  final int chatCount;

  Session({
    required this.sessionId,
    required this.createdAt,
    required this.chatCount,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      chatCount: json['chatCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'createdAt': createdAt,
      'chatCount': chatCount,
    };
  }
}

/// 聊天历史项数据模型
class ChatHistoryItem {
  final String createdAt;
  final String chatType;
  final String content;
  final String audioId;
  final String macAddress;

  ChatHistoryItem({
    required this.createdAt,
    required this.chatType,
    required this.content,
    required this.audioId,
    required this.macAddress,
  });

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      createdAt: json['createdAt']?.toString() ?? '',
      chatType: json['chatType']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      audioId: json['audioId']?.toString() ?? '',
      macAddress: json['macAddress']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt,
      'chatType': chatType,
      'content': content,
      'audioId': audioId,
      'macAddress': macAddress,
    };
  }

  /// 判断是否为用户消息
  bool get isUserMessage => chatType.toLowerCase() == '1';
  
  /// 判断是否为AI消息
  bool get isAIMessage => chatType.toLowerCase() == '2' || chatType.toLowerCase() == 'assistant';
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

/// Agent 详情数据模型
class AgentDetail {
  final String id;
  final String userId;
  final String agentCode;
  final String agentName;
  final String asrModelId;
  final String vadModelId;
  final String llmModelId;
  final String vllmModelId;
  final String ttsModelId;
  final String ttsVoiceId;
  final String memModelId;
  final String intentModelId;
  final int chatHistoryConf;
  final String systemPrompt;
  final String summaryMemory;
  final String langCode;
  final String language;
  final int sort;
  final String creator;
  final String createdAt;
  final String updater;
  final String updatedAt;
  final List<AgentFunction> functions;

  AgentDetail({
    required this.id,
    required this.userId,
    required this.agentCode,
    required this.agentName,
    required this.asrModelId,
    required this.vadModelId,
    required this.llmModelId,
    required this.vllmModelId,
    required this.ttsModelId,
    required this.ttsVoiceId,
    required this.memModelId,
    required this.intentModelId,
    required this.chatHistoryConf,
    required this.systemPrompt,
    required this.summaryMemory,
    required this.langCode,
    required this.language,
    required this.sort,
    required this.creator,
    required this.createdAt,
    required this.updater,
    required this.updatedAt,
    required this.functions,
  });

  factory AgentDetail.fromJson(Map<String, dynamic> json) {
    return AgentDetail(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      agentCode: json['agentCode']?.toString() ?? '',
      agentName: json['agentName']?.toString() ?? '',
      asrModelId: json['asrModelId']?.toString() ?? '',
      vadModelId: json['vadModelId']?.toString() ?? '',
      llmModelId: json['llmModelId']?.toString() ?? '',
      vllmModelId: json['vllmModelId']?.toString() ?? '',
      ttsModelId: json['ttsModelId']?.toString() ?? '',
      ttsVoiceId: json['ttsVoiceId']?.toString() ?? '',
      memModelId: json['memModelId']?.toString() ?? '',
      intentModelId: json['intentModelId']?.toString() ?? '',
      chatHistoryConf: int.tryParse(json['chatHistoryConf']?.toString() ?? '') ?? 0,
      systemPrompt: json['systemPrompt']?.toString() ?? '',
      summaryMemory: json['summaryMemory']?.toString() ?? '',
      langCode: json['langCode']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      sort: int.tryParse(json['sort']?.toString() ?? '') ?? 0,
      creator: json['creator']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      updater: json['updater']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      functions: (json['functions'] as List? ?? []).map((e) => AgentFunction.fromJson(e)).toList(),
    );
  }

  // 兼容Agent的getter
  String get assistantName => agentName;
  String get character => systemPrompt;
  String get ttsVoice => ttsVoiceId.isNotEmpty ? ttsVoiceId : ttsModelId;
  String get languageDisplay => language.isNotEmpty ? language : '中文';
  String get langCodeDisplay => langCode.isNotEmpty ? langCode : 'zh';
  String? get memory => summaryMemory;
}

class AgentFunction {
  final String id;
  final String agentId;
  final String pluginId;
  final String paramInfo;
  final String providerCode;

  AgentFunction({
    required this.id,
    required this.agentId,
    required this.pluginId,
    required this.paramInfo,
    required this.providerCode,
  });

  factory AgentFunction.fromJson(Map<String, dynamic> json) {
    return AgentFunction(
      id: json['id']?.toString() ?? '',
      agentId: json['agentId']?.toString() ?? '',
      pluginId: json['pluginId']?.toString() ?? '',
      paramInfo: json['paramInfo']?.toString() ?? '',
      providerCode: json['providerCode']?.toString() ?? '',
    );
  }
}
