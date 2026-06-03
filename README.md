# Ghulmil Application 🏠

A comprehensive **service booking platform** built with Flutter that connects customers with professional service providers. Ghulmil offers a seamless experience for booking home services with real-time tracking, secure payments, and quality assurance.

## 🌟 Features

### Core Functionality
- **Service Discovery** - Browse and select from various home services
- **Real-time Booking** - Schedule services with instant availability
- **Live Tracking** - Track service providers in real-time
- **Secure Payments** - Multiple payment options with detailed breakdowns
- **Review System** - Rate and review completed services
- **Subscription Management** - Set up recurring services
- **Emergency Services** - Quick booking for urgent needs

### User Experience
- **Intuitive Interface** - Clean, modern design with consistent theming
- **Responsive Design** - Optimized for all screen sizes
- **Multi-language Support** - Ready for internationalization
- **Offline Capability** - Core features work without internet

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart 3.0 or higher
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ghulmil_application
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation**
   ```bash
   flutter pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Chrome, Firefox, Safari, Edge)
- **Windows** (Windows 10+)
- **macOS** (macOS 10.15+)
- **Linux** (Ubuntu 18.04+, Fedora 33+)

## 🏗️ Architecture

### Technology Stack
- **Framework**: Flutter 3.9.2
- **State Management**: Riverpod 3.0.0
- **Navigation**: Go Router 16.2.1
- **HTTP Client**: Dio 5.9.0
- **Code Generation**: Freezed 3.2.3, JSON Serializable 6.11.1
- **UI Components**: Material Design 3
- **Typography**: Google Fonts (Poppins)

### Project Structure
```
lib/src/
├── core/           # Theme, constants, and global configurations
├── models/         # Data models with Freezed code generation
├── providers/      # Riverpod state management providers
├── screens/        # UI screens organized by feature
├── services/       # API clients and business logic services
├── widgets/        # Reusable UI components
└── routes.dart     # Application navigation configuration
```

## 📋 Documentation

Detailed documentation is available in the `docs/` directory:

- **[Technical Documentation](docs/TECHNICAL.md)** - Architecture, setup, and development guidelines
- **[Functional Documentation](docs/FUNCTIONAL.md)** - Feature descriptions and user flows
- **[API Documentation](docs/API.md)** - Service endpoints and data contracts

## 🎨 Design System

### Color Palette
- **Primary**: `#0FA3B1` (Teal)
- **Accent**: `#FF8A00` (Orange)
- **Success**: `#2E7D32` (Green)
- **Danger**: `#D32F2F` (Red)
- **Surface**: `#F6F7F8` (Light Gray)

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Consistent text scales** with semantic naming
- **Accessible contrast ratios**

## 🔄 Development Workflow

### Code Generation
The project uses build_runner for code generation:

```bash
# Generate code for all files
flutter pub run build_runner build

# Watch for changes and regenerate
flutter pub run build_runner watch

# Clean and regenerate
flutter pub run build_runner clean
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Code Quality
- **Flutter Lints** for consistent code style
- **Static Analysis** enabled
- **Type Safety** enforced throughout

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Create an issue on GitHub
- Contact the development team
- Check the documentation in `docs/`

## 🔗 Links

- [Project Repository](#)
- [Documentation](#)
- [Issue Tracker](#)
- [Flutter Documentation](https://docs.flutter.dev/)

---

**Built with ❤️ using Flutter**

License: All Rights Reserved by Manojsmehta6996