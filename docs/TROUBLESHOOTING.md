# Troubleshooting Guide

## Overview

This guide helps diagnose and resolve common issues encountered during development, building, and deployment of the Ghulmil Application. Issues are organized by category with step-by-step solutions.

## 🏗️ Build Issues

### Flutter SDK Issues

#### Issue: Flutter command not found
**Symptoms**: `flutter: command not found` error

**Solutions**:
1. **Verify Flutter installation**:
   ```bash
   which flutter
   flutter --version
   ```

2. **Add Flutter to PATH**:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export PATH="$PATH:[PATH_TO_FLUTTER]/bin"
   source ~/.bashrc
   ```

3. **Reinstall Flutter**:
   ```bash
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

#### Issue: Incompatible Dart SDK version
**Symptoms**: Version solving failed or Dart SDK version mismatch

**Solutions**:
1. **Check current versions**:
   ```bash
   flutter --version
   dart --version
   ```

2. **Update Flutter SDK**:
   ```bash
   flutter upgrade
   flutter pub get
   ```

3. **Update pubspec.yaml**:
   ```yaml
   environment:
     sdk: '>=3.0.0 <4.0.0'
     flutter: ">=3.9.0"
   ```

### Dependency Issues

#### Issue: Pub get fails
**Symptoms**: `pub get failed` or dependency resolution errors

**Solutions**:
1. **Clean pub cache**:
   ```bash
   flutter pub cache clean
   flutter pub get
   ```

2. **Delete pubspec.lock**:
   ```bash
   rm pubspec.lock
   flutter pub get
   ```

3. **Check for dependency conflicts**:
   ```bash
   flutter pub deps
   ```

#### Issue: Build runner fails
**Symptoms**: Code generation errors or build_runner hanging

**Solutions**:
1. **Clean and regenerate**:
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Check for circular dependencies**:
   ```bash
   flutter pub run build_runner build --fail-on-severe
   ```

3. **Update build_runner**:
   ```bash
   flutter pub upgrade build_runner
   ```

## 📱 Platform-Specific Issues

### Android Issues

#### Issue: Android emulator won't start
**Symptoms**: Emulator fails to launch or shows black screen

**Solutions**:
1. **Check Android Studio**:
   - Verify HAXM is installed and running
   - Increase emulator RAM to 4GB
   - Use x86_64 system image

2. **Cold boot emulator**:
   ```bash
   flutter emulators --launch Pixel_4_API_30
   ```

3. **Use physical device**:
   ```bash
   flutter devices
   flutter run -d [DEVICE_ID]
   ```

#### Issue: Gradle sync fails
**Symptoms**: Gradle project sync failed

**Solutions**:
1. **Update Gradle**:
   ```bash
   cd android
   ./gradlew wrapper --gradle-version 7.6
   ```

2. **Clean Gradle cache**:
   ```bash
   cd android
   ./gradlew clean
   ./gradlew cleanBuildCache
   ```

3. **Update Android Gradle Plugin** in `android/build.gradle`:
   ```gradle
   dependencies {
       classpath 'com.android.tools.build:gradle:7.4.2'
   }
   ```

### iOS Issues

#### Issue: iOS simulator won't start
**Symptoms**: Simulator fails to launch or shows errors

**Solutions**:
1. **Reset simulator**:
   ```bash
   xcrun simctl erase all
   ```

2. **Check Xcode version**:
   ```bash
   xcodebuild -version
   ```

3. **Clean derived data**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

#### Issue: Code signing issues
**Symptoms**: Provisioning profile or certificate errors

**Solutions**:
1. **Check certificates**:
   - Open Keychain Access
   - Verify certificates are valid
   - Check expiration dates

2. **Recreate provisioning profiles**:
   - Go to Apple Developer Console
   - Regenerate profiles
   - Download and install

3. **Automatic signing**:
   ```bash
   # In Xcode: Project > Targets > Signing & Capabilities
   # Enable "Automatically manage signing"
   ```

## 🔧 Development Issues

### Code Generation Issues

#### Issue: Freezed models not generating
**Symptoms**: `Undefined class` errors for generated models

**Solutions**:
1. **Check build_runner**:
   ```bash
   flutter pub run build_runner build
   ```

2. **Verify Freezed installation**:
   ```bash
   flutter pub list | grep freezed
   ```

3. **Check model syntax**:
   ```dart
   // Ensure proper Freezed syntax
   @freezed
   abstract class User with _$User {
     const factory User({
       required String id,
       required String name,
     }) = _User;
   }
   ```

#### Issue: JSON serialization not working
**Symptoms**: `JsonSerializable` errors

**Solutions**:
1. **Add json_serializable dependency**:
   ```yaml
   dev_dependencies:
     json_serializable: ^6.11.1
   ```

2. **Update build.yaml**:
   ```yaml
   targets:
     $default:
       builders:
         json_serializable:
           options:
             explicit_to_json: true
   ```

### State Management Issues

#### Issue: Riverpod provider not updating
**Symptoms**: UI not reflecting state changes

**Solutions**:
1. **Check provider family usage**:
   ```dart
   // Wrong
   final provider = Provider((ref) => MyClass());

   // Correct
   final provider = Provider<MyClass>((ref) {
     return MyClass();
   });
   ```

2. **Verify widget rebuild**:
   ```dart
   class MyWidget extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final data = ref.watch(myProvider);
       return Text(data.toString());
     }
   }
   ```

3. **Check for provider dependencies**:
   ```dart
   final myProvider = Provider<String>((ref) {
     final otherData = ref.watch(otherProvider);
     return processData(otherData);
   });
   ```

## 🌐 Web-Specific Issues

### Issue: Web app not loading
**Symptoms**: Blank screen or JavaScript errors in browser

**Solutions**:
1. **Check browser console**:
   - Open Developer Tools (F12)
   - Check Console tab for errors
   - Look for missing assets or 404 errors

2. **Verify web configuration**:
   ```bash
   flutter config --enable-web
   flutter create . --platforms web
   ```

3. **Check index.html**:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
     <meta charset="UTF-8">
     <title>Ghulmil Application</title>
   </head>
   <body>
     <script src="main.dart.js"></script>
   </body>
   </html>
   ```

### Issue: Assets not loading in web
**Symptoms**: Images or fonts not displaying

**Solutions**:
1. **Check asset paths**:
   ```yaml
   flutter:
     assets:
       - assets/images/
       - assets/fonts/
   ```

2. **Use asset transformers**:
   ```yaml
   dev_dependencies:
     flutter_asset_transformer: ^1.0.0
   ```

3. **Verify asset paths in code**:
   ```dart
   Image.asset('assets/images/logo.png')
   ```

## 🔍 Performance Issues

### Issue: App running slowly
**Symptoms**: Slow animations, high memory usage

**Solutions**:
1. **Check performance with DevTools**:
   ```bash
   flutter run --profile
   # Open in browser: chrome://inspect
   ```

2. **Monitor memory usage**:
   ```dart
   import 'dart:developer';
   MemoryUsage.record('start');
   // ... code ...
   MemoryUsage.record('end');
   ```

3. **Use performance best practices**:
   ```dart
   // Use const widgets
   const MyWidget();

   // Lazy load lists
   ListView.builder(
     itemBuilder: (context, index) => MyItem(index),
   );

   // Dispose controllers
   @override
   void dispose() {
     controller.dispose();
     super.dispose();
   }
   ```

### Issue: Large app size
**Symptoms**: APK or app bundle too large

**Solutions**:
1. **Analyze app size**:
   ```bash
   flutter build apk --analyze-size
   ```

2. **Remove unused assets**:
   ```yaml
   # Only include used assets
   flutter:
     assets:
       - assets/images/used_image.png
   ```

3. **Enable shrinking**:
   ```bash
   flutter build apk --shrink
   ```

## 🔐 Security Issues

### Issue: API keys exposed
**Symptoms**: Sensitive data in version control

**Solutions**:
1. **Use environment variables**:
   ```dart
   const apiKey = String.fromEnvironment('API_KEY');
   ```

2. **Check .gitignore**:
   ```gitignore
   # Environment files
   .env
   .env.*
   ```

3. **Use secure storage**:
   ```dart
   import 'package:flutter_secure_storage/flutter_secure_storage.dart';

   const storage = FlutterSecureStorage();
   await storage.write(key: 'api_key', value: 'secret');
   ```

## 📊 Testing Issues

### Issue: Tests not running
**Symptoms**: `flutter test` fails or hangs

**Solutions**:
1. **Check test dependencies**:
   ```bash
   flutter pub run test
   ```

2. **Run specific test**:
   ```bash
   flutter test test/unit/my_test.dart
   ```

3. **Check for async issues**:
   ```dart
   test('async test', () async {
     // Use async/await properly
     final result = await myAsyncFunction();
     expect(result, equals('expected'));
   });
   ```

### Issue: Widget tests failing
**Symptoms**: Widget tests not finding elements

**Solutions**:
1. **Use proper test setup**:
   ```dart
   void main() {
     testWidgets('widget test', (WidgetTester tester) async {
       await tester.pumpWidget(MyApp());
       await tester.pumpAndSettle();

       expect(find.text('Hello'), findsOneWidget);
     });
   }
   ```

2. **Handle async widgets**:
   ```dart
   await tester.pumpWidget(MyWidget());
   await tester.pump(); // Rebuild after state change
   ```

## 🐛 Debugging Techniques

### Remote Debugging
```bash
# Enable debugging
flutter run --debug

# Connect to device
flutter attach
```

### Memory Debugging
```dart
// Add memory markers
import 'dart:developer';

void debugMemory() {
  MemoryUsage.record('operation_start');
  // ... code ...
  MemoryUsage.record('operation_end');
}
```

### Network Debugging
```dart
// Add Dio interceptors
dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
));
```

## 📱 Device-Specific Issues

### Issue: Camera not working
**Symptoms**: Camera opens but shows black screen

**Solutions**:
1. **Check permissions**:
   ```dart
   await Permission.camera.request();
   ```

2. **Use proper camera controller**:
   ```dart
   CameraController(
     camera,
     ResolutionPreset.high,
   );
   ```

3. **Handle camera exceptions**:
   ```dart
   try {
     await controller.initialize();
   } catch (e) {
     print('Camera error: $e');
   }
   ```

### Issue: Location services not working
**Symptoms**: Location permission denied or location null

**Solutions**:
1. **Request permissions**:
   ```dart
   await Permission.location.request();
   ```

2. **Check GPS settings**:
   ```dart
   Location location = new Location();
   bool isEnabled = await location.serviceEnabled();
   if (!isEnabled) {
     isEnabled = await location.requestService();
   }
   ```

## 🚨 Emergency Fixes

### Critical Build Issue
```bash
# Nuclear option for build issues
rm -rf .dart_tool/
rm pubspec.lock
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Critical Performance Issue
```bash
# Profile the app
flutter run --profile
# Use observatory: http://127.0.0.1:8100/inspect
```

### Critical Memory Issue
```dart
// Add memory pressure monitoring
void checkMemoryUsage() {
  final vm = WidgetsBinding.instance.platformDispatcher.views.first;
  final memory = vm.platformDispatcher.memory;

  if (memory.heapMaxUsage > 100 * 1024 * 1024) { // 100MB
    // Clear caches or reduce memory usage
  }
}
```

## 📞 Getting Help

### When to Ask for Help

1. **After trying basic solutions** - Don't ask before troubleshooting
2. **With specific error messages** - Include full stack traces
3. **With reproduction steps** - How to recreate the issue
4. **With environment details** - Flutter version, device, OS

### How to Report Issues

1. **Check existing issues** on GitHub
2. **Create minimal reproduction** case
3. **Include complete error logs**
4. **Specify expected vs actual** behavior
5. **Add device/environment details**

### Support Channels

- **GitHub Issues**: Bug reports and feature requests
- **Stack Overflow**: Technical questions with `flutter` tag
- **Flutter Discord**: Community chat and help
- **Flutter Community**: Slack workspace

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Issues](https://github.com/flutter/flutter/issues)
- [Stack Overflow Flutter](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter DevTools](https://docs.flutter.dev/development/tools/devtools)

## 🔄 Issue Resolution Workflow

1. **Identify the issue** clearly
2. **Reproduce the problem** consistently
3. **Check existing solutions** and documentation
4. **Try standard fixes** from this guide
5. **Search community resources**
6. **Ask for help** with complete information
7. **Document the solution** for future reference

---

**Remember**: Most issues have been encountered before. Check existing solutions first, then ask the community with complete information.
