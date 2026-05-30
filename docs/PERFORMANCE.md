# Performance Optimization Guide

## Overview

This guide provides strategies and best practices for optimizing the performance of the Ghulmil Application. Performance optimization is crucial for user experience, battery life, and app store ratings.

## 📊 Performance Metrics

### Core Web Vitals (Web)
- **First Contentful Paint (FCP)**: < 1.8s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **First Input Delay (FID)**: < 100ms
- **Cumulative Layout Shift (CLS)**: < 0.1

### Mobile Performance Metrics
- **App Startup Time**: < 2s
- **Frame Rate**: 60 FPS
- **Memory Usage**: < 100MB baseline
- **Battery Impact**: Minimal
- **Network Usage**: Optimized

## 🚀 Optimization Strategies

### 1. App Startup Optimization

#### Reduce App Initialization Time

```dart
// lib/main.dart - Optimized main function
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize critical services in parallel
  await Future.wait([
    initializeFirebase(),
    loadCriticalAssets(),
    setupErrorReporting(),
  ]);

  // Initialize non-critical services asynchronously
  scheduleMicrotask(() {
    initializeAnalytics();
    checkForUpdates();
  });

  runApp(const GhulmilApp());
}
```

#### Lazy Loading
```dart
// Use FutureBuilder for heavy initialization
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const HomeScreen();
        }
        return const LoadingScreen();
      },
    );
  }
}
```

#### Preload Critical Resources
```dart
// Preload frequently used images
class AssetPreloader {
  static Future<void> preloadCriticalAssets() async {
    await Future.wait([
      precacheImage(const AssetImage('assets/images/logo.png'), Get.context!),
      precacheImage(const AssetImage('assets/images/background.jpg'), Get.context!),
    ]);
  }
}
```

### 2. Widget Optimization

#### Use const Constructors
```dart
// Good - const constructor
const CategoryTile({
  super.key,
  required this.title,
  required this.icon,
});

// Usage
const CategoryTile(title: 'Cleaning', icon: Icons.cleaning_services)
```

#### Avoid Unnecessary Rebuilds
```dart
// Bad - rebuilds on every parent rebuild
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final data = ref.watch(someProvider);
      return Text(data.toString());
    });
  }
}

// Good - only rebuilds when data changes
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(someProvider);
    return Text(data.toString());
  }
}
```

#### Optimize List Performance
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(item: items[index]);
  },
  addAutomaticKeepAlives: false,
  addRepaintBoundaries: true,
)
```

### 3. Memory Management

#### Dispose Resources Properly
```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late final StreamSubscription subscription;
  late final Timer timer;

  @override
  void initState() {
    super.initState();

    subscription = someStream.listen((data) {
      // Handle data
    });

    timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      // Handle periodic task
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

#### Use Weak References for Caches
```dart
class ImageCacheManager {
  final Map<String, WeakReference<ImageProvider>> _cache = {};

  ImageProvider? getImage(String url) {
    final cached = _cache[url]?.target;
    if (cached != null) {
      return cached;
    }

    final image = NetworkImage(url);
    _cache[url] = WeakReference(image);
    return image;
  }

  void clearCache() {
    _cache.clear();
  }
}
```

### 4. Network Optimization

#### Implement Request Caching
```dart
class ApiClient {
  final Map<String, CachedResponse> _cache = {};
  final Duration _cacheDuration = const Duration(minutes: 5);

  Future<Response> get(String endpoint) async {
    final cacheKey = '$endpoint-${DateTime.now().toIso8601().substring(0, 16)}';

    // Check cache first
    final cached = _cache[cacheKey];
    if (cached != null && DateTime.now().difference(cached.timestamp) < _cacheDuration) {
      return cached.response;
    }

    // Make network request
    final response = await _dio.get(endpoint);

    // Cache the response
    _cache[cacheKey] = CachedResponse(
      response: response,
      timestamp: DateTime.now(),
    );

    return response;
  }
}
```

#### Use Efficient Image Loading
```dart
// Optimized image widget
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  fadeInDuration: const Duration(milliseconds: 300),
  useOldImageOnUrlChange: true,
  maxHeightDiskCache: 500,
  maxWidthDiskCache: 500,
)
```

### 5. Animation Performance

#### Use Hardware Acceleration
```dart
// Enable hardware acceleration
Container(
  transform: Matrix4.translationValues(0, 0, 0),
  child: AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      return Transform.translate(
        offset: Offset(_animation.value, 0),
        child: child,
      );
    },
    child: ExpensiveWidget(), // This won't rebuild
  ),
)
```

#### Optimize Animation Controllers
```dart
class SmoothAnimation extends StatefulWidget {
  @override
  _SmoothAnimationState createState() => _SmoothAnimationState();
}

class _SmoothAnimationState extends State<SmoothAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addListener(() {
      // Use setState sparingly
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Transform.scale(
        scale: _controller.value,
        child: child,
      ),
      child: const MyWidget(), // Static child
    );
  }
}
```

### 6. State Management Optimization

#### Provider Optimization
```dart
// Use Provider.family for parameterized providers
final userProvider = Provider.family<User?, String>((ref, userId) {
  return ref.watch(apiProvider).getUser(userId);
});

// Use StreamProvider for real-time data
final locationProvider = StreamProvider<Location>((ref) {
  return LocationService().locationStream;
});
```

#### Avoid Provider Cascades
```dart
// Bad - creates cascade of providers
final providerA = Provider((ref) => A());
final providerB = Provider((ref) {
  final a = ref.watch(providerA);
  return B(a);
});
final providerC = Provider((ref) {
  final b = ref.watch(providerB);
  return C(b);
});

// Good - combine logic
final combinedProvider = Provider((ref) {
  final apiService = ref.watch(apiProvider);
  return apiService.getCombinedData();
});
```

## 📱 Platform-Specific Optimization

### Android Optimization

#### Reduce APK Size
```bash
# Build with shrinking
flutter build apk --shrink

# Use app bundle (recommended)
flutter build appbundle --shrink
```

#### Optimize for Different Architectures
```yaml
# android/app/build.gradle
android {
    splits {
        abi {
            enable true
            reset()
            include "armeabi-v7a", "arm64-v8a", "x86", "x86_64"
            universalApk true
        }
    }
}
```

### iOS Optimization

#### Bitcode Optimization
```yaml
# Enable bitcode in iOS
# Add to Info.plist
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

#### Optimize Launch Images
```dart
// Use proper launch screen storyboard
// ios/Runner/Base.lproj/LaunchScreen.storyboard
```

### Web Optimization

#### Tree Shaking
```yaml
# pubspec.yaml
dependencies:
  # Only include used dependencies
```

#### Code Splitting
```dart
// Use deferred loading for non-critical features
class FeatureLoader {
  static Future<void> loadFeature() async {
    await deferredLoadLibrary();
    // Use loaded library
  }
}
```

## 🔍 Performance Monitoring

### Flutter DevTools
```bash
# Launch DevTools
flutter pub global run devtools

# Connect to running app
flutter run --debug
# Then open: http://127.0.0.1:9100
```

### Performance Profiling
```dart
// Add performance markers
import 'package:flutter/foundation.dart';

void profileFunction(String name, Function fn) {
  final stopwatch = Stopwatch()..start();
  final result = fn();
  stopwatch.stop();

  debugPrint('$name took ${stopwatch.elapsedMilliseconds}ms');

  return result;
}
```

### Memory Leak Detection
```dart
// Use observatory to detect leaks
class MemoryMonitor {
  static void checkForLeaks() {
    // Force garbage collection
    // Check for unexpected retained objects
  }
}
```

## 🧪 Performance Testing

### Benchmark Testing
```dart
// test/performance/startup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

class AppStartupBenchmark extends BenchmarkBase {
  const AppStartupBenchmark() : super('AppStartup');

  static void main() {
    const AppStartupBenchmark().report();
  }

  @override
  void run() {
    // Test app startup time
  }

  @override
  void setup() {
    // Setup test
  }

  @override
  void teardown() {
    // Cleanup test
  }
}
```

### Load Testing
```dart
// Simulate multiple users
class LoadTester {
  static Future<void> simulateLoad(int userCount) async {
    final stopwatch = Stopwatch()..start();

    final futures = List.generate(userCount, (index) {
      return simulateUserSession(index);
    });

    await Future.wait(futures);
    stopwatch.stop();

    print('Load test completed in ${stopwatch.elapsedMilliseconds}ms');
  }
}
```

## 📊 Performance Metrics Collection

### Custom Performance Metrics
```dart
// lib/core/performance_monitor.dart
class PerformanceMonitor {
  static final Map<String, int> _metrics = {};

  static void recordMetric(String name, int value) {
    _metrics[name] = value;

    // Send to analytics service
    AnalyticsService.recordPerformanceMetric(name, value);
  }

  static Map<String, int> getMetrics() => Map.unmodifiable(_metrics);
}
```

### Firebase Performance Monitoring
```dart
// lib/core/firebase_performance.dart
class FirebasePerformanceMonitor {
  static Future<void> recordScreenLoadTime(String screenName) async {
    final trace = FirebasePerformance.instance.newTrace('screen_load_$screenName');
    await trace.start();

    // ... screen loading code ...

    await trace.stop();
  }
}
```

## 🚨 Performance Issues and Solutions

### Common Performance Issues

#### Issue: Slow List Rendering
**Symptoms**: Janky scrolling, dropped frames

**Solutions**:
1. Use `ListView.builder` instead of `ListView`
2. Implement virtualization for large lists
3. Use `AutomaticKeepAlive` for off-screen items
4. Optimize item layout complexity

#### Issue: Memory Leaks
**Symptoms**: Increasing memory usage over time

**Solutions**:
1. Dispose of controllers and subscriptions
2. Use `WeakReference` for caches
3. Monitor memory usage with DevTools
4. Implement proper cleanup in `dispose()`

#### Issue: Slow API Calls
**Symptoms**: Slow UI updates, poor network performance

**Solutions**:
1. Implement request caching
2. Use pagination for large datasets
3. Optimize image loading
4. Implement offline-first architecture

#### Issue: Heavy Widget Rebuilds
**Symptoms**: Poor frame rate, slow interactions

**Solutions**:
1. Use `const` widgets when possible
2. Implement proper `shouldRebuild` methods
3. Use `AnimatedBuilder` to isolate rebuilds
4. Separate static and dynamic content

## 🎯 Performance Best Practices

### General Guidelines
1. **Profile first** - Measure before optimizing
2. **Optimize for 60fps** - Maintain smooth animations
3. **Use const constructors** - Prevent unnecessary rebuilds
4. **Lazy load resources** - Load only when needed
5. **Dispose resources properly** - Prevent memory leaks

### Widget Guidelines
1. **Keep widgets simple** - Avoid complex nested layouts
2. **Use appropriate list types** - `ListView.builder` for dynamic lists
3. **Implement `shouldRebuild`** - For expensive widgets
4. **Use `RepaintBoundary`** - For complex animations

### State Management Guidelines
1. **Minimize provider rebuilds** - Use selective listening
2. **Use appropriate provider types** - `FutureProvider` for async data
3. **Avoid provider cascades** - Combine related logic
4. **Implement proper error handling** - Prevent error state rebuilds

### Network Guidelines
1. **Cache responses** - Implement intelligent caching
2. **Use efficient serialization** - JSON with proper models
3. **Implement retry logic** - Handle network failures
4. **Optimize image loading** - Use appropriate formats and sizes

## 📈 Performance Monitoring Setup

### DevTools Configuration
```bash
# Enable performance monitoring
flutter run --debug --observatory-port 9200

# Connect DevTools
open http://127.0.0.1:9200
```

### Continuous Performance Monitoring
```dart
// lib/core/performance_analytics.dart
class PerformanceAnalytics {
  static void setupMonitoring() {
    // Monitor frame rate
    WidgetsBinding.instance.addPersistentFrameCallback((time) {
      final fps = 1000 / time.inMilliseconds;
      if (fps < 50) {
        debugPrint('Low FPS detected: $fps');
      }
    });

    // Monitor memory usage
    Timer.periodic(const Duration(seconds: 30), (timer) {
      final memory = WidgetsBinding.instance.platformDispatcher.memory;
      debugPrint('Memory usage: ${memory.heapMaxUsage ~/ 1024}KB');
    });
  }
}
```

## 📋 Performance Checklist

### Pre-Release Performance Check
- [ ] App startup time < 2 seconds
- [ ] Frame rate maintains 60 FPS
- [ ] Memory usage stable over time
- [ ] Network requests optimized
- [ ] Images properly optimized
- [ ] Animations smooth and hardware-accelerated
- [ ] Large lists use virtualization
- [ ] State management efficient
- [ ] Error handling doesn't impact performance

### Performance Testing Checklist
- [ ] Unit tests for performance-critical functions
- [ ] Widget tests for complex UI components
- [ ] Integration tests for critical user flows
- [ ] Load testing for expected user volumes
- [ ] Memory leak testing
- [ ] Battery impact testing on mobile devices

## 📚 Additional Resources

### Flutter Performance
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Flutter Performance Profiling](https://docs.flutter.dev/perf/ui-performance)
- [Flutter Memory Management](https://docs.flutter.dev/perf/rendering-performance)

### Mobile Performance
- [Android Performance Patterns](https://developer.android.com/topic/performance)
- [iOS Performance Guidelines](https://developer.apple.com/documentation/uikit/app_and_environment)
- [Mobile Performance Testing](https://developers.google.com/web/fundamentals/performance)

### Web Performance
- [Web Performance Optimization](https://web.dev/performance/)
- [Flutter Web Performance](https://docs.flutter.dev/development/platform-integration/web/performance)
- [Progressive Web Apps](https://web.dev/pwa/)

---

**Remember**: Performance optimization is an ongoing process. Regularly profile your app and optimize based on real usage data.
