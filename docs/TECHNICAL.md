# Technical Documentation

## Architecture Overview

Ghulmil Application follows a modern, scalable architecture built on Flutter with clean separation of concerns. The application is structured to support easy maintenance, testing, and future enhancements.

### Core Architecture Principles

1. **Separation of Concerns** - Clear boundaries between UI, business logic, and data layers
2. **Dependency Injection** - Riverpod for state management and dependency injection
3. **Type Safety** - Extensive use of static typing and code generation
4. **Immutability** - Freezed models ensure data consistency
5. **Reactive Programming** - Stream-based architecture for real-time features

## Technology Stack

### Core Framework
- **Flutter**: 3.9.2 - Cross-platform UI framework
- **Dart**: 3.0+ - Programming language
- **Material Design 3** - UI component system

### State Management
- **Riverpod**: 3.0.0 - State management and dependency injection
- **StateNotifier**: For complex state management
- **StreamProvider**: For real-time data streams

### Navigation
- **Go Router**: 16.2.1 - Declarative routing with type safety
- **Deep Linking** - Support for external links and navigation

### HTTP Client & API
- **Dio**: 5.9.0 - HTTP client with interceptors
- **Retrofit**: 4.7.2 - Type-safe API client generation

### Code Generation
- **Freezed**: 3.2.3 - Immutable data classes
- **JSON Serializable**: 6.11.1 - JSON serialization/deserialization
- **Build Runner**: For code generation automation

### UI & Styling
- **Google Fonts**: 6.3.1 - Typography (Poppins)
- **Custom Theme System** - Consistent design tokens

## Project Structure

```
lib/src/
├── core/                    # Global configuration and theming
│   └── theme.dart          # Material Design theme configuration
├── models/                 # Data models and business entities
│   ├── service.dart        # Service entity model
│   ├── booking.dart        # Booking entity model
│   ├── provider.dart       # Service provider model
│   └── ...                 # Additional models
├── providers/              # Riverpod state providers
│   ├── api_client_provider.dart
│   ├── service_provider.dart
│   ├── booking_provider.dart
│   └── tracking_provider.dart
├── screens/                # UI screens organized by feature
│   ├── home/               # Home screen module
│   ├── service_detail/     # Service detail module
│   ├── tracking/           # Tracking module
│   └── ...                 # Additional screen modules
├── services/               # Business logic and API services
│   ├── api_client.dart     # HTTP API client
│   ├── booking_service.dart
│   └── tracking_service.dart
├── widgets/                # Reusable UI components
│   ├── category_tile.dart  # Service category component
│   ├── provider_card.dart  # Provider information card
│   └── ...                 # Additional components
└── routes.dart             # Application routing configuration
```

## State Management Architecture

### Provider Types

#### 1. Service Providers (Dependency Injection)
```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});
```

#### 2. State Providers (Simple State)
```dart
final bookingCountProvider = StateProvider<int>((ref) => 0);
```

#### 3. Future Providers (Async Data)
```dart
final serviceProvider = FutureProvider.family<Service, String>((ref, serviceId) {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.getService(serviceId);
});
```

#### 4. Stream Providers (Real-time Data)
```dart
final trackingProvider = StreamProvider.family<LocationUpdate, String>((ref, bookingId) {
  final trackingService = ref.watch(trackingServiceProvider);
  return trackingService.trackBooking(bookingId);
});
```

### State Provider Guidelines

- **Use `Provider`** for dependency injection of services
- **Use `StateProvider`** for simple mutable state
- **Use `FutureProvider`** for one-time async operations
- **Use `StreamProvider`** for real-time data streams
- **Use `StateNotifier`** for complex state with business logic

## Data Models Architecture

### Freezed Model Structure
```dart
@freezed
abstract class Service with _$Service {
  const factory Service({
    required String id,
    required String title,
    String? subtitle,
    required List<Package> packages,
    required double rating,
    required List<String> tags,
    String? imageUrl,
  }) = _Service;

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
}
```

### Generated Files
- `service.freezed.dart` - Union types and pattern matching
- `service.g.dart` - JSON serialization methods

### Model Guidelines
- **Always use `@freezed`** for data models
- **Include `fromJson` factory** for API deserialization
- **Use required fields** for essential data
- **Use optional fields** for non-critical data
- **Group related models** in feature-specific files

## API Architecture

### API Client Structure
```dart
class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio() {
    _dio.options.baseUrl = 'https://api.ghulmil.com';
    _dio.interceptors.add(AuthInterceptor());
  }

  Future<Service> getService(String serviceId) async {
    final response = await _dio.get('/services/$serviceId');
    return Service.fromJson(response.data);
  }
}
```

### Retrofit API Client (Generated)
```dart
@RestApi(baseUrl: "https://api.ghulmil.com")
abstract class RestClient {
  factory RestClient(Dio dio) = _RestClient;

  @GET("/services/{serviceId}")
  Future<Service> getService(@Path("serviceId") String serviceId);
}
```

## Routing Architecture

### Route Configuration
```dart
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/service/:serviceId',
      name: 'serviceDetail',
      builder: (context, state) => ServiceDetailScreen(
        serviceId: state.pathParameters['serviceId']!,
      ),
    ),
  ],
);
```

### Route Parameters
- **Path Parameters**: `serviceId` in `/service/:serviceId`
- **Query Parameters**: `?filter=active&sort=date`
- **Route Names**: For programmatic navigation
- **Type Safety**: Parameters are validated at compile time

## Theming Architecture

### Design Tokens
```dart
// Colors
const Color kPrimary = Color(0xFF0FA3B1);
const Color kAccent = Color(0xFFFF8A00);

// Spacing
const double spacing = 16.0;
const double spacingLg = 24.0;

// Typography
final appTheme = ThemeData(
  textTheme: GoogleFonts.poppinsTextTheme(),
  colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
);
```

### Theme Extension
```dart
class CustomTheme {
  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: kTextPrimary,
  );
}
```

## Development Workflow

### Code Generation
```bash
# Generate all code
flutter pub run build_runner build

# Watch mode for development
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner clean
```

### Testing Strategy
```bash
# Unit tests
flutter test

# Widget tests
flutter test --tags widget

# Integration tests
flutter test integration_test/
```

### Code Quality
- **Flutter Lints**: Enabled for consistent code style
- **Static Analysis**: IDE warnings and errors
- **Type Checking**: Strict type safety enforcement

## Build Configuration

### pubspec.yaml Structure
```yaml
name: ghulmil_application
description: "A new Flutter project."
publish_to: 'none'
version: 0.1.0

environment:
  sdk: ^3.9.2

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^3.0.0
  freezed_annotation: ^3.1.0
  # ... other dependencies

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.7.1
  freezed: ^3.2.3
  # ... other dev dependencies

flutter:
  uses-material-design: true
```

### Build Targets
```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
          include_if_null: true
```

## Deployment Architecture

### Platform Support
- **Android**: API 21+ with Android Gradle Plugin 7.0+
- **iOS**: iOS 12+ with Xcode 14+
- **Web**: Modern browsers with WebAssembly support
- **Desktop**: Windows 10+, macOS 10.15+, Linux (Ubuntu 18.04+)

### Build Flavors
```bash
# Development build
flutter run

# Profile build
flutter run --profile

# Release build
flutter build apk --release
flutter build ios --release
```

## Performance Optimization

### Best Practices
1. **Lazy Loading** - Use `FutureProvider` for on-demand data loading
2. **Memory Management** - Dispose of controllers and subscriptions
3. **Image Optimization** - Use appropriate image formats and sizes
4. **Code Splitting** - Separate features into modules
5. **Caching Strategy** - Implement intelligent data caching

### Monitoring
- **Performance Profiling** - Flutter DevTools
- **Memory Leaks** - Observatory and leak tracking
- **Network Monitoring** - Dio interceptors for request tracking

## Security Considerations

### API Security
- **HTTPS Only** - All API calls use HTTPS
- **Token Authentication** - Bearer token authentication
- **Request Signing** - API request validation
- **Rate Limiting** - Client-side rate limiting

### Data Protection
- **Secure Storage** - Encrypted local storage
- **Input Validation** - Comprehensive input sanitization
- **Error Handling** - Secure error messages
- **Dependency Scanning** - Regular security updates

## Development Environment

### IDE Configuration
- **VS Code**: Flutter extension with recommended settings
- **Android Studio**: Flutter plugin with Dart support
- **Extensions**: Flutter, Dart, Freezed support

### Recommended Settings
```json
{
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

## Troubleshooting

### Common Issues
1. **Build Runner Issues** - Clean and regenerate
2. **Provider Dependencies** - Check circular dependencies
3. **Navigation Issues** - Verify route names and parameters
4. **Performance Issues** - Profile with DevTools

### Debug Commands
```bash
# Clear Flutter cache
flutter clean && flutter pub get

# Analyze code
flutter analyze

# Check dependencies
flutter pub outdated

# Doctor check
flutter doctor
```
