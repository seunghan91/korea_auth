## 0.1.0

### New Features
- ✨ Unified authentication interface for Google, Kakao, Naver, and Apple
- 🔐 First-class Riverpod support with `authStateProvider`
- 🎨 Customizable `AuthButton` widget with provider-specific styles
- 🔄 Automatic token refresh with event streaming
- 📝 Server-side token verification helpers
- 🧪 Built-in `MockAuthProvider` for testing
- 📚 Comprehensive documentation and platform-specific setup guides

### Core Architecture
- `AuthUser`: Unified user model across all providers
- `AuthException`: Consistent error handling
- `AuthRepository`: Single entry point for all auth operations
- `AuthProvider`: Extensible interface for new providers

### Platform Support
- ✅ Android (Google, Kakao, Naver)
- ✅ iOS (Google, Kakao, Naver, Apple)
- ✅ Web (Google Sign-In only)

### State Management
- 🏃 Riverpod integration ready
- 🔌 Examples for Provider, BLoC, GetX, MobX, Redux, Signals, Vanilla

### Bug Fixes & Improvements
- Improved error handling across all providers
- Better token management and refresh logic
- Enhanced debug diagnostics
- Full test coverage for core components

## 0.0.1

* Initial release (experimental)
