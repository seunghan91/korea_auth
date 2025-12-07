# Troubleshooting Guide

Common issues and their solutions.

## Installation Issues

### "Could not resolve all artifacts" Error

**Symptom:**
```
ERROR: Could not resolve all artifacts for configuration ':app:debugRuntimeClasspath'
```

**Solution:**
```bash
flutter clean
flutter pub get
# Android-specific
cd android
./gradlew clean
cd ..
flutter build apk  # or flutter run
```

### Pod installation fails on iOS

**Symptom:**
```
CocoaPods could not find compatible versions
```

**Solution:**
```bash
cd ios
rm -rf Pods Pod.lock
pod repo update
pod install --repo-update
cd ..
flutter pub get
flutter run
```

---

## Authentication Issues

### Google Sign-In not working on Android

**Symptom:**
- `PlatformException(sign_in_failed)`
- White screen during sign-in

**Causes & Solutions:**

1. **SHA-1 Fingerprint mismatch**
   ```bash
   # Get your release SHA-1
   cd android
   ./gradlew signingReport
   # Update in Google Cloud Console > Credentials
   ```

2. **google-services.json not found**
   ```bash
   # Ensure file is in correct location
   ls android/app/google-services.json

   # Update android/app/build.gradle
   apply plugin: 'com.google.gms.google-services'
   ```

3. **Wrong package name**
   ```bash
   # Check your actual package name
   cat android/app/src/main/AndroidManifest.xml | grep package

   # Update Google Cloud Console with exact package name
   ```

### Google Sign-In not working on iOS

**Symptom:**
- Sign-in button does nothing
- `GoogleSignInError`

**Solutions:**

1. **GoogleService-Info.plist not added**
   ```
   Xcode → Runner → Runner target → Build Phases
   Check if GoogleService-Info.plist is in "Copy Bundle Resources"
   ```

2. **URL scheme missing**
   ```
   Edit ios/Runner/Info.plist and ensure URL types are configured:
   CFBundleURLTypes with scheme: com.googleusercontent.apps.YOUR_CLIENT_ID
   ```

3. **Bundle ID mismatch**
   ```
   Xcode → Runner → General → Identity → Bundle Identifier
   Must match what's in GoogleService-Info.plist
   ```

### Kakao Login not working

**Symptom:**
- Splash screen appears but nothing happens
- `KakaoAuthException`

**Android Solutions:**

1. **Keystore hash not registered**
   ```bash
   # Get debug keystore hash
   keytool -exportcert -alias androiddebugkey \
     -keystore ~/.android/debug.keystore \
     -storepass android -keypass android | \
     openssl dgst -sha1 -binary | openssl enc -base64

   # Add to Kakao Developers > App Settings > Android Platform
   ```

2. **Package name mismatch**
   - Verify `android/app/src/main/AndroidManifest.xml` package matches Kakao settings

3. **Kakao SDK not initialized**
   ```dart
   // Must initialize before use
   await kakao.KakaoSdk.init(
     nativeAppKey: "YOUR_NATIVE_APP_KEY",
   );
   ```

**iOS Solutions:**

1. **kakaoYOUR_APP_KEY URL scheme missing**
   - Edit `ios/Runner/Info.plist`
   - Add CFBundleURLSchemes with `kakaoYOUR_NATIVE_APP_KEY`

2. **KakaoTalk app not installed**
   ```dart
   // Fallback to web login
   if (await kakao.isKakaoTalkInstalled()) {
     token = await kakao.UserApi.instance.loginWithKakaoTalk();
   } else {
     token = await kakao.UserApi.instance.loginWithKakaoAccount();
   }
   ```

### Naver Login not working

**Android Issues:**

1. **Certificate fingerprint mismatch**
   ```bash
   # Get your fingerprint
   keytool -exportcert -alias androiddebugkey \
     -keystore ~/.android/debug.keystore \
     -storepass android | \
     openssl dgst -sha1 -binary | openssl enc -base64

   # Update in Naver Developers console
   ```

2. **Client ID/Secret mismatch**
   - Verify `android/app/src/main/AndroidManifest.xml` has correct metadata

**iOS Issues:**

1. **Bundle ID not registered**
   - Go to Naver Developers > App Settings > iOS
   - Verify Bundle ID matches Xcode project

---

## State Management Issues

### Riverpod not detecting auth state changes

**Symptom:**
- User logs in but UI doesn't update

**Solution:**

1. **Ensure ProviderScope is at root**
   ```dart
   void main() {
     runApp(const ProviderScope(child: MyApp()));
   }
   ```

2. **Use ConsumerWidget or ConsumerStatefulWidget**
   ```dart
   class AuthScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) {
       final authState = ref.watch(authStateProvider);
       // Widgets update automatically
       return ...
     }
   }
   ```

3. **Don't watch in sync code**
   ```dart
   // ✅ Correct
   final authState = ref.watch(authStateProvider);

   // ❌ Wrong - watch in async context
   final authState = await ref.watch(authStateProvider).future;
   ```

---

## Token Issues

### "Token expired" error

**Symptom:**
- Sign-in works but API calls fail after some time
- `AuthException('refresh_failed', 'Token expired')`

**Solution:**

1. **Implement token refresh**
   ```dart
   try {
     await authRepo.refresh();
   } catch (e) {
     // Re-authenticate user
     await authRepo.signOut();
     // Show login screen
   }
   ```

2. **Use ServerVerification for backend validation**
   ```dart
   final verification = ServerVerification(
     provider: 'google',
     token: user.rawData['accessToken'],
   );
   // Send to backend for validation
   ```

---

## Build Issues

### "Minimum requirements" Error

**Symptom:**
```
The minSdkVersion (16) specified in your app does not meet the requirements
```

**Solution for Android:**

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 21  // Increase from 16
        targetSdkVersion 33
    }
}
```

### Pod install fails with Ruby errors

**Symptom:**
```
ERROR - CocoaPods could not find compatible versions for pod "google_sign_in"
```

**Solution:**
```bash
# Update CocoaPods
sudo gem install cocoapods

# Update pods
cd ios
pod repo update
pod deintegrate
pod install
cd ..

# Rebuild
flutter run -v
```

### "The SDK is not installed at..." Error

**Symptom:**
```
The Android SDK is not installed at...
```

**Solution:**
```bash
flutter doctor --android-licenses  # Accept licenses
flutter config --android-sdk-path /path/to/sdk
```

---

## Testing Issues

### MockAuthProvider not working

**Symptom:**
```
NoSuchMethodError: Undefined method 'signIn'
```

**Solution:**

1. **Import testing utilities**
   ```dart
   import 'package:open_k_auth/src/testing/mock_auth_provider.dart';
   ```

2. **Create mock with correct parameters**
   ```dart
   final provider = MockAuthProvider(
     uid: 'test_uid',
     displayName: 'Test User',
     email: 'test@example.com',
   );
   ```

### Tests fail with "Platform channel not available"

**Symptom:**
```
PlatformException: Platform channel returned null
```

**Solution:**

1. **Use MockAuthProvider for tests**
   ```dart
   test('sign in works', () async {
     final provider = MockAuthProvider(uid: '123');
     final user = await provider.signIn();
     expect(user.uid, '123');
   });
   ```

2. **Don't use real providers in tests**
   ```dart
   // ❌ Don't do this in tests
   final provider = GoogleAuthProvider();

   // ✅ Use mock instead
   final provider = MockAuthProvider();
   ```

---

## Performance Issues

### App freezes during sign-in

**Symptom:**
- Sign-in dialog appears but UI becomes unresponsive

**Solution:**

1. **Use async/await properly**
   ```dart
   Future<void> handleSignIn() async {
     // Show loading indicator
     setState(() => isLoading = true);

     try {
       final user = await authRepo.signIn(GoogleAuthProvider());
       // Update UI
     } catch (e) {
       // Show error
     } finally {
       setState(() => isLoading = false);
     }
   }
   ```

2. **Load user data in background**
   ```dart
   // Don't wait for extra API calls during sign-in
   authRepo.signIn(provider).then((_) {
     // Load additional data in background
     _loadUserProfile();
   });
   ```

---

## Debugging

### Enable verbose logging

```bash
# Run with verbose output
flutter run -v

# Check native Android logs
adb logcat | grep -i "open_k_auth\|kakao\|naver\|google"

# Check iOS logs
ios/Pods/Logs/
```

### Use diagnostic tools

```dart
import 'package:open_k_auth/src/utils/diagnostic.dart';

// Check current auth state
AuthDiagnostics.printCurrentState();

// List available providers
AuthDiagnostics.printAvailableProviders();
```

### Monitor token changes

```dart
// Listen to token refresh events
authRepo.tokenStream.listen((token) {
  print('Token updated: $token');
});
```

---

## Still Having Issues?

1. **Check GitHub Issues**: https://github.com/seunghan91/korea_auth/issues
2. **Create new issue** with:
   - Device/OS version
   - Flutter version: `flutter --version`
   - Detailed error message
   - Steps to reproduce
   - Minimal reproducible example

3. **Enable debug logging**:
   ```bash
   flutter run -v --dart-define=DEBUG_OPEN_K_AUTH=true
   ```

4. **Check platform-specific guides**:
   - [Android Setup](./SETUP_ANDROID.md)
   - [iOS Setup](./SETUP_IOS.md)
