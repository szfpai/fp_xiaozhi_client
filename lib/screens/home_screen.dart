import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/home_service.dart';
import '../data/agent.dart';
import 'login_screen.dart';
import 'character_config_screen.dart';
import 'voiceprint_screen.dart';
import 'history_screen.dart';
import 'device_binding_screen.dart';

// 功能项数据结构
class HomeFeature {
  final String title;
  final IconData icon;
  HomeFeature(this.title, this.icon);
}

// 每个Card的数据结构
class HomeCardData {
  final String userName;
  final String welcomeMsg;
  final String avatarUrl;
  final String doctorImgUrl;
  final List<HomeFeature> features;
  HomeCardData({
    required this.userName,
    required this.welcomeMsg,
    required this.avatarUrl,
    required this.doctorImgUrl,
    required this.features,
  });
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  List<Agent> _agents = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadAgents() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final authService = context.read<AuthService>();
      final homeService = HomeService(authService: authService);
      final agents = await homeService.getAgents();

      setState(() {
        _agents = agents;
        print('页面数量: ${_agents.length}');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认登出'),
          content: const Text('您确定要退出登录吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthService>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
              child: const Text(
                '确定',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFeatureDialog(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(featureName),
          content: Text('$featureName 功能正在开发中，敬请期待！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1976D2),
      appBar: AppBar(
        title: const Text('小智客户端'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey[50],
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('加载失败: $_error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadAgents,
                            child: const Text('重试'),
                          ),
                        ],
                      ),
                    )
                  : _agents.isEmpty
                      ? const Center(child: Text('暂无数据'))
                      : Column(
                          children: [
                            Expanded(
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _agents.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentPage = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  final agent = _agents[index];
                                  final screenHeight = MediaQuery.of(context).size.height;
                                  return SingleChildScrollView(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Column(
                                        children: [
                                          SizedBox(height: screenHeight * 0.03),
                                          _buildAgentInfoCard(agent, screenHeight),
                                          SizedBox(height: screenHeight * 0.04),
                                          _buildConfigGrid(agent: agent),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildPageIndicator(),
                            const SizedBox(height: 80), // 为悬浮按钮留出空间
                          ],
                        ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: 添加新配置的逻辑
        },
        backgroundColor: const Color(0xFF673AB7),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // 构建顶部的Agent信息卡片
  Widget _buildAgentInfoCard(Agent agent, double screenHeight) {
    return Container(
      height: screenHeight * 0.22, // 响应式高度
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667EEA),
            Color(0xFF764BA2),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // hero大方框，显示agentName
          Container(
            width: 120,
            height: double.infinity, // 占满父容器高度
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Color(0xFFF8F9FA),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  agent.agentName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          // 右侧信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 均匀分布
              children: [
                _buildInfoRow('角色: ${agent.character}', const Color(0xFFE6FFFA), const Color(0xFF38B2AC)),
                _buildInfoRow('音色: ${agent.ttsVoice}', const Color(0xFFFFF5F5), const Color(0xFFF56565)),
                _buildInfoRow('模型: ${agent.llmModel}', const Color(0xFFF0FFF4), const Color(0xFF48BB78)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String text, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 38, // 固定信息行高度
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: textColor.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 配置按钮区
  Widget _buildConfigGrid({required Agent agent}) {
    // 为每个按钮定义文案和颜色
    final List<Map<String, dynamic>> configs = [
      {
        'text': '配置角色',
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CharacterConfigScreen(agentId: agent.id)),
          );
        },
      },
      {
        'text': '声纹识别',
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF48BB78), Color(0xFF38A169)],
        ),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VoiceprintScreen(agentId: agent.id)),
          );
        },
      },
      {
        'text': '历史对话',
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFED8936), Color(0xFFDD6B20)],
        ),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HistoryScreen(agentId: agent.id)),
          );
        },
      },
      {
        'text': '绑定设备',
        'gradient': const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9F7AEA), Color(0xFF805AD5)],
        ),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DeviceBindingScreen(agentId: agent.id)),
          );
        },
      },
    ];
    final double screenWidth = MediaQuery.of(context).size.width;
    // 根据屏幕宽度动态调整卡片间距
    final double spacing = screenWidth * 0.05;

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildConfigCard(configs[0]['text'], configs[0]['gradient'], configs[0]['onTap'])),
            SizedBox(width: spacing),
            Expanded(child: _buildConfigCard(configs[1]['text'], configs[1]['gradient'], configs[1]['onTap'])),
          ],
        ),
        SizedBox(height: spacing),
        Row(
          children: [
            Expanded(child: _buildConfigCard(configs[2]['text'], configs[2]['gradient'], configs[2]['onTap'])),
            SizedBox(width: spacing),
            Expanded(child: _buildConfigCard(configs[3]['text'], configs[3]['gradient'], configs[3]['onTap'])),
          ],
        ),
      ],
    );
  }

  // 单个配置卡片
  Widget _buildConfigCard(String text, Gradient gradient, VoidCallback onTap) {
    return AspectRatio(
      aspectRatio: 1, // 保证卡片是正方形
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 构建页面指示器
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_agents.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: _currentPage == index
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  )
                : null,
            color: _currentPage == index ? null : Colors.grey[300],
            boxShadow: _currentPage == index
                ? [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final HomeCardData card;
  const _HomeCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1976D2),
      child: Column(
        children: [
          // 顶部蓝色区域
          Container(
            padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 16),
            color: const Color(0xFF1976D2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧头像和欢迎语
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(card.avatarUrl),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'welcome !',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      card.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      card.welcomeMsg,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 右侧医生图片
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    card.doctorImgUrl,
                    width: 110,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          // 白色圆角功能区
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: card.features.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, idx) {
                    final feature = card.features[idx];
                    return _FeatureCard(feature: feature);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final HomeFeature feature;
  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: 跳转到对应功能页面
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withOpacity(0.12),
              radius: 26,
              child: Icon(feature.icon, color: Colors.blue, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              feature.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
} 