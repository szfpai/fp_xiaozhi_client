import 'package:flutter/material.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            // 账号信息
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
                child: Row(
                  children: [
                    const Text('账号：', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text('fp_hero', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Token统计
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Token统计', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const Text('Token总额：100000', style: TextStyle(fontSize: 17)),
                      ),
                    ),
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: const Text('Token消耗：8000', style: TextStyle(fontSize: 17)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          side: const BorderSide(color: Color(0xFF764BA2), width: 2),
                        ),
                        onPressed: () {},
                        child: const Text('购买token', style: TextStyle(fontSize: 17, color: Color(0xFF764BA2), fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 其它操作
            _buildMenuButton('升级更新', onTap: () {}),
            _buildMenuButton('关于我们', onTap: () {}),
            _buildMenuButton('重置密码', onTap: () {}),
            _buildMenuButton('退出登陆', onTap: () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF764BA2),
          elevation: 2,
          side: const BorderSide(color: Color(0xFF764BA2), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        onPressed: onTap,
        child: Text(text),
      ),
    );
  }
} 