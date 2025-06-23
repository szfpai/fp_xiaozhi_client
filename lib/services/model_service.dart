import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../data/model.dart';
import 'auth_service.dart';

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
} 