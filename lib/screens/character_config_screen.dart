import 'package:flutter/material.dart';

class CharacterConfigScreen extends StatelessWidget {
  final int agentId;

  const CharacterConfigScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('配置角色'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '正在为 Agent ID: $agentId 配置角色',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 