import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/model.dart';
import 'auth_service.dart';

class ModelInfo {
  final String id;
  final String modelName;
  ModelInfo({required this.id, required this.modelName});
  factory ModelInfo.fromJson(Map<String, dynamic> json) {
    return ModelInfo(
      id: json['id']?.toString() ?? '',
      modelName: json['modelName'] ?? '',
    );
  }
}

class ModelService {
  final AuthService authService;

  ModelService({required this.authService});

  /// Fetches the list of available AI models from the backend.
  Future<List<Model>> getModels() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final url = Uri.parse('${AppConfig.baseUrl}/api/roles/model-list');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> modelsJson = responseData['data']['modelList'] ?? [];
      return modelsJson.map((json) => Model.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load models: ${response.body}');
    }
  }

  /// Gets the recommended model (first one with "推荐" in description)
  Future<Model?> getRecommendedModel() async {
    final models = await getModels();
    try {
      return models.firstWhere((model) => model.isRecommended);
    } catch (e) {
      // If no recommended model found, return the first one
      return models.isNotEmpty ? models.first : null;
    }
  }

  /// Gets a model by name
  Future<Model?> getModelByName(String name) async {
    final models = await getModels();
    try {
      return models.firstWhere((model) => model.name == name);
    } catch (e) {
      return null;
    }
  }

  /// 根据类型和名称获取模型列表
  Future<List<ModelInfo>> getModelByType({required String modelType, String? modelName}) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }
    final url = Uri.parse('${AppConfig.baseUrl}/xiaozhi/models/names');
    final body = jsonEncode({
      'modelType': modelType,
      if (modelName != null) 'modelName': modelName,
    });
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      if (responseData['code'] == 0) {
        final List<dynamic> list = responseData['data'] ?? [];
        return list.map((e) => ModelInfo.fromJson(e)).toList();
      } else {
        throw Exception('接口返回错误: \\${responseData['msg']}');
      }
    } else {
      throw Exception('Failed to load model names: ${response.body}');
    }
  }
} 