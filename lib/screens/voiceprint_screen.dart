import 'package:flutter/material.dart';

class VoiceprintScreen extends StatefulWidget {
  final String agentId;
  const VoiceprintScreen({super.key, required this.agentId});

  @override
  State<VoiceprintScreen> createState() => _VoiceprintScreenState();
}

class _VoiceprintScreenState extends State<VoiceprintScreen> {
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
          '正在为 Agent ID: ${widget.agentId} 进行声纹识别',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 