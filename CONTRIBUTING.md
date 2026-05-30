# Contributing to Ghulmil Application

Thank you for your interest in contributing to Ghulmil Application! We welcome contributions from everyone. Here are some guidelines to help you get started.

## 🚀 Quick Start

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Create a feature branch** for your changes
4. **Make your changes** and test them
5. **Submit a pull request** with a clear description

## 📋 Development Setup

### Prerequisites

- **Flutter SDK**: 3.9.2 or higher
- **Dart**: 3.0 or higher
- **IDE**: VS Code or Android Studio with Flutter extensions

### Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/ghulmil_application.git
cd ghulmil_application

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build

# Run the application
flutter run
```

## 🏗️ Project Structure

```
lib/src/
├── core/           # Global configuration and theming
├── models/         # Data models with Freezed code generation
├── providers/      # Riverpod state management providers
├── screens/        # UI screens organized by feature
├── services/       # API clients and business logic services
├── widgets/        # Reusable UI components
└── routes.dart     # Application routing configuration
```

## 📝 Code Style

### General Guidelines

- **Use meaningful variable and function names**
- **Write clear, concise comments** for complex logic
- **Follow the existing code style** and patterns
- **Keep functions small** and focused on a single responsibility
- **Use type annotations** where it improves clarity

### Dart/Flutter Specific

- **Use `const` constructors** when possible
- **Prefer `final` over `var`** for immutable variables
- **Use async/await** instead of raw futures
- **Handle null safety** properly with `?` and `!` operators
- **Use Freezed** for data models

### Example

```dart
// Good
class UserProfile extends StatelessWidget {
  const UserProfile({
    super.key,
    required this.user,
  });

  final User user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.name),
      ),
      body: const _ProfileContent(),
    );
  }
}

// Avoid
class UserProfile extends StatelessWidget {
  final user;

  const UserProfile(this.user, {Key key}) : super(key: key);

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: _ProfileContent(),
    );
  }
}
```

## 🔧 Code Generation

The project uses several code generation tools:

### Freezed Models
```bash
# Generate Freezed models
flutter pub run build_runner build --delete-conflicting-outputs
```

### JSON Serialization
```bash
# Generate JSON serialization code
flutter pub run build_runner build
```

### Watch Mode (Development)
```bash
# Watch for changes and regenerate automatically
flutter pub run build_runner watch
```

## 🧪 Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/models/user_test.dart

# Run tests matching pattern
flutter test --name "User"
```

### Writing Tests

- **Unit tests** for business logic
- **Widget tests** for UI components
- **Integration tests** for complete user flows
- **Mock dependencies** using Mockito

### Test Example

```dart
void main() {
  group('User Model', () {
    test('should create user from JSON', () {
      final json = {
        'id': '123',
        'name': 'John Doe',
        'email': 'john@example.com',
      };

      final user = User.fromJson(json);

      expect(user.id, '123');
      expect(user.name, 'John Doe');
      expect(user.email, 'john@example.com');
    });
  });
}
```

## 📱 Platform-Specific Setup

### Android

1. **Install Android Studio** with Flutter plugin
2. **Set up Android SDK** (API 21 or higher)
3. **Create emulator** or connect physical device
4. **Enable Developer Options** and USB Debugging

### iOS

1. **Install Xcode** (version 14 or higher)
2. **Set up iOS Simulator** or connect physical device
3. **Install CocoaPods** for iOS dependencies
4. **Set up Apple ID** for code signing

### Web

1. **Enable web support** in Flutter
2. **Install Chrome** for testing
3. **Run with web target**: `flutter run -d chrome`

## 🎨 UI/UX Guidelines

### Design System

- **Colors**: Follow the defined color palette in `core/theme.dart`
- **Typography**: Use Poppins font family with consistent text scales
- **Spacing**: Use predefined spacing constants
- **Components**: Utilize existing widgets in `widgets/`

### Responsive Design

- **Test on multiple screen sizes**
- **Use responsive layouts** with MediaQuery
- **Follow Material Design guidelines**
- **Consider both portrait and landscape orientations**

## 🚫 Common Pitfalls

### Performance Issues

- **Avoid unnecessary widget rebuilds**
- **Use `const` widgets** when possible
- **Dispose of controllers** and subscriptions
- **Lazy load** large lists and images

### State Management

- **Don't put business logic** in widgets
- **Use appropriate providers** for different types of state
- **Avoid provider dependency cycles**
- **Test state changes** thoroughly

### Memory Leaks

- **Dispose of streams** and subscriptions
- **Cancel timers** in dispose methods
- **Use weak references** when appropriate
- **Monitor memory usage** with Flutter Inspector

## 🔒 Security Considerations

### API Security

- **Never hardcode API keys** in source code
- **Use environment variables** for sensitive data
- **Validate all input** from users and APIs
- **Implement proper error handling** without exposing sensitive information

### Data Protection

- **Use HTTPS** for all network requests
- **Store sensitive data** securely using Flutter Secure Storage
- **Implement proper authentication** and authorization
- **Follow data protection regulations** (GDPR, CCPA, etc.)

## 📊 Pull Request Process

### Before Submitting

1. **Run tests** and ensure they pass
2. **Test on multiple devices/platforms**
3. **Update documentation** if needed
4. **Follow code style guidelines**
5. **Write meaningful commit messages**

### PR Template

```markdown
## Description

Brief description of the changes made.

## Changes

- Change 1
- Change 2
- Change 3

## Testing

- Test case 1
- Test case 2
- Test case 3

## Screenshots

[Before/After screenshots if UI changes]

## Related Issues

Closes #123
```

## 🐛 Issue Reporting

### Bug Reports

When reporting bugs, please include:

- **Flutter doctor output**
- **Steps to reproduce** the issue
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Device information** (OS, Flutter version, device model)

### Feature Requests

For feature requests, please include:

- **Use case** and problem description
- **Proposed solution** or implementation approach
- **Alternatives considered**
- **Additional context** or examples

## 📚 Resources

### Documentation

- **[Technical Documentation](docs/TECHNICAL.md)** - Architecture and setup
- **[Functional Documentation](docs/FUNCTIONAL.md)** - Features and user flows
- **[API Documentation](docs/API.md)** - API endpoints and models

### Community

- **[Flutter Documentation](https://docs.flutter.dev/)**
- **[Riverpod Documentation](https://riverpod.dev/)**
- **[Freezed Documentation](https://pub.dev/packages/freezed)**
- **[Go Router Documentation](https://pub.dev/packages/go_router)**

## 🤝 Code of Conduct

Please be respectful and considerate of others when contributing. We expect all contributors to:

- **Be respectful** in communications
- **Be collaborative** and open to feedback
- **Focus on what is best** for the project
- **Respect different viewpoints** and experiences
- **Use welcoming and inclusive language**

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the same license as the original project.

---

Thank you for contributing to Ghulmil Application! 🎉
