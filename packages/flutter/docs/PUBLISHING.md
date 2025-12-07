# Publishing Guide for Open K-Auth

This guide covers the process of publishing the `open_k_auth` package to pub.dev.

## Pre-Publishing Checklist

### Code Quality
- [ ] All tests pass: `flutter test --coverage`
- [ ] Code analysis passes: `flutter analyze`
- [ ] Code is formatted: `dart format .`
- [ ] Test coverage is > 80%: `lcov --summary coverage/lcov.info`
- [ ] No deprecation warnings
- [ ] No lint warnings

### Documentation
- [ ] README.md is complete and accurate
- [ ] CHANGELOG.md is updated with new features
- [ ] API documentation is complete (dartdoc comments)
- [ ] All public APIs are documented
- [ ] Setup guides are provided (iOS & Android)
- [ ] Example app works and demonstrates features
- [ ] Installation instructions are clear

### Package Configuration
- [ ] `pubspec.yaml` has correct version number
- [ ] `pubspec.yaml` has valid description (130 chars max)
- [ ] All `homepage`, `repository`, `issue_tracker` URLs are correct
- [ ] `environment` sdk constraint is reasonable (`^3.0.0` minimum)
- [ ] All dependencies are stable versions
- [ ] No local path dependencies
- [ ] No path dependencies to other packages
- [ ] Dependency versions are compatible

### Licensing & Legal
- [ ] LICENSE file exists and is MIT/Apache/BSD
- [ ] Copyright headers in main files (optional)
- [ ] No proprietary code included
- [ ] Third-party attributions documented

### Platform Support
- [ ] iOS build tested and verified
- [ ] Android build tested and verified
- [ ] Web support documented (if applicable)
- [ ] Platform-specific dependencies properly configured
- [ ] Example app builds on both platforms

### Files & Structure
- [ ] No temporary or debug files
- [ ] No IDE-specific files committed (use .gitignore)
- [ ] No large binary files
- [ ] Example app is self-contained
- [ ] All source files are properly formatted

---

## Step-by-Step Publishing Process

### 1. Prepare Release

```bash
# Update version in pubspec.yaml
# Update CHANGELOG.md with new features

# Clean and verify everything
cd packages/flutter
flutter clean
flutter pub get

# Run all checks
flutter analyze
flutter test --coverage
dart format . # or: dart format --output=show .
```

### 2. Verify Package

```bash
# Dry-run publish to check for issues
dart pub publish --dry-run
```

Expected output:
```
Publishing open_k_auth 0.1.0 to pub.dev:

  |-- assets
  |-- docs
  |   |-- SETUP_ANDROID.md
  |   |-- SETUP_IOS.md
  |   |-- PUBLISHING.md
  |-- example
  |-- lib
  |-- test
  |-- CHANGELOG.md
  |-- LICENSE
  |-- pubspec.yaml
  |-- README.md
```

### 3. Tag Release (if using Git)

```bash
# Create git tag for version
git tag v0.1.0
git push origin v0.1.0

# Or through GitHub:
# 1. Go to Releases
# 2. Click "Create a new release"
# 3. Set tag name: v0.1.0
# 4. Set title: Release 0.1.0
# 5. Add description from CHANGELOG
# 6. Publish release
```

### 4. Publish to pub.dev

#### Option A: Using pub.dev Web Interface (Recommended for first-time)

1. Visit https://pub.dev/packages/open_k_auth
2. Click "Publish new version" (if updating existing package)
3. Wait for verification

#### Option B: Using Command Line

```bash
# Requires pub.dev credentials to be configured
dart pub publish

# First time setup:
# 1. Visit https://pub.dev/create-account
# 2. Sign in with Google account
# 3. Run: `dart pub token add https://pub.dev`
# 4. Follow authentication flow
# 5. Run publish command
```

### 5. Verify Publication

```bash
# Check if package is published
dart pub cache clean
dart pub get

# Or visit: https://pub.dev/packages/open_k_auth

# Install from pub.dev
flutter pub add open_k_auth

# Verify it works
dart pub global activate open_k_auth
```

---

## Publishing via GitHub Actions (Automated)

The `publish.yml` workflow automates the publishing process:

### Setup (One-time)

1. Create pub.dev credentials:
   ```bash
   dart pub token add https://pub.dev
   ```

2. Get access tokens from https://pub.dev/console/credentials

3. Add secrets to GitHub repository:
   - Go to Settings → Secrets and variables → Actions
   - Add `PUB_DEV_PUBLISH_ACCESS_TOKEN`
   - Add `PUB_DEV_PUBLISH_REFRESH_TOKEN`

### Automated Publishing

The workflow triggers on:
- **Release creation**: Automatically publishes when GitHub release is created
- **Manual trigger**: Use GitHub Actions workflow dispatch with custom reason

```bash
# Locally create and push release
git tag v0.1.0 -m "Release 0.1.0 - Initial release"
git push origin v0.1.0
```

Then create a GitHub Release from the tag, and the workflow will automatically publish.

---

## Post-Publishing Tasks

### Update Documentation

```bash
# Update your GitHub README to include pub.dev badge
# Add to README.md:
[![Pub](https://img.shields.io/pub/v/open_k_auth.svg)](https://pub.dev/packages/open_k_auth)
```

### Monitor Package

1. Watch pub.dev analytics: https://pub.dev/packages/open_k_auth/score
2. Monitor likes and pub points
3. Watch for issues and bug reports
4. Respond to questions on pub.dev

### Update Dependent Packages

If you have other packages depending on this:

```bash
# Update pubspec.yaml
dependencies:
  open_k_auth: ^0.1.0

flutter pub get
```

---

## Version Strategy

### Semantic Versioning

Follow [Semantic Versioning](https://semver.org/):

- **MAJOR** (1.0.0): Breaking API changes
- **MINOR** (0.1.0): New features, backward compatible
- **PATCH** (0.0.1): Bug fixes, backward compatible

### Example Version Timeline

```
v0.0.1 - Initial release (experimental)
v0.1.0 - Feature complete release
v0.1.1 - Bug fix release
v0.2.0 - New features (e.g., more providers)
v1.0.0 - Stable API (no more breaking changes)
```

---

## Troubleshooting

### Issue: Package validation fails

**Common reasons:**
- Invalid `pubspec.yaml` syntax
- Missing documentation
- Unused dependencies
- Analysis warnings

**Solution:**
```bash
dart pub publish --dry-run
# Review all warnings and fix them
dart pub publish --dry-run # Run again to verify
```

### Issue: Pub.dev credentials issues

**Solution:**
```bash
# Remove old credentials
dart pub token remove https://pub.dev

# Re-authenticate
dart pub token add https://pub.dev

# Follow the web browser flow
```

### Issue: Dependency conflicts

**Common causes:**
- Incompatible Flutter SDK version
- Conflicting plugin versions
- Old Dart SDK requirement

**Solution:**
```bash
# Update constraints in pubspec.yaml
environment:
  sdk: ^3.0.0  # Increase minimum version
  flutter: ">=1.17.0"

# Test with current versions
flutter pub get
flutter test
```

### Issue: Too many analysis warnings

**Solution:**
```bash
# Enable analysis options
# Create analysis_options.yaml:
linter:
  rules:
    - prefer_const_constructors
    - prefer_final_fields
    # ... add all required rules

# Fix warnings
dart fix --apply
```

---

## Package Maintenance

### After Publishing

1. **Monitor downloads**: Track usage on pub.dev
2. **Respond to feedback**: Check package issues/comments
3. **Plan updates**: Keep CHANGELOG ready for next release
4. **Security**: Monitor dependencies for vulnerabilities
5. **Compatibility**: Test on latest Flutter version

### Updating the Package

```bash
# Edit code
# Update version in pubspec.yaml
# Update CHANGELOG.md

# Verify and publish
dart pub publish --dry-run
dart pub publish
```

---

## Resources

- [Pub.dev Publishing Guide](https://dart.dev/tools/pub/publishing)
- [Semantic Versioning](https://semver.org/)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Package Guidelines](https://flutter.dev/packages)
- [Code Style](https://github.com/google/dart-style/wiki/Formatting-Rules)

---

## Questions or Issues?

If you encounter problems during publishing:

1. Check [pub.dev help](https://pub.dev/help)
2. Read [Dart FAQ](https://dart.dev/faq)
3. Open GitHub issues in the repository
4. Check GitHub Actions logs for automated publishing
