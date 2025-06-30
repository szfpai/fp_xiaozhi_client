import 'package:flutter/material.dart';

class MoreFunScreen extends StatelessWidget {
  const MoreFunScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多玩法'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            // 公告卡片
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: const BorderSide(color: Color(0xFF764BA2), width: 2),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
                child: Column(
                  children: const [
                    Text(
                      '公告一：',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF764BA2)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 18),
                    Text(
                      '1.浮点AI在最新的服务版本中接入了openAI，你可以通过进入角色配置页面，选择该模型\n'
                      '2.为了更好服务我们的用户，我们更新了硬件设备驱动，请及时更新',
                      style: TextStyle(fontSize: 17, color: Color(0xFF222B45), height: 1.7),
                      textAlign: TextAlign.center,
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