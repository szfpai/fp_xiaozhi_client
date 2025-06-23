import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../config/app_config.dart';
import '../data/agent.dart';
import '../mock/home_mock.dart';

class HomeService extends ChangeNotifier {
  final AuthService authService;

  HomeService({required this.authService});

  Future<List<Agent>> getAgents({int page = 1, int pageSize = 24}) async {
    final url =
        Uri.parse('${AppConfig.baseUrl}/api/agents?page=$page&pageSize=$pageSize');

    // 构建headers，包含Content-Type和可选的Authorization token
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // 从AuthService获取token
    final token = authService.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List)
              .map((item) => Agent.fromJson(item))
              .toList();
        } else {
          throw Exception('API返回数据格式错误: ${data['message']}');
        }
      } else {
        // 网络请求失败，返回mock数据以便测试
        print('网络请求失败: ${response.statusCode}, 返回mock数据');
        return HomeMock.getAgents();
      }
    } catch (e) {
      print('捕获到异常: $e, 返回mock数据');
      return HomeMock.getAgents();
    }
  }
}

