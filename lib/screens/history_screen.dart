import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  final int agentId;

  const HistoryScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史对话'),
        backgroundColor: const Color(0xFFED8936),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '正在查看 Agent ID: $agentId 的历史对话',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 