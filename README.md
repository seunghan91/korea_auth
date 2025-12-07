# Korea Auth

[![Pub](https://img.shields.io/pub/v/open_k_auth.svg)](https://pub.dev/packages/open_k_auth)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![GitHub Issues](https://img.shields.io/github/issues/seunghan91/korea_auth)](https://github.com/seunghan91/korea_auth/issues)

A multi-platform authentication SDK for Korean social logins (Kakao, Naver, Google, Apple).

## 📦 Packages

| Package                       | Platform         | Registry     | Status   |
| ----------------------------- | ---------------- | ------------ | -------- |
| [flutter](./packages/flutter) | Flutter/Dart     | pub.dev      | ✅ Ready |
| [rails](./packages/rails)     | Ruby on Rails    | rubygems.org | ✅ Ready |
| [svelte](./packages/svelte)   | Svelte/SvelteKit | npm          | ✅ Ready |
| [flask](./packages/flask)     | Python/Flask     | pypi.org     | ✅ Ready |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  Client (Flutter / Svelte / React)                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  korea-auth SDK                                          │   │
│  │  • KakaoButton, NaverButton, GoogleButton, AppleButton   │   │
│  │  • AuthStore (state management)                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                    │
│                            │ POST /auth/verify                  │
│                            │ { provider: "kakao", token: "..." }│
│                            ▼                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  Backend (Rails / Flask / Express)                              │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  korea-auth SDK                                          │   │
│  │  • KoreaAuth.verify(provider, token)                     │   │
│  │  • Returns: { uid, name, email, photo_url }              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Flutter (Client)

```dart
import 'package:open_k_auth/open_k_auth.dart';

final authRepo = AuthRepository();
await authRepo.signIn(GoogleAuthProvider());
```

See [Flutter README](./packages/flutter/README.md) for complete documentation.

### Rails (Backend)

```ruby
result = KoreaAuth.verify("kakao", params[:token])
if result.success?
  user = User.find_or_create_by(uid: result.uid)
end
```

### Flask (Backend)

```python
from korea_auth import verify_token

result = verify_token("kakao", request.json["token"])
if result.success:
    user = User.get_or_create(uid=result.uid)
```

## 📚 Documentation

### Flutter Package
- **[Flutter README](./packages/flutter/README.md)** - Package overview and usage
- **[Android Setup](./packages/flutter/docs/SETUP_ANDROID.md)** - Android configuration guide
- **[iOS Setup](./packages/flutter/docs/SETUP_IOS.md)** - iOS configuration guide
- **[Publishing Guide](./packages/flutter/docs/PUBLISHING.md)** - How to publish to pub.dev
- **[Troubleshooting](./packages/flutter/docs/TROUBLESHOOTING.md)** - Common issues and solutions

### Backend Packages
- **[Rails Package](./packages/rails/README.md)** - Ruby on Rails integration
- **[Svelte Package](./packages/svelte/README.md)** - Svelte/SvelteKit integration
- **[Flask Package](./packages/flask/README.md)** - Python/Flask integration

### Project
- **[Contributing Guide](./CONTRIBUTING.md)** - How to contribute
- **[License](./LICENSE)** - MIT License

## ✨ Features

### Flutter Package (open_k_auth)

- ✅ **Unified Interface**: One API for Google, Kakao, Naver, Apple
- ✅ **Riverpod Integration**: First-class support for state management
- ✅ **Multiple State Managers**: Provider, BLoC, GetX, MobX, Redux, Signals, Vanilla
- ✅ **Auto Token Refresh**: Automatic token refresh with event streaming
- ✅ **Server Verification**: Token verification helpers for backend
- ✅ **Testing Support**: MockAuthProvider for easy testing
- ✅ **UI Components**: Branded AuthButton widget with provider styles
- ✅ **Error Handling**: Unified AuthException for consistent error handling
- ✅ **Platform Support**: Android, iOS, Web
- ✅ **Documentation**: Comprehensive guides and examples

## 🔧 Setup

### Prerequisites
- Flutter 3.0+
- Dart 3.0+
- Android 5.0+ (API level 21)
- iOS 11.0+

### Installation

```bash
flutter pub add open_k_auth
```

## 🎯 Providers

### Supported Platforms

| Provider | Android | iOS | Web  |
|----------|---------|-----|------|
| Google   | ✅      | ✅  | ✅   |
| Kakao    | ✅      | ✅  | ❌   |
| Naver    | ✅      | ✅  | ❌   |
| Apple    | ❌      | ✅  | ❌   |

## 📖 Examples

### Basic Usage

```dart
import 'package:open_k_auth/open_k_auth.dart';

// Create repository
final authRepo = AuthRepository();

// Sign in with Google
try {
  final user = await authRepo.signIn(GoogleAuthProvider());
  print('Welcome, ${user.displayName}!');
} catch (e) {
  print('Sign in failed: $e');
}

// Sign out
await authRepo.signOut();
```

### With Riverpod

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_k_auth/open_k_auth.dart';

class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) => state.isAuthenticated
          ? UserProfile(user: state.user!)
          : LoginButtons(),
      loading: () => LoadingSpinner(),
      error: (e, st) => ErrorWidget(error: e),
    );
  }
}
```

### With Server Verification

```dart
// Client-side
final user = await authRepo.signIn(KakaoAuthProvider());
final verification = ServerVerification(
  provider: 'kakao',
  token: user.rawData['accessToken'],
);

// Send to backend
final response = await http.post(
  Uri.parse('https://api.example.com/auth/verify'),
  body: jsonEncode(verification.toJson()),
);
```

## 🐛 Troubleshooting

Common issues and solutions:

- **Google Sign-In not working**: Check [SHA-1 fingerprint setup](./packages/flutter/docs/SETUP_ANDROID.md)
- **Kakao login fails**: Verify [keystore hash](./packages/flutter/docs/SETUP_ANDROID.md)
- **Naver login issues**: Confirm [certificate fingerprint](./packages/flutter/docs/SETUP_ANDROID.md)
- **Token expired errors**: Implement [token refresh](./packages/flutter/docs/TROUBLESHOOTING.md)

See [Troubleshooting Guide](./packages/flutter/docs/TROUBLESHOOTING.md) for more.

## 📝 License

MIT License - see [LICENSE](./LICENSE)

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guide](./CONTRIBUTING.md) for details.

### Contributors

<a href="https://github.com/seunghan91/korea_auth/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=seunghan91/korea_auth" />
</a>

## 📞 Support

- **Documentation**: See [packages/flutter/docs/](./packages/flutter/docs/)
- **Issues**: [GitHub Issues](https://github.com/seunghan91/korea_auth/issues)
- **Discussions**: [GitHub Discussions](https://github.com/seunghan91/korea_auth/discussions)
- **Email**: Open an issue for contact information

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Integrates with official SDKs:
  - [Google Sign-In](https://pub.dev/packages/google_sign_in)
  - [Kakao SDK](https://pub.dev/packages/kakao_flutter_sdk_user)
  - [Naver Login](https://pub.dev/packages/flutter_naver_login)
  - [Sign in with Apple](https://pub.dev/packages/sign_in_with_apple)

---

**Star ⭐ this repository if you find it helpful!**
