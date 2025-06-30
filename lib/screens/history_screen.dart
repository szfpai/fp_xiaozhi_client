import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  final String agentId;
  const HistoryScreen({super.key, required this.agentId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Session> sessions = [];
  List<ChatHistoryItem> chatHistory = [];
  Session? selectedSession;
  bool isLoadingSessions = true;
  bool isLoadingChatHistory = false;
  String? error;

  late final AgentService agentService;

  @override
  void initState() {
    super.initState();
    final authService = context.read<AuthService>();
    agentService = AgentService(authService: authService);
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      setState(() {
        isLoadingSessions = true;
        error = null;
      });

      final response = await agentService.getSessionList(widget.agentId);
      setState(() {
        sessions = response.list;
        isLoadingSessions = false;
      });

      // 如果有会话，自动选择第一个
      if (sessions.isNotEmpty) {
        _selectSession(sessions.first);
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingSessions = false;
      });
    }
  }

  Future<void> _selectSession(Session session) async {
    setState(() {
      selectedSession = session;
      isLoadingChatHistory = true;
      chatHistory = [];
    });

    try {
      final history = await agentService.getChatHistory(widget.agentId, session.sessionId);
      setState(() {
        chatHistory = history;
        isLoadingChatHistory = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoadingChatHistory = false;
      });
    }
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays}天前';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时前';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}分钟前';
      } else {
        return '刚刚';
      }
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          '聊天历史',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: Row(
          children: [
            // 左侧会话列表
            Container(
              width: 200,
              color: Colors.white.withOpacity(0.95),
              child: Column(
                children: [
                  // 会话列表标题
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Color(0xFF667EEA)),
                        const SizedBox(width: 8),
                        const Text(
                          '会话列表',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF222B45),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${sessions.length}个会话',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8F9BB3),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // 会话列表内容
                  Expanded(
                    child: isLoadingSessions
                        ? const Center(child: CircularProgressIndicator())
                        : error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '加载失败: $error',
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadSessions,
                                      child: const Text('重试'),
                                    ),
                                  ],
                                ),
                              )
                            : sessions.isEmpty
                                ? const Center(
                                    child: Text(
                                      '暂无会话记录',
                                      style: TextStyle(
                                        color: Color(0xFF8F9BB3),
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: sessions.length,
                                    itemBuilder: (context, index) {
                                      final session = sessions[index];
                                      final isSelected = selectedSession?.sessionId == session.sessionId;
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF667EEA).withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          border: isSelected
                                              ? Border.all(color: const Color(0xFF667EEA), width: 2)
                                              : null,
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: const Color(0xFF667EEA),
                                            child: Text(
                                              '${index + 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            '会话 ${session.sessionId.substring(0, 8)}...',
                                            style: TextStyle(
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                              color: isSelected ? const Color(0xFF667EEA) : const Color(0xFF222B45),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '消息数: ${session.chatCount}',
                                                style: const TextStyle(fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                _formatTime(session.createdAt),
                                                style: const TextStyle(fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                          onTap: () => _selectSession(session),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),
            // 右侧聊天记录区域
            Expanded(
              child: Container(
                color: Colors.white.withOpacity(0.1),
                child: selectedSession == null
                    ? const Center(
                        child: Text(
                          '请选择一个会话查看聊天记录',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          // 聊天记录标题
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat, color: Colors.white),
                                const SizedBox(width: 8),
                                Text(
                                  '会话 ${selectedSession!.sessionId.substring(0, 8)}...',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${chatHistory.length}条消息',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 聊天记录内容
                          Expanded(
                            child: isLoadingChatHistory
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : chatHistory.isEmpty
                                    ? const Center(
                                        child: Text(
                                          '暂无聊天记录',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: const EdgeInsets.all(16),
                                        itemCount: chatHistory.length,
                                        itemBuilder: (context, index) {
                                          final item = chatHistory[index];
                                          final isUser = item.isUserMessage;
                                          return Container(
                                            margin: const EdgeInsets.only(bottom: 16),
                                            child: Column(
                                              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    if (!isUser) ...[
                                                      // AI头像
                                                      Container(
                                                        margin: const EdgeInsets.only(right: 8),
                                                        child: const CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor: Colors.white,
                                                          child: Icon(
                                                            Icons.smart_toy,
                                                            color: Color(0xFF667EEA),
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                    Flexible(
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          maxWidth: MediaQuery.of(context).size.width * 0.6,
                                                        ),
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                          decoration: BoxDecoration(
                                                            color: isUser ? Colors.white : Colors.white.withOpacity(0.95),
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: const Radius.circular(16),
                                                              topRight: const Radius.circular(16),
                                                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                                                              bottomRight: Radius.circular(isUser ? 4 : 16),
                                                            ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors.black.withOpacity(0.1),
                                                                blurRadius: 8,
                                                                offset: const Offset(0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                item.content,
                                                                style: TextStyle(
                                                                  color: isUser ? const Color(0xFF222B45) : const Color(0xFF222B45),
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 8),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    _formatTime(item.createdAt),
                                                                    style: const TextStyle(
                                                                      fontSize: 12,
                                                                      color: Color(0xFF8F9BB3),
                                                                    ),
                                                                  ),
                                                                  if (item.audioId.isNotEmpty) ...[
                                                                    const SizedBox(width: 8),
                                                                    const Icon(
                                                                      Icons.audiotrack,
                                                                      size: 14,
                                                                      color: Color(0xFF8F9BB3),
                                                                    ),
                                                                  ],
                                                                  if (item.macAddress.isNotEmpty) ...[
                                                                    const SizedBox(width: 8),
                                                                    const Icon(
                                                                      Icons.devices,
                                                                      size: 14,
                                                                      color: Color(0xFF8F9BB3),
                                                                    ),
                                                                  ],
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    if (isUser) ...[
                                                      // 用户头像
                                                      Container(
                                                        margin: const EdgeInsets.only(left: 8),
                                                        child: const CircleAvatar(
                                                          radius: 18,
                                                          backgroundColor: Color(0xFF667EEA),
                                                          child: Icon(
                                                            Icons.person,
                                                            color: Colors.white,
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
