# Contributing to Korea Auth

Thank you for your interest in contributing to Korea Auth! This document provides guidelines for contributing to the project.

## Code of Conduct

This project follows a code of conduct to ensure a welcoming environment for all contributors. By participating, you are expected to uphold this code of conduct.

## How to Contribute

### Reporting Bugs

1. **Search existing issues** first to avoid duplicates
2. **Provide details**:
   - Device/OS and version
   - Flutter version: `flutter --version`
   - Package version
   - Detailed error message with stack trace
   - Steps to reproduce
   - Expected vs. actual behavior

3. **Example issue**:
   ```
   **Title**: Google Sign-In fails on Android with SHA-1 mismatch

   **Environment**:
   - Device: Pixel 6a
   - Android: 13
   - Flutter: 3.24.0

   **Steps to Reproduce**:
   1. Create app with google-services.json
   2. Click Google Sign-In button
   3. Observe error

   **Error**:
   ```
   PlatformException(sign_in_failed, 10: , null)
   ```

   **Expected**: Sign-in should succeed
   ```

### Suggesting Enhancements

1. **Check existing issues** for similar suggestions
2. **Describe the enhancement**:
   - What problem does it solve?
   - How would it work?
   - Is there an alternative?

3. **Example enhancement**:
   ```
   **Title**: Add support for WeChat authentication

   **Description**: WeChat is widely used in China. Adding support
   would allow developers to reach more users.

   **Implementation**: Follow the pattern of existing providers
   (GoogleAuthProvider, KakaoAuthProvider, etc.)
   ```

### Submitting Pull Requests

#### 1. Fork and Setup

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR_USERNAME/korea_auth.git
cd korea_auth

# Add upstream remote
git remote add upstream https://github.com/seunghan91/korea_auth.git

# Create feature branch
git checkout -b feature/your-feature-name
```

#### 2. Development

```bash
# Install dependencies
cd packages/flutter
flutter pub get

# Create your changes
# Edit files, add tests, update docs

# Run tests to verify
flutter test

# Format code
dart format .

# Analyze code
flutter analyze
```

#### 3. Commit

```bash
# Commit with clear message
git commit -m "Add WeChat authentication provider"

# Follow conventional commits:
# feat: New feature
# fix: Bug fix
# docs: Documentation
# test: Tests
# refactor: Code refactoring
# chore: Build, dependencies, etc.
```

#### 4. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Go to GitHub and create a Pull Request
# - Base: main
# - Compare: your-feature-branch
# - Add description and reference related issues
```

#### 5. Pull Request Guidelines

Your PR should include:

- [ ] Clear title and description
- [ ] Reference to related issues (`#123`)
- [ ] Tests for new functionality
- [ ] Updated documentation
- [ ] Updated CHANGELOG.md
- [ ] No breaking changes (or clearly documented)

**Example PR Description**:
```markdown
## Description
Adds WeChat authentication provider following the pattern of existing providers.

## Related Issues
Fixes #456

## Changes
- Added `WeChatAuthProvider` class
- Added WeChat platform setup guide
- Added tests for WeChat provider
- Updated README with WeChat example

## Testing
- [x] Unit tests pass
- [x] Android build succeeds
- [x] iOS build succeeds
- [x] Example app works

## Breaking Changes
None
```

---

## Development Guidelines

### Code Style

Follow [Effective Dart](https://dart.dev/guides/language/effective-dart):

```dart
// ✅ Good
class GoogleAuthProvider implements AuthProvider {
  final String providerId = 'google';

  Future<AuthUser> signIn() async {
    // Implementation
  }
}

// ❌ Bad
class googleAuthProvider implements AuthProvider{
  String providerId='google';
  Future signIn(){
    // Implementation
  }
}
```

### Testing

Every new feature should include tests:

```dart
test('GoogleAuthProvider returns correct user', () async {
  final provider = GoogleAuthProvider();
  // Mock or use test data
  final user = await provider.signIn();

  expect(user.providerId, 'google');
  expect(user.uid, isNotEmpty);
});
```

Run tests before submitting:

```bash
flutter test
flutter test --coverage
```

### Documentation

- Add dartdoc comments to public APIs
- Update README for new features
- Add examples to docstrings

```dart
/// Signs in a user with the specified provider.
///
/// Example:
/// ```dart
/// final user = await authRepo.signIn(GoogleAuthProvider());
/// ```
///
/// Throws [AuthException] if sign-in fails.
Future<AuthUser> signIn(AuthProvider provider) async {
  // Implementation
}
```

### Commits

- Write clear, descriptive commit messages
- One logical change per commit
- Reference issues when applicable

```bash
# Good
git commit -m "Add WeChat provider with tests"
git commit -m "Fix token refresh issue (#456)"

# Bad
git commit -m "Updates"
git commit -m "WX"
```

---

## Adding a New Provider

To add a new social login provider:

### 1. Create Provider Class

```dart
// lib/src/providers/wechat_auth_provider.dart

import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

class WeChatAuthProvider implements AuthProvider {
  @override
  String get providerId => 'wechat';

  @override
  Future<AuthUser> signIn() async {
    // Implementation
  }

  @override
  Future<void> signOut() async {
    // Implementation
  }

  @override
  Future<AuthUser?> get currentUser async {
    // Implementation
  }

  @override
  Future<void> refresh() async {
    // Implementation
  }
}
```

### 2. Add to exports

```dart
// lib/open_k_auth.dart
export 'src/providers/wechat_auth_provider.dart';
```

### 3. Create Tests

```dart
// test/wechat_auth_provider_test.dart

void main() {
  group('WeChatAuthProvider', () {
    test('signs in successfully', () async {
      final provider = WeChatAuthProvider();
      final user = await provider.signIn();

      expect(user.providerId, 'wechat');
      expect(user.uid, isNotEmpty);
    });

    test('signs out successfully', () async {
      final provider = WeChatAuthProvider();
      await provider.signOut(); // Should not throw
    });
  });
}
```

### 4. Add Documentation

Create `docs/SETUP_WECHAT.md` with:
- Developer console setup
- Android configuration
- iOS configuration
- Troubleshooting

### 5. Update README

Add example in README.md:

```dart
// WeChat Sign-In
AuthButton.wechat(
  onPressed: () => authRepo.signIn(WeChatAuthProvider()),
)
```

### 6. Update CHANGELOG

```markdown
## 0.2.0

- Add WeChat authentication provider
- Add WeChat setup guide
```

---

## File Structure

```
korea_auth/
├── packages/
│   ├── flutter/
│   │   ├── lib/
│   │   │   ├── src/
│   │   │   │   ├── core/          # Core interfaces & models
│   │   │   │   ├── providers/     # Auth providers
│   │   │   │   ├── repositories/  # Repository pattern
│   │   │   │   ├── widgets/       # UI components
│   │   │   │   ├── integrations/  # State management
│   │   │   │   ├── testing/       # Testing utilities
│   │   │   │   └── utils/         # Utilities
│   │   │   └── open_k_auth.dart   # Public exports
│   │   ├── test/                  # Unit tests
│   │   ├── example/               # Example app
│   │   ├── docs/                  # Documentation
│   │   └── pubspec.yaml
│   └── rails/
│   └── ...
├── docs/                          # Project-wide docs
├── README.md
├── LICENSE
└── CONTRIBUTING.md
```

---

## Review Process

1. **Automatic Checks**
   - Tests must pass
   - Code analysis must pass
   - Coverage must be > 80%

2. **Code Review**
   - At least one maintainer review required
   - Comments and suggestions for improvement
   - Request changes if needed

3. **Approval**
   - Maintainer approves changes
   - All conversations resolved
   - Ready to merge

4. **Merge**
   - Squash or rebase commits for clarity
   - Delete feature branch
   - Close related issues

---

## Development Tips

### Local Testing

```bash
# Test in example app
cd packages/flutter/example
flutter run

# Test with mock provider
import 'package:open_k_auth/src/testing/mock_auth_provider.dart';

final provider = MockAuthProvider(uid: 'test');
```

### Debug Mode

```bash
# Enable verbose output
flutter run -v

# Add debug prints
print('Debug: $variable');

# Use debugPrintBeginFrame for UI issues
```

### Documentation Preview

```bash
# Generate dartdoc
cd packages/flutter
dartdoc

# Open generated docs
open doc/api/index.html  # macOS
```

---

## Questions?

- **GitHub Discussions**: Ask questions in discussions
- **GitHub Issues**: Report bugs or request features
- **Email**: Contact maintainers
- **Documentation**: Check [docs/](./packages/flutter/docs/)

---

## Recognition

Contributors will be recognized in:
- README.md contributors section
- GitHub contributors page
- Release notes for significant contributions

Thank you for contributing to Korea Auth! 🎉
