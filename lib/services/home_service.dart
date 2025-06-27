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
        Uri.parse('${AppConfig.baseUrl}/xiaozhi/agent/list?page=$page&pageSize=$pageSize');

    print('=== HomeService.getAgents 开始 ===');
    print('请求URL: $url');

    // 构建headers，包含Content-Type和可选的Authorization token
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    // 从AuthService获取token
    print('正在获取token...');
    final token = await authService.getToken();
    print('获取到的token: ${token != null ? '已获取' : '未获取'}');
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      print('已添加Authorization header');
    } else {
      // 用户未登录，直接返回mock数据
      print('用户未登录，返回mock数据');
      return getMockAgents();
    }

    try {
      print('发送HTTP请求...');
      final response = await http.get(url, headers: headers);
      print('响应状态码: ${response.statusCode}');
      print('响应头: ${response.headers}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('响应数据: $data');
        
        if (data['msg'] == 'success' && data['data'] is List) {
          final agents = (data['data'] as List)
              .map((item) => Agent.fromJson(item))
              .toList();
          print('成功解析 ${agents.length} 个Agent');
          return agents;
        } else {
          throw Exception('API返回数据格式错误: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        // 认证失败，可能是token过期
        print('认证失败 (401)，返回mock数据');
        print('响应体: ${response.body}');
        return getMockAgents();
      } else {
        // 网络请求失败，返回mock数据以便测试
        print('网络请求失败: ${response.statusCode}, 返回mock数据');
        print('响应体: ${response.body}');
        return getMockAgents();
      }
    } catch (e) {
      print('捕获到异常: $e, 返回mock数据');
      return getMockAgents();
    } finally {
      print('=== HomeService.getAgents 结束 ===');
    }
  }

  Future<Map<String, dynamic>> addAgent({
    required String agentName,
  }) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/agents');
    final token = await authService.getToken();

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': '用户未登录'};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'agent_name': agentName}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return {'success': true, 'message': '创建成功'};
        } else {
          return {'success': false, 'message': responseData['message'] ?? '创建失败'};
        }
      } else {
        return {'success': false, 'message': '服务器错误: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': '网络请求失败: $e'};
    }
  }

  Future<Agent?> getAgentDetails(String agentId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/agents/$agentId');
    final token = await authService.getToken();

    if (token == null || token.isEmpty) {
      //return getMockAgent();
      throw Exception('用户未登录');
    }

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          return Agent.fromJson(responseData['data']);
        }
      }
      return null; // or throw an exception
    } catch (e) {
      print('获取Agent详情失败: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateAgent(Agent agent) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/agents/${agent.id}');
    final token = await authService.getToken();

    if (token == null || token.isEmpty) {
      return {'success': false, 'message': '用户未登录'};
    }

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(agent.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {'success': responseData['success'], 'message': responseData['message'] ?? '更新成功'};
      } else {
        return {'success': false, 'message': '服务器错误: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': '网络请求失败: $e'};
    }
  }
}

