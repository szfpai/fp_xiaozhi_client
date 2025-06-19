enum Environment {
  development,
  testing,
  production,
}

class AppConfig {
  // 当前环境配置
  static const Environment environment = Environment.development;
  
  // API基础URL配置 - 根据环境动态配置
  static String get baseUrl {
    switch (environment) {
      case Environment.development:
        return 'http://localhost:8002';
      case Environment.testing:
        return 'http://test-api.xiaozhi.com';
      case Environment.production:
        return 'https://api.xiaozhi.com';
    }
  }
  
  // API超时时间配置
  static const Duration apiTimeout = Duration(seconds: 10);
  
  // 应用版本信息
  static const String appVersion = '1.0.0';
  static const String appName = '小智客户端';
  
  // 其他全局配置参数
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // 调试模式配置
  static bool get isDebugMode => environment == Environment.development;
  
  // 日志级别配置
  static bool get enableVerboseLogging => isDebugMode;
  
  // 缓存配置
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 100; // MB
  
  // 安全配置
  static const bool enableSSL = true;
  static const bool enableCertificatePinning = false; // 生产环境建议开启
  
  // 功能开关
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  
  // 获取环境名称
  static String get environmentName {
    switch (environment) {
      case Environment.development:
        return '开发环境';
      case Environment.testing:
        return '测试环境';
      case Environment.production:
        return '生产环境';
    }
  }
} 