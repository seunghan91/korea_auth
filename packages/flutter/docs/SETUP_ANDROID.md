# Android Setup Guide for Open K-Auth

This guide covers the necessary setup steps to enable social authentication on Android.

## Table of Contents

- [Google Sign-In](#google-sign-in)
- [Kakao Login](#kakao-login)
- [Naver Login](#naver-login)
- [Apple Sign-In (Web)](#apple-sign-in-web)

---

## Google Sign-In

### 1. Create Google Cloud Project

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google+ API**

### 2. Create Android OAuth Credentials

1. Navigate to **Credentials** in the left sidebar
2. Click **Create Credentials** → **OAuth 2.0 Client ID**
3. Select **Android** as the application type
4. Generate a SHA-1 fingerprint for your app:

```bash
cd android
./gradlew signingReport
```

Look for the SHA-1 fingerprint in the output.

5. Add your package name and SHA-1 fingerprint
6. Download the **google-services.json** file

### 3. Add google-services.json to Android Project

1. Place `google-services.json` in `android/app/`
2. Update `android/build.gradle`:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

3. Update `android/app/build.gradle`:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    // ... other dependencies
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

### 4. Update AndroidManifest.xml

Add the following permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Kakao Login

### 1. Register Your App on Kakao Developers

1. Visit [Kakao Developers](https://developers.kakao.com/)
2. Log in or create an account
3. Click **My Application** → **Create Application**
4. Fill in app information:
   - App Name: Your app name
   - Company: Your company (can be your name)
5. Accept terms and create the app
6. You'll receive a **Native App Key**

### 2. Set Up Android Platform

1. In your app settings, go to **Platform** tab
2. Add **Android** platform
3. Fill in:
   - Package Name: Your app's package name
   - Main Activity Class Path: `com.example.app.MainActivity`
4. Get your **Keystore Hash** and add it:

```bash
# Get debug keystore hash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl dgst -sha1 -binary | openssl enc -base64
```

### 3. Update build.gradle

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            kakao_app_key: "YOUR_NATIVE_APP_KEY",
            kakao_scheme: "kakao${YOUR_NATIVE_APP_KEY}"
        ]
    }
}

dependencies {
    implementation 'com.kakao.sdk:v2-user:2.19.0'
}
```

### 4. Update AndroidManifest.xml

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />

    <application>
        <activity
            android:name="com.kakao.sdk.auth.AuthCodeActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="@string/kakao_scheme"
                    android:host="oauth" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 5. Create strings.xml for Kakao Settings

```xml
<!-- android/app/src/main/res/values/strings.xml -->
<resources>
    <string name="app_name">Your App Name</string>
    <string name="kakao_app_key">YOUR_NATIVE_APP_KEY</string>
    <string name="kakao_scheme">kakaoYOUR_NATIVE_APP_KEY</string>
</resources>
```

---

## Naver Login

### 1. Register Your App on Naver Developers

1. Visit [Naver Developers](https://developers.naver.com/)
2. Log in or sign up
3. Go to **My Applications** → **Application Registration**
4. Fill in application details:
   - App Name: Your app name
   - Use: Mobile App
5. Accept terms and register
6. You'll receive **Client ID** and **Client Secret**

### 2. Set Up Android Platform

1. In your app settings, go to **API Settings**
2. Add Android platform:
   - Package Name: Your app's package name
   - Certificate Fingerprint: (see below)
   - App Name: Your app name
3. Get your certificate fingerprint:

```bash
# Debug keystore
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl dgst -sha1 -binary | openssl enc -base64
```

### 3. Update build.gradle

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            naver_client_id: "YOUR_CLIENT_ID",
            naver_client_secret: "YOUR_CLIENT_SECRET",
            naver_client_name: "Your App Name"
        ]
    }
}

dependencies {
    implementation 'com.naver.nid:naveridlogin-android:5.11.0'
}
```

### 4. Update AndroidManifest.xml

```xml
<manifest>
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <!-- Naver Login Configuration -->
        <meta-data
            android:name="com.naver.sdk.ClientId"
            android:value="@string/naver_client_id" />
        <meta-data
            android:name="com.naver.sdk.ClientSecret"
            android:value="@string/naver_client_secret" />
        <meta-data
            android:name="com.naver.sdk.ClientName"
            android:value="@string/naver_client_name" />
    </application>
</manifest>
```

---

## Apple Sign-In (Web)

Apple Sign-In on Android uses web-based authentication.

### 1. Create Apple Developer Account

1. Visit [Apple Developer](https://developer.apple.com/)
2. Sign up or log in with your Apple ID
3. Go to **Account** → **Certificates, Identifiers & Profiles**
4. Create a new identifier for your app

### 2. Set Up Sign in with Apple

1. In your app identifier settings, enable **Sign in with Apple**
2. Configure return URLs for web-based authentication
3. Generate a **Services ID** with return URL pointing to your backend

### 3. Example Implementation

For Android, you'd typically handle Apple sign-in through a web-based flow:

```dart
// Example: Handle Apple sign-in on Android
try {
  final credential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    webAuthenticationOptions: servicesId != null && redirectUri != null
        ? WebAuthenticationOptions(
            clientId: servicesId!,
            redirectUri: Uri.parse(redirectUri!),
          )
        : null,
  );
  // Handle credential
} catch (e) {
  // Handle error
}
```

---

## Complete AndroidManifest.xml Example

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.app">

    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application
        android:label="@string/app_name"
        android:icon="@mipmap/ic_launcher">

        <!-- Activities -->
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <!-- Kakao OAuth Activity -->
        <activity
            android:name="com.kakao.sdk.auth.AuthCodeActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="@string/kakao_scheme"
                    android:host="oauth" />
            </intent-filter>
        </activity>

        <!-- Google Services -->
        <service
            android:name="com.google.android.gms.auth.api.signin.SignInService"
            android:exported="true" />

        <!-- Naver Configuration -->
        <meta-data
            android:name="com.naver.sdk.ClientId"
            android:value="@string/naver_client_id" />
        <meta-data
            android:name="com.naver.sdk.ClientSecret"
            android:value="@string/naver_client_secret" />
        <meta-data
            android:name="com.naver.sdk.ClientName"
            android:value="@string/naver_client_name" />

        <!-- Kakao Configuration -->
        <meta-data
            android:name="com.kakao.sdk.AppKey"
            android:value="@string/kakao_app_key" />

    </application>

</manifest>
```

---

## Troubleshooting

### Google Sign-In Issues
- **Issue**: `PlatformException(sign_in_failed, ... ,null)`
- **Solution**: Ensure `google-services.json` is in correct location and SHA-1 matches

### Kakao Login Issues
- **Issue**: Package name mismatch
- **Solution**: Verify package name in `AndroidManifest.xml` matches Kakao app settings

### Naver Login Issues
- **Issue**: Certificate fingerprint mismatch
- **Solution**: Update certificate hash in Naver developer console

---

## Next Steps

- Check [iOS Setup Guide](./SETUP_IOS.md)
- Review [Quick Start Guide](../README.md)
