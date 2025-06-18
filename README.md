# 小智客户端

一个基于Flutter框架的跨平台用户认证应用，支持Android、iOS和macOS平台。

## 功能特性

- 🔐 用户注册和登录
- 🖼️ 图片验证码验证
- 📱 跨平台支持 (Android, iOS, macOS)
- 🎨 现代化UI设计
- 🔒 安全存储用户信息
- 📊 状态管理 (Provider)

## 技术栈

- **框架**: Flutter 3.0+
- **状态管理**: Provider
- **网络请求**: HTTP
- **本地存储**: SharedPreferences, Flutter Secure Storage
- **UI组件**: Material Design 3

## 项目结构

```
lib/
├── main.dart              # 应用入口
├── screens/               # 页面
│   ├── login_screen.dart  # 登录页面
│   ├── register_screen.dart # 注册页面
│   └── home_screen.dart   # 主页面
├── services/              # 服务
│   └── auth_service.dart  # 认证服务
├── models/                # 数据模型
├── widgets/               # 自定义组件
└── utils/                 # 工具类
```

## 安装和运行

### 前置要求

- Flutter SDK 3.0+
- Dart SDK 2.19+
- Android Studio / VS Code
- Xcode (用于iOS开发)
- Android SDK (用于Android开发)

### 安装步骤

1. 确保Flutter环境已正确安装
   ```bash
   flutter doctor
   ```

2. 进入项目目录
   ```bash
   cd xiaozhi_client
   ```

3. 安装依赖
   ```bash
   flutter pub get
   ```

4. 运行应用
   ```bash
   # 运行在模拟器/设备上
   flutter run

   # 运行在Web浏览器
   flutter run -d chrome

   # 运行在macOS
   flutter run -d macos
   ```

## 主要功能说明

### 用户注册
- 用户名验证（至少3位）
- 邮箱格式验证
- 密码强度验证（至少6位）
- 密码确认验证
- 图片验证码验证

### 用户登录
- 用户名和密码验证
- 自动登录状态检查
- 登录状态持久化

### 图片验证码
- 自动生成4位随机验证码
- 包含干扰线增加安全性
- 支持点击刷新
- 大小写不敏感验证

### 安全特性
- 密码安全存储
- Token管理
- 自动登录状态恢复
- 安全登出

## 开发说明

### API配置
当前使用模拟API，实际使用时需要修改 `lib/services/auth_service.dart` 中的 `baseUrl` 为真实的API地址。

### 自定义主题
可以在 `lib/main.dart` 中修改 `ThemeData` 来自定义应用主题。

### 添加新功能
1. 在 `lib/screens/` 中创建新页面
2. 在 `lib/services/` 中添加相关服务
3. 更新路由配置

## 构建发布版本

```bash
# 构建Android APK
flutter build apk

# 构建iOS应用
flutter build ios

# 构建macOS应用
flutter build macos

# 构建Web版本
flutter build web
```

## 注意事项

1. 确保所有依赖都已正确安装
2. 检查Flutter环境配置
3. 确保模拟器或设备已连接
4. 首次运行可能需要较长时间

## 故障排除

如果遇到编译错误，请尝试：
1. 清理项目：`flutter clean`
2. 重新获取依赖：`flutter pub get`
3. 重新运行：`flutter run`

## 许可证

本项目采用 MIT 许可证。
