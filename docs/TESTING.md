# Testing Guide

## Overview

This guide outlines the testing strategy and practices for the Ghulmil Application. We follow a comprehensive testing approach to ensure code quality, reliability, and maintainability.

## 🧪 Testing Strategy

### Testing Levels

#### 1. Unit Tests
- Test individual functions and methods
- Focus on business logic isolation
- Fast execution and high coverage
- Mock external dependencies

#### 2. Widget Tests
- Test UI components in isolation
- Verify widget behavior and interactions
- Test rendering and state changes
- Include accessibility testing

#### 3. Integration Tests
- Test complete user workflows
- Test interactions between components
- Include API integration tests
- Test navigation and routing

#### 4. End-to-End Tests
- Test complete app functionality
- Include user journey testing
- Test on real devices and emulators
- Performance and load testing

## 🛠️ Testing Tools

### Core Testing Framework
- **test**: Official Dart testing framework
- **flutter_test**: Flutter-specific testing utilities
- **mockito**: Mock objects for testing
- **build_runner**: Code generation for tests

### Testing Dependencies
```yaml
dev_dependencies:
  test: ^1.24.0
  flutter_test:
    sdk: flutter
  mockito: ^5.5.0
  build_test: ^2.2.0
  integration_test:
    sdk: flutter
```

## 📁 Test Structure

```
test/
├── unit/                    # Unit tests
│   ├── models/             # Model tests
│   ├── providers/          # State management tests
│   ├── services/           # Service layer tests
│   └── utils/              # Utility function tests
├── widget/                 # Widget tests
│   ├── home/               # Home screen tests
│   ├── booking/            # Booking flow tests
│   └── common/             # Common widget tests
├── integration/            # Integration tests
│   ├── booking_flow.dart   # Complete booking tests
│   └── navigation_test.dart # Navigation tests
└── test_utils/             # Test utilities
    ├── mocks/              # Mock objects
    ├── helpers/            # Test helpers
    └── fixtures/           # Test data
```

## 🧪 Unit Testing

### Model Testing

```dart
// test/unit/models/user_test.dart
import 'package:test/test.dart';
import 'package:ghulmil_application/src/models/user.dart';

void main() {
  group('User Model', () {
    test('should create user from valid JSON', () {
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
      };

      final user = User.fromJson(json);

      expect(user.id, equals('123'));
      expect(user.name, equals('John Doe'));
      expect(user.email, equals('john@example.com'));
    });

    test('should throw error for invalid JSON', () {
      final json = {
        'id': '123',
        // Missing required fields
      };

      expect(() => User.fromJson(json), throwsFormatException);
    });

    test('should copy user with new values', () {
      final user = User(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
      );

      final updatedUser = user.copyWith(name: 'Jane Doe');

      expect(updatedUser.name, equals('Jane Doe'));
      expect(updatedUser.id, equals('123'));
    });
  });
}
```

### Service Testing

```dart
// test/unit/services/api_client_test.dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ghulmil_application/src/services/api_client.dart';
import 'package:ghulmil_application/src/models/service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient.withDio(mockDio);
  });

  group('ApiClient', () {
    test('should fetch service successfully', () async {
      final mockService = Service(
        id: 'cleaning_1',
        title: 'Household Cleaning',
        packages: [],
        rating: 4.7,
        tags: ['Cleaning'],
      );

      when(mockDio.get('/services/cleaning_1')).thenAnswer(
        (_) async => Response(
          data: mockService.toJson(),
          statusCode: 200,
        ),
      );

      final result = await apiClient.getService('cleaning_1');

      expect(result.id, equals('cleaning_1'));
      expect(result.title, equals('Household Cleaning'));
      verify(mockDio.get('/services/cleaning_1')).called(1);
    });

    test('should throw exception on API error', () async {
      when(mockDio.get('/services/cleaning_1')).thenAnswer(
        (_) async => Response(
          data: {'error': 'Service not found'},
          statusCode: 404,
        ),
      );

      expect(
        () => apiClient.getService('cleaning_1'),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
```

### Provider Testing

```dart
// test/unit/providers/booking_provider_test.dart
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:ghulmil_application/src/providers/booking_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late BookingProvider bookingProvider;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    bookingProvider = BookingProvider(mockApiClient);
  });

  group('BookingProvider', () {
    test('should load bookings successfully', () async {
      final mockBookings = [
        Booking(
          id: 'bk_1',
          serviceId: 'cleaning_1',
          status: BookingStatus.confirmed,
          createdAt: DateTime.now(),
        ),
      ];

      when(mockApiClient.getBookings()).thenAnswer((_) async => mockBookings);

      await bookingProvider.loadBookings();

      expect(bookingProvider.state, equals(ProviderState.success));
      expect(bookingProvider.bookings.length, equals(1));
    });

    test('should handle loading error', () async {
      when(mockApiClient.getBookings()).thenThrow(Exception('API Error'));

      await bookingProvider.loadBookings();

      expect(bookingProvider.state, equals(ProviderState.error));
      expect(bookingProvider.error, isNotNull);
    });
  });
}
```

## 🎨 Widget Testing

### Basic Widget Test

```dart
// test/widget/common/category_tile_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ghulmil_application/src/widgets/category_tile.dart';

void main() {
  testWidgets('CategoryTile displays title and icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryTile(
          id: 'cleaning_1',
          label: 'Household Cleaning',
          subtitle: 'Professional cleaning service',
          icon: Icons.cleaning_services,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Household Cleaning'), findsOneWidget);
    expect(find.byIcon(Icons.cleaning_services), findsOneWidget);
    expect(find.text('Professional cleaning service'), findsOneWidget);
  });

  testWidgets('CategoryTile responds to tap', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CategoryTile(
          id: 'cleaning_1',
          label: 'Household Cleaning',
          subtitle: 'Professional cleaning service',
          icon: Icons.cleaning_services,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(InkWell));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
```

### Widget Test with State

```dart
// test/widget/home/home_screen_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ghulmil_application/src/screens/home/home_screen.dart';
import 'package:ghulmil_application/src/providers/service_provider.dart';

void main() {
  testWidgets('HomeScreen displays services when loaded', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceProvider.overrideWith((ref) => AsyncValue.data([
            Service(
              id: 'cleaning_1',
              title: 'Household Cleaning',
              packages: [],
              rating: 4.7,
              tags: ['Cleaning'],
            ),
          ])),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Household Cleaning'), findsOneWidget);
    expect(find.byType(CategoryTile), findsOneWidget);
  });

  testWidgets('HomeScreen shows loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serviceProvider.overrideWith((ref) => const AsyncValue.loading()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

## 🔗 Integration Testing

### Complete User Flow Test

```dart
// test/integration/booking_flow_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ghulmil_application/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Booking Flow', () {
    testWidgets('should complete full booking process', (WidgetTester tester) async {
      app.main();

      await tester.pumpAndSettle();

      // Navigate to service selection
      await tester.tap(find.text('Household Cleaning'));
      await tester.pumpAndSettle();

      // Select package
      await tester.tap(find.text('Standard Clean'));
      await tester.pumpAndSettle();

      // Choose time slot
      await tester.tap(find.text('2:00 PM'));
      await tester.pumpAndSettle();

      // Enter address
      await tester.enterText(
        find.byType(TextFormField).first,
        '123 Main St',
      );
      await tester.pumpAndSettle();

      // Complete payment
      await tester.tap(find.text('Pay Now'));
      await tester.pumpAndSettle();

      // Verify confirmation
      expect(find.text('Booking Confirmed'), findsOneWidget);
      expect(find.text('Booking ID:'), findsOneWidget);
    });
  });
}
```

### Navigation Test

```dart
// test/integration/navigation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ghulmil_application/src/screens/home/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('should navigate between screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/': (_) => const HomeScreen(),
          '/service': (_) => const ServiceDetailScreen(),
        },
      ),
    );

    // Start on home screen
    expect(find.byType(HomeScreen), findsOneWidget);

    // Navigate to service detail
    await tester.tap(find.byType(CategoryTile));
    await tester.pumpAndSettle();

    // Verify navigation
    expect(find.byType(ServiceDetailScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });
}
```

## 🏃 Test Utilities

### Mock Setup

```dart
// test/test_utils/mocks/mock_api_client.dart
import 'package:mockito/mockito.dart';
import 'package:ghulmil_application/src/services/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockDio extends Mock implements Dio {}
```

### Test Helpers

```dart
// test/test_utils/helpers/widget_helpers.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

extension WidgetTesterX on WidgetTester {
  Future<void> pumpForSeconds(int seconds) async {
    await pumpAndSettle();
    await pump(Duration(seconds: seconds));
  }

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }
}
```

### Test Data Fixtures

```dart
// test/test_utils/fixtures/user_fixtures.dart
import 'package:ghulmil_application/src/models/user.dart';

class UserFixtures {
  static User get validUser => User(
    id: 'user_123',
    name: 'John Doe',
    email: 'john@example.com',
    phone: '+1234567890',
  );

  static Map<String, dynamic> get validUserJson => {
    'id': 'user_123',
    'name': 'John Doe',
    'email': 'john@example.com',
    'phone': '+1234567890',
  };
}
```

## 📊 Test Coverage

### Coverage Configuration

```yaml
# pubspec.yaml
dev_dependencies:
  test_cov: ^0.2.0

# analysis_options.yaml
analyzer:
  exclude:
    - test/**
    - lib/**/*.g.dart
    - lib/**/*.freezed.dart
```

### Running Coverage Tests

```bash
# Run tests with coverage
flutter test --coverage

# Generate coverage report
flutter test --coverage && lcov --remove coverage/lcov.info 'lib/**/*.g.dart' 'lib/**/*.freezed.dart' -o coverage/lcov_cleaned.info

# Generate HTML report
genhtml coverage/lcov_cleaned.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```

### Coverage Goals
- **Overall Coverage**: 85% minimum
- **Critical Path Coverage**: 95% minimum
- **Model Coverage**: 100%
- **Business Logic Coverage**: 90% minimum

## 🏗️ CI/CD Testing

### GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.9.2'

    - name: Install dependencies
      run: flutter pub get

    - name: Run tests
      run: flutter test

    - name: Run tests with coverage
      run: flutter test --coverage

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
```

### Test Reports

```yaml
# Generate test reports
flutter test --reporter json --output-dir test-reports

# Convert to HTML
dart run test_cov_console --file test-reports/tests.json
```

## 🐛 Debugging Tests

### Test Debugging Tips

1. **Use print statements**:
   ```dart
   test('debug test', () {
     print('Debug: Starting test');
     // ... test code ...
   });
   ```

2. **Use debugger**:
   ```bash
   flutter test --start-paused test/my_test.dart
   ```

3. **Check test output**:
   ```bash
   flutter test --verbose
   ```

### Common Test Issues

#### Issue: Test hangs or times out
**Solution**: Increase timeout or use `pumpAndSettle()`:
```dart
testWidgets('async test', (tester) async {
  // Use pumpAndSettle for async operations
  await tester.pumpAndSettle();
});
```

#### Issue: Widget not found
**Solution**: Check widget tree or use more specific finders:
```dart
// Instead of
expect(find.text('Button'), findsOneWidget);

// Use
expect(find.widgetWithText(ElevatedButton, 'Button'), findsOneWidget);
```

#### Issue: Provider not available in test
**Solution**: Override providers in test:
```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      myProvider.overrideWith((ref) => mockData),
    ],
    child: MyWidget(),
  ),
);
```

## 📋 Testing Best Practices

### Writing Good Tests

1. **Test one thing at a time**
2. **Use descriptive test names**
3. **Follow Arrange-Act-Assert pattern**
4. **Test both success and failure cases**
5. **Mock external dependencies**
6. **Use realistic test data**

### Test Organization

1. **Group related tests** using `group()`
2. **Use descriptive test descriptions**
3. **Set up common test data**
4. **Clean up after tests**
5. **Document complex test logic**

### Mocking Guidelines

1. **Mock external services** (API, database, etc.)
2. **Mock complex dependencies**
3. **Don't mock simple value objects**
4. **Use consistent mocking patterns**
5. **Verify mock interactions when relevant**

## 📈 Test Metrics

### Key Metrics to Track

- **Test Coverage**: Percentage of code covered
- **Test Success Rate**: Passing vs failing tests
- **Test Execution Time**: Time to run test suite
- **Flaky Test Rate**: Tests that fail intermittently
- **Test Maintenance Burden**: Time spent fixing tests

### Coverage Goals by Component

| Component | Target Coverage |
|-----------|----------------|
| Models | 100% |
| Services | 90% |
| Providers | 85% |
| Widgets | 80% |
| Utils | 95% |

## 🚀 Performance Testing

### App Startup Time
```dart
testWidgets('app starts quickly', (tester) async {
  final stopwatch = Stopwatch()..start();

  await tester.runAsync(() async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  });

  stopwatch.stop();
  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
});
```

### Memory Usage Testing
```dart
testWidgets('widget manages memory efficiently', (tester) async {
  await tester.pumpWidget(MyWidget());

  final before = await tester.binding.rootElement?.debugAllocatedSize;
  // ... interact with widget ...
  await tester.pumpAndSettle();

  final after = await tester.binding.rootElement?.debugAllocatedSize;
  expect(after, closeTo(before, 1000)); // Within 1KB
});
```

## 📱 Mobile-Specific Testing

### Platform-Specific Tests

```dart
group('Platform-specific tests', () {
  testWidgets('Android behavior', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    await tester.pumpWidget(MyWidget());
    // ... test Android-specific behavior ...

    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('iOS behavior', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    await tester.pumpWidget(MyWidget());
    // ... test iOS-specific behavior ...

    debugDefaultTargetPlatformOverride = null;
  });
});
```

### Device-Specific Tests

```dart
testWidgets('tablet layout', (tester) async {
  await tester.binding.setSurfaceSize(const Size(1024, 768));
  await tester.pumpWidget(MyWidget());
  // ... test tablet layout ...
});

testWidgets('phone layout', (tester) async {
  await tester.binding.setSurfaceSize(const Size(375, 667));
  await tester.pumpWidget(MyWidget());
  // ... test phone layout ...
});
```

## 📚 Additional Resources

### Testing Documentation
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/testing#widget-testing)
- [Integration Testing Guide](https://docs.flutter.dev/testing#integration-testing)

### Testing Tools
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Test Coverage Tools](https://pub.dev/packages/test_cov)
- [Golden Testing](https://pub.dev/packages/golden_toolkit)

### Best Practices
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/usage#testing)
- [Flutter Testing Best Practices](https://medium.com/flutter-community/testing-flutter-apps-a-guide-for-beginners-66b4e2c8563)

---

**Remember**: Good tests save time and prevent bugs. Write tests as you develop features, not after.
