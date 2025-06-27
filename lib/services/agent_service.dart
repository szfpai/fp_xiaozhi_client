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

/*
使用示例：

// 在 Widget 中使用 getSessionList 接口
class SessionListScreen extends StatefulWidget {
  final String agentId;
  
  const SessionListScreen({Key? key, required this.agentId}) : super(key: key);
  
  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  List<Session> sessions = [];
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _loadSessions();
  }
  
  Future<void> _loadSessions() async {
    try {
      final authService = context.read<AuthService>();
      final agentService = AgentService(authService: authService);
      final response = await agentService.getSessionList(widget.agentId);
      
      setState(() {
        sessions = response.list;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('会话列表')),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text('错误: $error'))
          : ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return ListTile(
                  title: Text('会话 ${session.sessionId}'),
                  subtitle: Text('创建时间: ${session.createdAt}'),
                  trailing: Text('消息数: ${session.chatCount}'),
                  onTap: () {
                    // 跳转到聊天历史页面
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatHistoryScreen(
                          agentId: widget.agentId,
                          sessionId: session.sessionId,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

// 在 Widget 中使用 getChatHistory 接口
class ChatHistoryScreen extends StatefulWidget {
  final String agentId;
  final String sessionId;
  
  const ChatHistoryScreen({
    Key? key, 
    required this.agentId, 
    required this.sessionId,
  }) : super(key: key);
  
  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<ChatHistoryItem> chatHistory = [];
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }
  
  Future<void> _loadChatHistory() async {
    try {
      final authService = context.read<AuthService>();
      final agentService = AgentService(authService: authService);
      final history = await agentService.getChatHistory(widget.agentId, widget.sessionId);
      
      setState(() {
        chatHistory = history;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('聊天历史 - ${widget.sessionId}')),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : error != null
          ? Center(child: Text('错误: $error'))
          : ListView.builder(
              itemCount: chatHistory.length,
              itemBuilder: (context, index) {
                final item = chatHistory[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item.isUserMessage ? Colors.blue : Colors.green,
                      child: Icon(
                        item.isUserMessage ? Icons.person : Icons.smart_toy,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      item.isUserMessage ? '用户' : 'AI助手',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.content),
                        const SizedBox(height: 4),
                        Text(
                          '时间: ${item.createdAt}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (item.audioId.isNotEmpty)
                          Text(
                            '音频ID: ${item.audioId}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        if (item.macAddress.isNotEmpty)
                          Text(
                            '设备: ${item.macAddress}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
*/ 