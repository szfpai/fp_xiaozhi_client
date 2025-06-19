# 全局配置系统

这个目录包含了应用的全局配置管理，提供了统一的配置接口和环境管理功能。

## 文件结构

- `app_config.dart` - 主要的配置文件，包含所有全局配置参数
- `config_usage_example.dart` - 配置使用示例
- `README.md` - 本说明文件

## 主要功能

### 1. 环境配置
支持三种环境：
- **开发环境 (development)** - 本地开发使用
- **测试环境 (testing)** - 测试服务器使用  
- **生产环境 (production)** - 正式服务器使用

### 2. 动态URL配置
根据当前环境自动选择对应的API基础URL：
- 开发环境: `http://localhost:8002`
- 测试环境: `http://test-api.xiaozhi.com`
- 生产环境: `https://api.xiaozhi.com`

### 3. 其他配置参数
- API超时时间
- 重试策略
- 缓存配置
- 安全配置
- 功能开关
- 调试模式

## 使用方法

### 基本使用

```dart
import 'package:your_app/config/app_config.dart';

// 获取基础URL
String apiUrl = AppConfig.baseUrl;

// 获取超时时间
Duration timeout = AppConfig.apiTimeout;

// 检查是否为调试模式
bool isDebug = AppConfig.isDebugMode;
```

### 在服务中使用

```dart
import '../config/app_config.dart';

class YourService {
  Future<void> apiCall() async {
    final response = await http.get(
      Uri.parse('${AppConfig.baseUrl}/your/api/endpoint'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(AppConfig.apiTimeout);
    
    // 处理响应...
  }
}
```

### 环境相关配置

```dart
// 根据环境显示不同的调试信息
if (AppConfig.isDebugMode) {
  print('调试信息: $message');
}

// 获取环境名称
String envName = AppConfig.environmentName;
```

## 切换环境

要切换环境，只需修改 `app_config.dart` 中的 `environment` 常量：

```dart
// 开发环境
static const Environment environment = Environment.development;

// 测试环境  
static const Environment environment = Environment.testing;

// 生产环境
static const Environment environment = Environment.production;
```

## 添加新配置

在 `AppConfig` 类中添加新的配置参数：

```dart
class AppConfig {
  // 现有配置...
  
  // 添加新配置
  static const String newFeatureFlag = 'enabled';
  static const int newTimeout = 30;
  
  // 或者根据环境动态配置
  static String get dynamicConfig {
    switch (environment) {
      case Environment.development:
        return 'dev_value';
      case Environment.testing:
        return 'test_value';
      case Environment.production:
        return 'prod_value';
    }
  }
}
```

## 最佳实践

1. **统一配置管理**: 所有配置参数都应该在 `AppConfig` 中定义
2. **环境隔离**: 不同环境使用不同的配置值
3. **类型安全**: 使用强类型定义配置参数
4. **文档化**: 为每个配置参数添加注释说明
5. **版本控制**: 敏感配置不应该提交到版本控制系统

## 注意事项

- 修改环境配置后需要重新编译应用
- 生产环境的配置应该经过充分测试
- 敏感信息（如API密钥）应该使用环境变量或安全存储 