# Deployment Guide

## Overview

This guide covers deploying the Ghulmil Application to various platforms including Android, iOS, Web, Desktop, and cloud services. Follow the appropriate section based on your target platform.

## 🚀 Pre-Deployment Checklist

### Code Quality
- [ ] All tests passing (`flutter test`)
- [ ] Code analysis clean (`flutter analyze`)
- [ ] Dependencies updated (`flutter pub upgrade`)
- [ ] Code generation completed (`flutter pub run build_runner build`)

### Assets and Configuration
- [ ] App icons and splash screens prepared
- [ ] Environment variables configured
- [ ] API endpoints updated for production
- [ ] Firebase configuration (if applicable)

### Build Configuration
- [ ] App version updated in `pubspec.yaml`
- [ ] Build number incremented
- [ ] Signing configurations ready

## 📱 Android Deployment

### Play Store Deployment

#### 1. Prepare for Release
```bash
# Build release APK
flutter build apk --release

# Build app bundle (recommended for Play Store)
flutter build appbundle --release
```

#### 2. Signing Configuration
Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=key
storeFile=../path/to/keystore.jks
```

#### 3. Version Configuration
Update `android/app/build.gradle`:
```gradle
android {
    defaultConfig {
        applicationId "com.ghulmil.application"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### 4. Play Store Upload
1. Create app in [Google Play Console](https://play.google.com/console)
2. Upload AAB file
3. Complete store listing
4. Submit for review

### Firebase App Distribution (Testing)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Build and distribute
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/apk/release/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "testers"
```

## 🍎 iOS Deployment

### App Store Deployment

#### 1. Prepare for Release
```bash
# Build iOS archive
flutter build ios --release

# Or build for specific device
flutter build ios --release --no-codesign
```

#### 2. Archive and Upload
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Product > Archive**
3. Upload to App Store Connect via Organizer

#### 3. Version Configuration
Update `ios/Runner/Info.plist`:
```xml
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

#### 4. TestFlight Distribution
1. Upload build to App Store Connect
2. Add internal testers or external test groups
3. Distribute via TestFlight

### Code Signing
Ensure proper code signing certificates and provisioning profiles are configured in Xcode.

## 🌐 Web Deployment

### Firebase Hosting
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize hosting
firebase init hosting

# Build for production
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Netlify Deployment
1. Build the web app: `flutter build web`
2. Upload `build/web` folder to Netlify
3. Configure build settings:
   - Build command: `flutter build web`
   - Publish directory: `build/web`

### GitHub Pages
```bash
# Install gh-pages package
flutter pub global activate peanut

# Deploy to GitHub Pages
peanut
```

### Web-Specific Configuration
Update `web/index.html` for production:
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="description" content="Ghulmil Application - Service Booking Platform">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ghulmil Application</title>
    <base href="/your-repo-name/">
</head>
<body>
    <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

## 💻 Desktop Deployment

### Windows Deployment

#### MSIX Package
```bash
# Build MSIX package
flutter build windows --release

# Create MSIX installer
flutter pub run msix:create
```

#### MSI Installer
```bash
# Build MSI installer
flutter build windows --release
innosetup-compiler installer.iss
```

### macOS Deployment

#### DMG Package
```bash
# Build for release
flutter build macos --release

# Create DMG
create-dmg build/macos/Build/Products/Release/ghulmil_application.app
```

#### App Store Deployment
1. Configure App Store Connect
2. Archive in Xcode
3. Upload via Transporter or Xcode

### Linux Deployment

#### Snap Package
```bash
# Build AppImage
flutter build linux --release
appimagetool build/linux/x64/release/bundle ghulmil_application.AppImage

# Build Snap
snapcraft
```

#### Debian Package
```bash
# Build DEB package
flutter build linux --release
dpkg-deb --build build/linux/x64/release/bundle
```

## ☁️ Cloud Services Deployment

### Firebase Configuration

#### 1. Setup Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase init

# Select: Functions, Firestore, Storage, Hosting
```

#### 2. Firebase Services Configuration

**lib/firebase_options.dart**:
```dart
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: "your-api-key",
    appId: "your-app-id",
    messagingSenderId: "your-sender-id",
    projectId: "your-project-id",
  );
}
```

### AWS Amplify Deployment

#### 1. Initialize Amplify
```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Initialize Amplify
amplify init

# Add hosting
amplify add hosting
```

#### 2. Deploy
```bash
# Build and deploy
amplify publish
```

## 📦 CI/CD Pipeline

### GitHub Actions
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy Flutter App

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        java-version: '12.x'
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Build APK
      run: flutter build apk --release

    - name: Build for Web
      run: flutter build web --release

    - name: Archive artifacts
      uses: actions/upload-artifact@v3
      with:
        name: release-artifacts
        path: |
          build/app/outputs/apk/release/*.apk
          build/web/
```

### GitLab CI
Create `.gitlab-ci.yml`:

```yaml
stages:
  - test
  - build
  - deploy

flutter_test:
  stage: test
  image: cirrusci/flutter:latest
  script:
    - flutter pub get
    - flutter analyze
    - flutter test

build_android:
  stage: build
  image: cirrusci/flutter:latest
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/apk/release/*.apk
```

## 🔧 Environment Configuration

### Production Environment Variables
Create `.env.production`:

```
API_BASE_URL=https://api.ghulmil.com
FIREBASE_API_KEY=your_api_key
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### Development Environment Variables
Create `.env.development`:

```
API_BASE_URL=http://localhost:3000
FIREBASE_API_KEY=your_dev_api_key
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### Environment Setup in Flutter
```dart
// lib/core/environment.dart
class Environment {
  static const bool isProduction = bool.fromEnvironment('dart.vm.production');
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
```

## 📊 Post-Deployment Tasks

### 1. Monitoring Setup
- Configure crash reporting (Firebase Crashlytics/Sentry)
- Set up performance monitoring
- Configure analytics (Firebase Analytics/Google Analytics)

### 2. App Store Optimization
- Update app store listings
- Configure in-app purchases (if applicable)
- Set up app store reviews and ratings

### 3. User Communication
- Announce new version to users
- Update support documentation
- Monitor user feedback and reviews

## 🐛 Rollback Procedures

### Android
1. Upload previous version to Play Store
2. Use staged rollout to minimize impact
3. Communicate with affected users

### iOS
1. Reject problematic build in App Store Connect
2. Upload fixed version
3. Use TestFlight for validation

### Web
1. Revert to previous deployment
2. Update CDN cache settings
3. Monitor for issues

## 📈 Performance Monitoring

### Web Vitals
- First Contentful Paint (FCP)
- Largest Contentful Paint (LCP)
- First Input Delay (FID)
- Cumulative Layout Shift (CLS)

### Mobile Metrics
- App startup time
- Memory usage
- Battery consumption
- Network usage

## 🔒 Security Considerations

### API Keys
- Use environment-specific API keys
- Rotate keys regularly
- Never commit keys to version control

### Network Security
- Enable HTTPS for all connections
- Implement certificate pinning
- Use secure storage for sensitive data

### Code Obfuscation
```bash
# Enable obfuscation
flutter build apk --obfuscate --split-debug-info=build/debug-info
```

## 📞 Support and Monitoring

### Error Tracking
- Firebase Crashlytics
- Sentry
- Bugsnag

### Performance Monitoring
- Firebase Performance Monitoring
- Datadog
- New Relic

### Analytics
- Firebase Analytics
- Google Analytics
- Mixpanel

## 🚨 Emergency Contacts

- **Development Team**: dev@ghulmil.com
- **DevOps Team**: ops@ghulmil.com
- **Support Team**: support@ghulmil.com

## 📚 Additional Resources

- [Flutter Build and Release](https://docs.flutter.dev/deployment)
- [Firebase Deployment](https://firebase.google.com/docs/flutter/setup)
- [Play Store Deployment](https://developer.android.com/distribute)
- [App Store Deployment](https://developer.apple.com/app-store)
- [Web Deployment](https://docs.flutter.dev/development/platform-integration/web)
