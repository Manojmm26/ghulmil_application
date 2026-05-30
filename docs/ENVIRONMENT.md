# Environment Setup Guide

## Overview

This guide provides comprehensive instructions for setting up the development environment for the Ghulmil Application. Follow these steps to get your development environment ready for Flutter development.

## 🖥️ System Requirements

### Minimum Requirements
- **Operating System**: Windows 10+, macOS 10.15+, Linux (Ubuntu 18.04+)
- **RAM**: 8 GB minimum (16 GB recommended)
- **Storage**: 10 GB free space
- **Internet**: Required for Flutter installation and dependencies

### Recommended Specifications
- **RAM**: 16 GB or more
- **Processor**: Multi-core CPU (Intel i5 or equivalent)
- **Storage**: SSD with 20+ GB free space
- **Graphics**: Dedicated GPU for better performance

## 🛠️ Development Tools Installation

### 1. Flutter SDK Installation

#### Option A: Official Installation (Recommended)

**Windows:**
```bash
# Download Flutter SDK
# Extract to C:\src\flutter
# Add to PATH: C:\src\flutter\bin

# Verify installation
flutter --version
flutter doctor
```

**macOS:**
```bash
# Download Flutter SDK
# Extract to ~/development/flutter
# Add to PATH: ~/development/flutter/bin

# Verify installation
flutter --version
flutter doctor
```

**Linux:**
```bash
# Download Flutter SDK
# Extract to ~/development/flutter
# Add to PATH: ~/development/flutter/bin

# Verify installation
flutter --version
flutter doctor
```

#### Option B: Using Package Managers

**macOS (Homebrew):**
```bash
brew tap leoafarias/fvm
brew install fvm
fvm install stable
fvm use stable
```

**Linux (Snap):**
```bash
sudo snap install flutter --classic
```

### 2. IDE Installation

#### Visual Studio Code (Recommended)
1. **Download**: https://code.visualstudio.com/
2. **Install Extensions**:
   - Flutter (official)
   - Dart
   - Awesome Flutter Snippets
   - Flutter Widget Snippets
   - Bracket Pair Colorizer 2
   - Error Lens

#### Android Studio
1. **Download**: https://developer.android.com/studio
2. **Install Flutter Plugin**:
   - Go to File > Settings > Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

#### IntelliJ IDEA
1. **Download**: https://www.jetbrains.com/idea/
2. **Install Flutter Plugin**:
   - Go to File > Settings > Plugins
   - Search for "Flutter" and install
   - Restart IntelliJ

### 3. Android Development Setup

#### Android Studio and SDK
1. **Install Android Studio** (if not already installed)
2. **Install Android SDK**:
   - Open Android Studio
   - Go to Tools > SDK Manager
   - Select Android 12.0 (API 31) or higher
   - Install necessary tools and emulator images

#### Environment Variables (Windows)
```batch
# Add to system PATH
ANDROID_HOME=C:\Users\[USERNAME]\AppData\Local\Android\Sdk
JAVA_HOME=C:\Program Files\Java\jdk-[VERSION]

# Add to PATH
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\tools
%ANDROID_HOME%\tools\bin
```

#### Environment Variables (macOS/Linux)
```bash
# Add to ~/.bashrc or ~/.zshrc
export ANDROID_HOME=$HOME/Android/Sdk
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-[VERSION].jdk/Contents/Home
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
```

### 4. iOS Development Setup (macOS only)

#### Xcode Installation
1. **Download Xcode** from Mac App Store
2. **Install Command Line Tools**:
   ```bash
   xcode-select --install
   ```

#### iOS Simulator
1. **Open Xcode** after installation
2. **Install iOS Simulator**:
   - Go to Xcode > Preferences > Components
   - Install desired iOS versions

#### CocoaPods Installation
```bash
sudo gem install cocoapods
pod setup
```

### 5. Web Development Setup

#### Chrome Browser
1. **Download Chrome**: https://www.google.com/chrome/
2. **Enable Developer Tools**:
   - Press F12 or right-click > Inspect
   - Enable "Experiments" in Settings

#### Web-Specific Dependencies
```bash
# Chrome DevTools Protocol
flutter pub global activate webdev

# For debugging
flutter pub global activate devtools
```

### 6. Desktop Development Setup

#### Windows Desktop
1. **Install Visual Studio 2022** with C++ workload
2. **Install Windows SDK** (included with Visual Studio)

#### macOS Desktop
1. **Xcode** already includes necessary tools
2. **Install CMake**:
   ```bash
   brew install cmake
   ```

#### Linux Desktop
1. **Install required libraries**:
   ```bash
   sudo apt update
   sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

## 🔧 Project-Specific Setup

### 1. Clone and Setup Project
```bash
# Clone the repository
git clone <repository-url>
cd ghulmil_application

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Verify setup
flutter doctor
flutter analyze
```

### 2. Environment Configuration

#### Create Environment Files
Create `.env.development`:
```
API_BASE_URL=http://localhost:3000
FIREBASE_API_KEY=your_dev_api_key
STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_key
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

Create `.env.production`:
```
API_BASE_URL=https://api.ghulmil.com
FIREBASE_API_KEY=your_prod_api_key
STRIPE_PUBLISHABLE_KEY=pk_live_your_stripe_key
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
```

#### Environment Setup in Flutter
```dart
// lib/core/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('dart.vm.production');

  static String get apiBaseUrl {
    if (isProduction) {
      return const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.ghulmil.com');
    }
    return const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
  }
}
```

### 3. Device Setup

#### Android Emulator Setup
1. **Open Android Studio**
2. **Go to AVD Manager** (Tools > AVD Manager)
3. **Create Virtual Device**:
   - Choose Pixel 4 or similar
   - Select system image (API 30+)
   - Configure memory and storage
   - Start emulator

#### iOS Simulator Setup
1. **Open Xcode**
2. **Go to Window > Devices and Simulators**
3. **Add Simulator**:
   - Click "+" button
   - Select iOS version and device
   - Click "Create"

#### Physical Device Setup
**Android:**
1. **Enable Developer Options**
2. **Enable USB Debugging**
3. **Connect device via USB**
4. **Accept USB debugging authorization**

**iOS:**
1. **Connect iPhone via USB**
2. **Trust computer on iPhone**
3. **Select device in Xcode or Flutter**

### 4. Testing Environment

#### Install Test Dependencies
```bash
# Install coverage tools
flutter pub global activate test_cov_console

# Install test utilities
flutter pub global activate peanut
```

#### Setup Test Configuration
Create `test/test_config.dart`:
```dart
// Test configuration
const testConfig = {
  'api_base_url': 'http://localhost:3000',
  'mock_server_port': 8080,
  'test_timeout': Duration(seconds: 30),
};
```

## 🚀 First Run

### 1. Verify Flutter Installation
```bash
# Check Flutter installation
flutter --version
flutter doctor

# Expected output:
# Flutter 3.9.2 • channel stable
# Framework • revision
# Engine • revision
# Tools • Dart 3.0.0
```

### 2. Run the Application
```bash
# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run on connected device/emulator
flutter run

# Run on specific device
flutter run -d [DEVICE_ID]

# Run on web
flutter run -d chrome

# Run on desktop
flutter run -d windows  # or macos, linux
```

### 3. Common First-Run Issues

#### Issue: No Devices Found
**Solutions**:
1. **Start emulator**: `flutter emulators --launch [EMULATOR_ID]`
2. **Connect physical device**: Enable USB debugging
3. **Install web support**: `flutter config --enable-web`

#### Issue: Build Failed
**Solutions**:
1. **Clean project**: `flutter clean && flutter pub get`
2. **Check dependencies**: `flutter pub outdated`
3. **Update dependencies**: `flutter pub upgrade`

#### Issue: Code Generation Failed
**Solutions**:
1. **Clean build runner**: `flutter pub run build_runner clean`
2. **Rebuild**: `flutter pub run build_runner build --delete-conflicting-outputs`
3. **Check for circular dependencies**

## 🔧 Development Workflow

### 1. Code Generation
```bash
# Generate code for all files
flutter pub run build_runner build

# Watch mode for development
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner clean
```

### 2. Testing
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/unit/models/user_test.dart

# Run widget tests
flutter test --tags widget
```

### 3. Code Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Fix linting issues
flutter fix --dry-run
```

### 4. Performance Monitoring
```bash
# Profile the app
flutter run --profile

# Use DevTools
flutter pub global run devtools

# Memory profiling
flutter run --debug --observatory-port 9200
```

## 📱 Platform-Specific Configuration

### Android Configuration
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "com.ghulmil.application"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### iOS Configuration
```xml
<!-- ios/Runner/Info.plist -->
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>https</string>
    <string>http</string>
</array>
```

### Web Configuration
```html
<!-- web/index.html -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="description" content="Ghulmil Application - Service Booking Platform">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ghulmil Application</title>
    <base href="/">
</head>
<body>
    <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

## 🐛 Troubleshooting Common Issues

### Issue: Flutter Command Not Found
**Solution**:
```bash
# Check PATH
echo $PATH

# Add Flutter to PATH
export PATH="$PATH:[FLUTTER_PATH]/bin"

# Make permanent
echo 'export PATH="$PATH:[FLUTTER_PATH]/bin"' >> ~/.bashrc
```

### Issue: Android License Issues
**Solution**:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Or manually accept
yes | flutter doctor --android-licenses
```

### Issue: iOS Build Issues
**Solution**:
```bash
# Clean iOS build
cd ios
rm -rf build/
pod cache clean --all
pod install

# Clean Flutter
flutter clean
flutter pub get
```

### Issue: Web Build Issues
**Solution**:
```bash
# Enable web
flutter config --enable-web

# Clean and rebuild
flutter clean
flutter create . --platforms web
flutter pub get
```

## 📊 Environment Verification

### Flutter Doctor Output
```bash
# Run flutter doctor
flutter doctor

# Expected output:
# [✓] Flutter (Channel stable, 3.9.2, on macOS 13.0 22A380, locale en-US)
# [✓] Android toolchain - develop for Android devices (Android SDK version 33.0.0)
# [✓] Xcode - develop for iOS and macOS (Xcode 14.2)
# [✓] Chrome - develop for the web
# [✓] Android Studio (version 2022.1)
# [✓] VS Code (version 1.75.1)
# [✓] Connected device (3 available)
# [✓] HTTP Host Availability
```

### Project-Specific Checks
```bash
# Check dependencies
flutter pub list

# Check for outdated packages
flutter pub outdated

# Check code generation
flutter pub run build_runner build --dry-run

# Check test environment
flutter test --version
```

## 🚀 Advanced Setup

### 1. CI/CD Environment
```yaml
# GitHub Actions example
- name: Setup Flutter
  uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.9.2'

- name: Install dependencies
  run: flutter pub get

- name: Run tests
  run: flutter test
```

### 2. Docker Environment
```dockerfile
FROM cirrusci/flutter:latest

WORKDIR /app
COPY pubspec.yaml .
RUN flutter pub get

COPY . .
RUN flutter pub run build_runner build

CMD ["flutter", "test"]
```

### 3. Multiple Flutter Versions
```bash
# Using FVM (Flutter Version Management)
fvm install 3.9.2
fvm use 3.9.2
fvm global 3.9.2
```

## 📞 Support and Resources

### Getting Help
1. **Flutter Documentation**: https://docs.flutter.dev/
2. **Stack Overflow**: https://stackoverflow.com/questions/tagged/flutter
3. **Flutter Community**: https://flutter.dev/community
4. **GitHub Issues**: Project repository issues

### Common Commands Reference
```bash
# Development
flutter run                     # Run app
flutter test                    # Run tests
flutter analyze                 # Analyze code
flutter format .                # Format code

# Building
flutter build apk               # Build Android APK
flutter build ios               # Build iOS app
flutter build web               # Build web app
flutter build windows           # Build Windows app

# Code Generation
flutter pub run build_runner build
flutter pub run build_runner watch

# Dependencies
flutter pub get                 # Install dependencies
flutter pub upgrade             # Upgrade dependencies
flutter pub outdated            # Check outdated packages
```

### Environment Variables Reference
```bash
# Flutter
FLUTTER_ROOT                    # Flutter installation path
PUB_CACHE                       # Pub cache directory

# Android
ANDROID_HOME                    # Android SDK path
ANDROID_SDK_ROOT                # Android SDK root
JAVA_HOME                       # Java installation path

# iOS
DEVELOPER_DIR                   # Xcode developer directory
```

## 📋 Final Checklist

### Development Environment
- [ ] Flutter SDK installed and configured
- [ ] IDE with Flutter extensions installed
- [ ] Android/iOS development tools configured
- [ ] Web/desktop development enabled (if needed)
- [ ] Project dependencies installed
- [ ] Code generation working
- [ ] Tests running successfully

### Device/Emulator Setup
- [ ] Android emulator configured
- [ ] iOS simulator available (macOS)
- [ ] Physical devices connected (optional)
- [ ] Web browser ready for testing

### Project Configuration
- [ ] Environment variables set up
- [ ] API endpoints configured
- [ ] Build configurations ready
- [ ] Testing environment working

---

**Next Steps**: Once your environment is set up, proceed to the [Getting Started](README.md) guide to begin development.
