# Open K-Auth

A modern, open-source authentication package for Flutter, designed for Korean apps but usable globally.
It provides a unified interface for Google, Kakao, Naver, and Apple sign-in, with built-in Riverpod support and a focus on developer experience.

## Features

- **Unified Interface**: `signIn`, `signOut`, `currentUser` works consistently across all providers.
- **Riverpod Integration**: First-class support with `authStateProvider`.
- **Customizable UI**: `AuthButton` widget with provider-specific styles.
- **Extensible**: Easy to add new providers by implementing `AuthProvider`.
- **Error Handling**: Unified `AuthException` for easier debugging.

## Installation

Add `open_k_auth` to your `pubspec.yaml`:

```yaml
dependencies:
  open_k_auth: ^0.0.1
  flutter_riverpod: ^2.0.0 # Recommended
```

## Usage

### 1. Setup Riverpod

Wrap your app with `ProviderScope`:

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

### 2. Watch Auth State

Use `authStateProvider` to listen to changes:

```dart
class AuthScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return authState.when(
      data: (state) {
        if (state.isAuthenticated) {
          return Text('Welcome ${state.user?.displayName}');
        }
        return AuthButton.google(
          onPressed: () => authRepo.signIn(GoogleAuthProvider()),
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
```

## Configuration

### Android & iOS

Follow the official configuration guides for each provider you use:

- [Google Sign In](https://pub.dev/packages/google_sign_in)
- [Kakao Login](https://pub.dev/packages/kakao_flutter_sdk_user)
- [Naver Login](https://pub.dev/packages/flutter_naver_login)
- [Sign in with Apple](https://pub.dev/packages/sign_in_with_apple)

## License

MIT
