# 国际化支持 (Internationalization)

本项目已支持中英文双语切换功能。

## 功能特性

- ✅ 支持中文和英文两种语言
- ✅ 实时语言切换，无需重启应用
- ✅ 语言设置持久化保存
- ✅ 登录和注册页面完全国际化
- ✅ 优雅的语言切换器UI

## 使用方法

### 1. 切换语言

在应用的任何页面的右上角，点击语言图标 🌐 即可切换语言：
- 🇨🇳 中文
- 🇺🇸 English

### 2. 语言设置

语言设置会自动保存到本地存储，下次启动应用时会使用上次选择的语言。

## 技术实现

### 文件结构

```
lib/
├── l10n/
│   ├── app_en.arb          # 英文语言文件
│   └── app_zh.arb          # 中文语言文件
├── services/
│   └── language_service.dart    # 语言管理服务
├── widgets/
│   └── language_switcher.dart   # 语言切换器组件
└── screens/
    ├── login_screen.dart        # 登录页面（已国际化）
    └── register_screen.dart     # 注册页面（已国际化）
```

### 核心组件

1. **LanguageService**: 管理应用语言状态
   - 使用 Provider 进行状态管理
   - 支持语言持久化存储
   - 提供语言切换方法

2. **LanguageSwitcher**: 语言切换器组件
   - 美观的下拉菜单设计
   - 显示当前语言状态
   - 支持中英文切换

3. **国际化文件**: ARB 格式的语言文件
   - `app_en.arb`: 英文翻译
   - `app_zh.arb`: 中文翻译

### 添加新的国际化字符串

1. 在 `lib/l10n/app_en.arb` 中添加英文字符串：
```json
{
  "newString": "New String",
  "@newString": {
    "description": "Description for the new string"
  }
}
```

2. 在 `lib/l10n/app_zh.arb` 中添加中文翻译：
```json
{
  "newString": "新字符串"
}
```

3. 运行命令生成国际化文件：
```bash
flutter gen-l10n
```

4. 在代码中使用：
```dart
final l10n = AppLocalizations.of(context)!;
Text(l10n.newString)
```

### 依赖项

项目使用了以下依赖来实现国际化：

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.1
  shared_preferences: ^2.2.2
```

## 扩展支持

### 添加更多语言

1. 创建新的语言文件，如 `app_ja.arb`（日语）
2. 在 `main.dart` 的 `supportedLocales` 中添加新语言
3. 在 `LanguageSwitcher` 中添加新的语言选项

### 自动语言检测

可以扩展 `LanguageService` 来支持：
- 系统语言自动检测
- 地理位置语言推荐
- 用户偏好语言记忆

## 注意事项

- 所有用户可见的文本都应该使用国际化字符串
- 避免在代码中硬编码任何语言相关的文本
- 定期更新语言文件以保持翻译的准确性
- 测试不同语言下的UI布局适配性 