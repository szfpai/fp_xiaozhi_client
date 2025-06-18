#!/bin/bash

echo "🚀 启动小智客户端..."

# 检查Flutter是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter未安装，请先安装Flutter SDK"
    echo "📖 安装指南: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# 检查Flutter版本
echo "📱 Flutter版本: $(flutter --version | head -n 1)"

# 获取依赖
echo "📦 安装依赖..."
flutter pub get

# 检查设备
echo "🔍 检查可用设备..."
flutter devices

echo ""
echo "🎯 选择运行方式:"
echo "1. 运行在模拟器/设备上 (flutter run)"
echo "2. 运行在Web浏览器 (flutter run -d chrome)"
echo "3. 运行在macOS (flutter run -d macos)"
echo "4. 构建APK (flutter build apk)"
echo "5. 退出"

read -p "请输入选择 (1-5): " choice

case $choice in
    1)
        echo "🚀 启动应用..."
        flutter run
        ;;
    2)
        echo "🌐 启动Web版本..."
        flutter run -d chrome
        ;;
    3)
        echo "🖥️ 启动macOS版本..."
        flutter run -d macos
        ;;
    4)
        echo "📱 构建APK..."
        flutter build apk
        echo "✅ APK构建完成，位置: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    5)
        echo "👋 再见！"
        exit 0
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac 