import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../data/template.dart';
import 'auth_service.dart';

class TemplateService {
  final AuthService authService;

  TemplateService({required this.authService});

  Future<List<Template>> getTemplates() async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/roles/templates');
    final token = authService.token;

    if (token == null || token.isEmpty) {
      // 根据你的业务逻辑，可以抛出异常或返回空列表/mock数据
      throw Exception('用户未登录，无法获取模板');
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data']['templates'] is List) {
          final List<dynamic> templateData = responseData['data']['templates'];
          return templateData.map((json) => Template.fromJson(json)).toList();
        } else {
          throw Exception('获取模板失败: ${responseData['message']}');
        }
      } else {
        throw Exception('服务器错误: ${response.statusCode}');
      }
    } catch (e) {
      print('获取模板时发生网络错误: $e');
      rethrow; // 将异常重新抛出，让调用方处理
    }
  }
}
