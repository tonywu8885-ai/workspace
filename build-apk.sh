#!/bin/bash
# 周报工作台安卓 APK 构建脚本
# 使用前请先安装 JDK 17 和 Android SDK

set -e

echo "=== 周报工作台 APK 构建脚本 ==="

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "❌ 未找到 Java，正在安装 JDK 17..."
    brew install openjdk@17
    echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
    export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
fi

# 检查 Android SDK
if [ -z "$ANDROID_HOME" ]; then
    echo "❌ 未设置 ANDROID_HOME，正在安装 Android SDK..."
    brew install --cask android-commandlinetools
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"
    echo 'export ANDROID_HOME="$HOME/Library/Android/sdk"' >> ~/.zshrc
    echo 'export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools"' >> ~/.zshrc
    yes | sdkmanager --licenses
    sdkmanager "platforms;android-34" "build-tools;34.0.0"
fi

echo "✅ 环境检查完成"
echo "Java: $(java -version 2>&1 | head -1)"
echo "Android SDK: $ANDROID_HOME"

# 同步 Capacitor
echo "=== 同步 Capacitor ==="
npx cap sync android

# 构建 APK
echo "=== 构建 APK ==="
cd android
./gradlew assembleDebug

# 复制 APK 到项目根目录
APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
if [ -f "$APK_PATH" ]; then
    cp "$APK_PATH" "../周报工作台-debug.apk"
    echo ""
    echo "✅ APK 构建成功！"
    echo "📦 文件位置: $(pwd)/../周报工作台-debug.apk"
    echo "📱 安装方式: adb install 周报工作台-debug.apk"
else
    echo "❌ APK 构建失败，请检查错误信息"
    exit 1
fi
