import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_config.dart';

/// 配置使用示例
/// 这个文件展示了如何在不同的服务中使用全局配置
class ConfigUsageExample {
  
  /// 示例：使用全局配置进行API调用
  static Future<Map<String, dynamic>> apiCallExample() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/example'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(AppConfig.apiTimeout);
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API调用失败: ${response.statusCode}');
      }
    } catch (e) {
      if (AppConfig.enableVerboseLogging) {
        print('API调用错误: $e');
      }
      rethrow;
    }
  }
  
  /// 示例：根据环境显示不同的调试信息
  static void debugLog(String message) {
    if (AppConfig.isDebugMode) {
      print('[$environmentName] $message');
    }
  }
  
  /// 示例：根据环境配置不同的重试策略
  static Future<T> retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < AppConfig.maxRetryAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= AppConfig.maxRetryAttempts) {
          rethrow;
        }
        
        if (AppConfig.enableVerboseLogging) {
          print('操作失败，${AppConfig.retryDelay.inSeconds}秒后重试 (${attempts}/${AppConfig.maxRetryAttempts})');
        }
        
        await Future.delayed(AppConfig.retryDelay);
      }
    }
    throw Exception('操作失败，已达到最大重试次数');
  }
  
  /// 示例：根据环境配置不同的缓存策略
  static Duration getCacheDuration() {
    switch (AppConfig.environment) {
      case Environment.development:
        return const Duration(minutes: 5); // 开发环境缓存时间短
      case Environment.testing:
        return const Duration(hours: 1);   // 测试环境中等缓存时间
      case Environment.production:
        return AppConfig.cacheExpiration;  // 生产环境使用标准缓存时间
    }
  }
  
  /// 示例：根据环境配置不同的安全策略
  static Map<String, String> getSecurityHeaders() {
    final headers = {'Content-Type': 'application/json'};
    
    if (AppConfig.enableSSL) {
      headers['X-Forwarded-Proto'] = 'https';
    }
    
    if (AppConfig.environment == Environment.production) {
      headers['X-Content-Type-Options'] = 'nosniff';
      headers['X-Frame-Options'] = 'DENY';
      headers['X-XSS-Protection'] = '1; mode=block';
    }
    
    return headers;
  }
  
  /// 获取当前环境名称
  static String get environmentName => AppConfig.environmentName;
} 