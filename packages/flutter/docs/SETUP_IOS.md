# iOS Setup Guide for Open K-Auth

This guide covers the necessary setup steps to enable social authentication on iOS.

## Table of Contents

- [Google Sign-In](#google-sign-in)
- [Kakao Login](#kakao-login)
- [Naver Login](#naver-login)
- [Apple Sign-In](#apple-sign-in)

---

## Google Sign-In

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google+ API**

### 2. Create iOS OAuth Credentials

1. Navigate to **Credentials** in the left sidebar
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **iOS** as the application type
4. Fill in:
   - App name: Your app name
   - Bundle ID: Found in Xcode project settings (e.g., `com.example.app`)
   - Team ID: Your Apple Developer Team ID
5. Download the **GoogleService-Info.plist** file

### 3. Add GoogleService-Info.plist to iOS Project

1. Open your iOS project in Xcode: `ios/Runner.xcworkspace`
2. Add `GoogleService-Info.plist` to the **Runner** target:
   - Right-click on **Runner** in project navigator
   - Select **Add Files to "Runner"...**
   - Select `GoogleService-Info.plist`
   - Ensure "Copy items if needed" is checked
3. Verify the file is added to the **Runner** target in Build Phases

### 4. Update Runner.xcconfig

Add to `ios/Flutter/Generated.xcconfig`:

```
GOOGLE_SIGN_IN_CLIENT_ID=YOUR_CLIENT_ID.apps.googleusercontent.com
```

### 5. Update Info.plist

Add URL schemes for Google Sign-In:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>googlechrome</string>
    <string>googleapp</string>
    <string>googlegmail</string>
</array>
```

---

## Kakao Login

### 1. Register Your App on Kakao Developers

1. Visit [Kakao Developers](https://developers.kakao.com/)
2. Log in or create an account
3. Click **My Application** → **Create Application**
4. Fill in app information and create the app
5. You'll receive a **Native App Key**

### 2. Set Up iOS Platform

1. In your app settings, go to **Platform** tab
2. Add **iOS** platform
3. Fill in:
   - Bundle ID: Your app's bundle ID (e.g., `com.example.app`)
   - Team ID: (optional) Your Apple Developer Team ID

### 3. Update Podfile

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      # Add Kakao SDK settings
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'KAKAO_APP_KEY=YOUR_NATIVE_APP_KEY',
      ]
    end
  end
end
```

### 4. Update Info.plist

Add Kakao settings:

```xml
<key>KAKAO_APP_KEY</key>
<string>YOUR_NATIVE_APP_KEY</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>kakaoYOUR_NATIVE_APP_KEY</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>kakaokompassauth</string>
    <string>kakaolink</string>
    <string>kakaotalk</string>
    <string>kakaotalkprofile</string>
    <string>kakaoplus</string>
    <string>naversearchapp</string>
    <string>naversearchthk</string>
</array>
```

---

## Naver Login

### 1. Register Your App on Naver Developers

1. Visit [Naver Developers](https://developers.naver.com/)
2. Log in or sign up
3. Go to **My Applications** → **Application Registration**
4. Fill in application details
5. You'll receive **Client ID** and **Client Secret**

### 2. Set Up iOS Platform

1. In your app settings, go to **API Settings**
2. Add iOS platform:
   - Bundle ID: Your app's bundle ID
   - App Name: Your app name

### 3. Update Podfile

```ruby
target 'Runner' do
  pod 'naver-login-sdk-ios'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      flutter_additional_ios_build_settings(target)
    end
  end
end
```

### 4. Update Info.plist

Add Naver settings:

```xml
<key>NAVER_CLIENT_ID</key>
<string>YOUR_CLIENT_ID</string>

<key>NAVER_CLIENT_SECRET</key>
<string>YOUR_CLIENT_SECRET</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>naversearchapp</string>
            <string>naversearchthk</string>
            <string>naver</string>
        </array>
    </dict>
</array>

<key>LSApplicationQueriesSchemes</key>
<array>
    <string>naversearchapp</string>
    <string>naversearchthk</string>
    <string>navercafe</string>
</array>
```

---

## Apple Sign-In

Apple Sign-In is the most straightforward to set up on iOS.

### 1. Set Up Signing & Capabilities in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select **Runner** project and **Runner** target
3. Go to **Signing & Capabilities** tab
4. Ensure you have a valid development team selected
5. Click **+ Capability** and add:
   - **Sign in with Apple**

### 2. Create App ID with Sign in with Apple

1. Visit [Apple Developer](https://developer.apple.com/)
2. Go to **Certificates, Identifiers & Profiles**
3. Select **Identifiers** and your app identifier
4. Enable **Sign in with Apple** capability

### 3. Update Info.plist

```xml
<!--
  Usually handled automatically by the sign_in_with_apple plugin
  But you can optionally configure it:
-->
```

### 4. Handle User Session (Optional)

You can query the user's sign-in state:

```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Check if Sign in with Apple is available
final isAvailable = await SignInWithApple.isAvailable();

// In your app lifecycle:
// Check if user is still signed in (iOS 13.0+)
try {
  final credentials = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  );
} on SignInWithAppleAuthorizationException catch (e) {
  // Handle cancellation or other errors
}
```

---

## Complete Info.plist Example

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Application Properties -->
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Your App Name</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>

    <!-- Support iOS 11.0+ -->
    <key>MinimumOSVersion</key>
    <string>11.0</string>

    <!-- Google Sign-In -->
    <key>GIDClientID</key>
    <string>YOUR_CLIENT_ID.apps.googleusercontent.com</string>

    <key>CFBundleURLTypes</key>
    <array>
        <!-- Google URL Scheme -->
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
            </array>
        </dict>
        <!-- Kakao URL Scheme -->
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>kakaoYOUR_NATIVE_APP_KEY</string>
            </array>
        </dict>
        <!-- Naver URL Scheme -->
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>naversearchapp</string>
                <string>naversearchthk</string>
            </array>
        </dict>
    </array>

    <!-- Application Query Schemes -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <!-- Google -->
        <string>googlechrome</string>
        <string>googleapp</string>
        <!-- Kakao -->
        <string>kakaokompassauth</string>
        <string>kakaolink</string>
        <string>kakaotalk</string>
        <string>kakaotalkprofile</string>
        <!-- Naver -->
        <string>naversearchapp</string>
        <string>naversearchthk</string>
        <string>navercafe</string>
    </array>

    <!-- Required Privacy Keys -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access for sign-in</string>

    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access</string>

    <!-- Phone Requirement -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>

</dict>
</plist>
```

---

## Troubleshooting

### Google Sign-In Issues
- **Issue**: `PlatformException(sign_in_failed)`
- **Solution**: Ensure `GoogleService-Info.plist` is added to Runner target and Bundle ID matches

### Kakao Login Issues
- **Issue**: App crashes with Kakao SDK error
- **Solution**: Verify Bundle ID matches Kakao developer console

### Naver Login Issues
- **Issue**: Redirect loop or auth failure
- **Solution**: Check LSApplicationQueriesSchemes includes required Naver schemes

### Apple Sign-In Issues
- **Issue**: `unsupported_response_type` error
- **Solution**: Verify **Sign in with Apple** capability is enabled in Xcode

---

## Pod Installation Issues

If you encounter pod-related issues:

```bash
cd ios
rm -rf Pods Pod.lock
cd ..
flutter pub get
cd ios
pod repo update
pod install --repo-update
cd ..
```

---

## Next Steps

- Check [Android Setup Guide](./SETUP_ANDROID.md)
- Review [Quick Start Guide](../README.md)
- See example implementation in `example/lib/main.dart`
