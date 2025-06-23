import 'package:flutter/material.dart';

class DeviceBindingScreen extends StatelessWidget {
  final int agentId;

  const DeviceBindingScreen({Key? key, required this.agentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('绑定设备'),
        backgroundColor: const Color(0xFF9F7AEA),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          '正在为 Agent ID: $agentId 绑定设备',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 