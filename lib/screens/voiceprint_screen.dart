import 'package:flutter/material.dart';

class VoiceprintScreen extends StatelessWidget {
  final int agentId;

  const VoiceprintScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('声纹识别'),
        backgroundColor: const Color(0xFF48BB78),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '正在为 Agent ID: $agentId 进行声纹识别',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 