import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/agent_service.dart';
import '../services/auth_service.dart';

class HistoryScreen extends StatefulWidget {
  final int agentId;
  const HistoryScreen({super.key, required this.agentId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String? userName;
  String? deviceId;
  String? userAvatarUrl;
  List<ChatMessage> messages = [];
  bool isLoading = true;
  String? error;

  late final AgentService agentService;

  @override
  void initState() {
    super.initState();
    // 获取 AuthService 实例（假设你用 Provider 管理）
    final authService = context.read<AuthService>();
    agentService = AgentService(authService: authService);
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final data = await agentService.getHistory(widget.agentId);
      setState(() {
        userName = data.userName;
        deviceId = data.deviceId;
        userAvatarUrl = data.userAvatarUrl;
        messages = data.messages;
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('加载失败: $error'));
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '与$userName的聊天记录',
          style: const TextStyle(
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
            // 左侧信息栏
            Container(
              width: 140,
              color: Colors.white.withOpacity(0.85),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  const SizedBox(height: 32),
                  ClipOval(
                    child: (userAvatarUrl?.isNotEmpty ?? false)
                        ? Image.network(
                            userAvatarUrl!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.contain, // 保证图片完整显示
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFFE0E7EF),
                              child: const Icon(Icons.person, size: 44, color: Color(0xFF667EEA)),
                            ),
                          )
                        : Container(
                            width: 64,
                            height: 64,
                            color: const Color(0xFFE0E7EF),
                            child: const Icon(Icons.person, size: 44, color: Color(0xFF667EEA)),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName ?? '',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF222B45)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    deviceId ?? '',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8F9BB3)),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      messages.length.toString(),
                      style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(height: 1, color: Colors.grey.withOpacity(0.15)),
                  const SizedBox(height: 24),
                  const Text('没有更多记录了', style: TextStyle(fontSize: 13, color: Color(0xFF8F9BB3))),
                ],
              ),
            ),
            // 聊天内容区
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  itemCount: messages.length,
                  separatorBuilder: (context, idx) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final msg = messages[idx];
                    final isUser = msg.isUser;
                    return Column(
                      crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isUser) ...[
                              // 机器人头像
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  backgroundImage: const AssetImage('assets/robot_avatar.png'),
                                  child: Image.asset('assets/robot_avatar.png', width: 32, height: 32, fit: BoxFit.cover),
                                ),
                              ),
                            ],
                            Flexible(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isUser ? const Color(0xFF667EEA) : Colors.white.withOpacity(0.95),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                                      bottomRight: Radius.circular(isUser ? 4 : 16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    border: isUser
                                        ? null
                                        : Border.all(color: const Color(0xFF667EEA).withOpacity(0.10)),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : const Color(0xFF222B45),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (!isUser) ...[
                              // 播放按钮
                              IconButton(
                                icon: const Icon(Icons.play_circle_fill, color: Color(0xFF667EEA), size: 28),
                                onPressed: () {},
                                tooltip: '播放语音',
                              ),
                            ],
                          ],
                        ),
                        // 时间分割线
                        Padding(
                          padding: EdgeInsets.only(
                            top: 8,
                            left: isUser ? 0 : 50,
                            right: isUser ? 50 : 0,
                          ),
                          child: Text(
                            msg.time,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF8F9BB3)),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
