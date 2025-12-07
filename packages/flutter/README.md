# Open K-Auth

**한국 앱 개발자를 위한 통합 소셜 로그인 Flutter SDK**

카카오, 네이버, 구글, 애플 - 4대 소셜 로그인을 하나의 통합된 API로 간편하게 구현하세요.

[Features](#features) • [설치](#설치) • [빠른 시작](#빠른-시작) • [Provider 설정](#provider-설정) • [플랫폼 설정](#플랫폼-설정) • [고급 사용법](#고급-사용법) • [트러블슈팅](#트러블슈팅)

## Features

| 기능 | 설명 |
|------|------|
| **통합 API** | `signIn(provider)` 하나로 4개 소셜 로그인 처리 |
| **표준화된 응답** | `AuthUser`로 모든 Provider 응답 통일 |
| **함수형 패턴** | `fold`, `when` 지원으로 깔끔한 에러 처리 |
| **상태 관리** | Riverpod 완벽 통합 (StreamProvider, Notifier) |
| **자동 토큰 갱신** | 만료 전 자동 갱신 + 이벤트 스트림 |
| **서버 검증** | 백엔드 토큰 검증용 데이터 제공 |
| **테스트 지원** | MockAuthProvider로 쉬운 단위 테스트 |
| **공식 UI 버튼** | 각 플랫폼 디자인 가이드라인 준수 버튼 제공 |

## 설치

```bash
flutter pub add open_k_auth
```

## 빠른 시작

### 1. 초기화 (Riverpod 사용)

```dart
import 'package:open_k_auth/open_k_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

### 2. 로그인

```dart
// Riverpod Notifier 사용
final user = await ref.read(authNotifierProvider.notifier).signIn(
  KakaoAuthProvider(),
);

// 또는 직접 사용
final authRepo = AuthRepository();
final user = await authRepo.signIn(KakaoAuthProvider());
print('환영합니다, ${user.displayName}!');
```

### 3. 로그인 버튼

```dart
// 개별 버튼
AuthButton.kakao(onPressed: () => signIn(AuthProviderType.kakao))
AuthButton.naver(onPressed: () => signIn(AuthProviderType.naver))
AuthButton.google(onPressed: () => signIn(AuthProviderType.google))
AuthButton.apple(onPressed: () => signIn(AuthProviderType.apple))

// 버튼 그룹
LoginButtonGroup(
  providers: [
    AuthProviderType.kakao,
    AuthProviderType.naver,
    AuthProviderType.google,
    AuthProviderType.apple,
  ],
  onPressed: (provider) => signIn(provider),
  spacing: 12,
)
```

## Provider 설정

각 Provider를 사용하려면 해당 개발자 콘솔에서 앱을 등록해야 합니다.

### 카카오

1. [Kakao Developers](https://developers.kakao.com/)에서 애플리케이션 등록
2. 앱 키 > **네이티브 앱 키** 복사
3. 플랫폼 > Android/iOS 플랫폼 등록
   - Android: 패키지명, 키 해시 등록
   - iOS: 번들 ID 등록
4. 카카오 로그인 > 활성화 설정 ON
5. 동의항목 > 필요한 정보 설정

```dart
KakaoAuthProvider()
// 카카오는 플랫폼 설정에서 앱 키를 읽어옵니다
```

### 네이버

1. [네이버 개발자 센터](https://developers.naver.com/)에서 애플리케이션 등록
2. 사용 API: 네아로 (네이버 로그인) 선택
3. 환경 추가: Android/iOS 환경 추가
   - Android: 패키지명, 다운로드 URL
   - iOS: URL Scheme, 번들 ID
4. Client ID와 Client Secret 복사

```dart
NaverAuthProvider()
// 네이버는 플랫폼 설정에서 credentials를 읽어옵니다
```

### 구글

1. [Google Cloud Console](https://console.cloud.google.com/)에서 프로젝트 생성
2. API 및 서비스 > 사용자 인증 정보 > OAuth 클라이언트 ID 만들기
3. Android 클라이언트 ID 생성
   - 패키지명, SHA-1 인증서 지문 입력
4. iOS 클라이언트 ID 생성
   - 번들 ID 입력
5. OAuth 동의 화면 설정

```dart
GoogleAuthProvider(
  clientId: 'YOUR_IOS_CLIENT_ID', // iOS용
  scopes: ['email', 'profile'],
)
```

### 애플

1. [Apple Developer](https://developer.apple.com/)에서 App ID 생성
2. Certificates, Identifiers & Profiles > Identifiers
3. App ID에서 Sign in with Apple Capability 활성화
4. Xcode에서 Signing & Capabilities > + Capability > Sign in with Apple 추가

```dart
AppleAuthProvider() // 별도 설정 불필요
```

## 플랫폼 설정

### iOS

#### 1. Info.plist 설정

`ios/Runner/Info.plist`에 다음을 추가:

```xml
<!-- 카카오 URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>kakao{YOUR_NATIVE_APP_KEY}</string>
    </array>
  </dict>
</array>

<!-- 카카오/네이버 앱 호출을 위한 설정 -->
<key>LSApplicationQueriesSchemes</key>
<array>
  <!-- 카카오 -->
  <string>kakaokompassauth</string>
  <string>kakaolink</string>
  <string>kakaotalk</string>
  <!-- 네이버 -->
  <string>naversearchapp</string>
  <string>naversearchthirdlogin</string>
</array>

<!-- 네이버 설정 -->
<key>naverServiceAppUrlScheme</key>
<string>{YOUR_URL_SCHEME}</string>
<key>naverConsumerKey</key>
<string>{YOUR_CLIENT_ID}</string>
<key>naverConsumerSecret</key>
<string>{YOUR_CLIENT_SECRET}</string>
<key>naverServiceAppName</key>
<string>{YOUR_APP_NAME}</string>

<!-- 구글 URL Scheme (역방향 클라이언트 ID) -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>com.googleusercontent.apps.{YOUR_CLIENT_ID}</string>
    </array>
  </dict>
</array>
```

#### 2. Apple Sign In 설정 (Xcode)

1. Xcode에서 프로젝트 열기
2. Runner 타겟 선택
3. Signing & Capabilities 탭
4. + Capability 클릭
5. Sign in with Apple 추가

### Android

#### 1. AndroidManifest.xml 설정

`android/app/src/main/AndroidManifest.xml`의 `<application>` 태그 안에 추가:

```xml
<!-- 카카오 로그인 -->
<activity
    android:name="com.kakao.sdk.flutter.AuthCodeCustomTabsActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:host="oauth" android:scheme="kakao{YOUR_NATIVE_APP_KEY}" />
    </intent-filter>
</activity>

<!-- 네이버 설정 -->
<meta-data
    android:name="com.naver.sdk.clientId"
    android:value="{YOUR_CLIENT_ID}" />
<meta-data
    android:name="com.naver.sdk.clientSecret"
    android:value="{YOUR_CLIENT_SECRET}" />
<meta-data
    android:name="com.naver.sdk.clientName"
    android:value="{YOUR_APP_NAME}" />
```

#### 2. MainActivity 수정 (네이버 필수)

`android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
// 변경 전
import io.flutter.embedding.android.FlutterActivity
class MainActivity: FlutterActivity()

// 변경 후
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity: FlutterFragmentActivity()
```

#### 3. 키 해시 등록 (카카오)

디버그/릴리즈 키 해시를 카카오 개발자 콘솔에 등록:

```bash
# 디버그 키 해시
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore -storepass android -keypass android | openssl sha1 -binary | openssl base64

# 릴리즈 키 해시
keytool -exportcert -alias {YOUR_ALIAS} -keystore {YOUR_KEYSTORE_PATH} | openssl sha1 -binary | openssl base64
```

## 상태 관리 선택 가이드

open_k_auth는 특정 상태 관리에 종속되지 않습니다. 프로젝트에 맞는 방식을 선택하세요.

| 상태 관리 | 추천 상황 | 추가 패키지 |
|-----------|----------|-------------|
| **Riverpod** | 새 프로젝트, 타입 안전성 중시 | `flutter_riverpod` (기본 포함) |
| **Provider** | 기존 Provider 프로젝트 | `provider` |
| **BLoC** | 대규모 앱, 이벤트 기반 | `flutter_bloc` |
| **GetX** | 빠른 개발, 간단한 문법 | `get` |
| **Vanilla** | 간단한 앱, 학습용 | 없음 |

### Riverpod (기본 제공)

```dart
// main.dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 상태 구독
ref.watch(authStateProvider).when(
  data: (state) => state.isAuthenticated ? HomeScreen() : LoginScreen(),
  loading: () => SplashScreen(),
  error: (e, _) => ErrorScreen(e),
);

// 로그인
await ref.read(authNotifierProvider.notifier).signIn(KakaoAuthProvider());
```

### Provider

```dart
// 1. AuthNotifier 정의
class AuthNotifier extends ChangeNotifier {
  final AuthRepository _authRepo;
  AuthState _state = const AuthState.initial();

  AuthNotifier(this._authRepo) {
    _authRepo.authStateChanges.listen((state) {
      _state = state;
      notifyListeners();
    });
  }

  AuthState get state => _state;
  bool get isAuthenticated => _state.isAuthenticated;

  Future<void> signIn(AuthProvider provider) async {
    _state = const AuthState.loading();
    notifyListeners();
    try {
      await _authRepo.signIn(provider);
    } on AuthException catch (e) {
      _state = AuthState.error(e);
      notifyListeners();
    }
  }
}

// 2. main.dart
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthNotifier(AuthRepository()),
      child: MyApp(),
    ),
  );
}

// 3. 위젯에서 사용
final auth = context.watch<AuthNotifier>();
if (auth.isAuthenticated) return HomeScreen();
```

### BLoC

```dart
// 1. AuthCubit 정의
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepo;

  AuthCubit(this._authRepo) : super(const AuthState.initial()) {
    _authRepo.authStateChanges.listen(emit);
  }

  Future<void> signIn(AuthProvider provider) async {
    emit(const AuthState.loading());
    try {
      await _authRepo.signIn(provider);
    } on AuthException catch (e) {
      emit(AuthState.error(e));
    }
  }
}

// 2. main.dart
void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthCubit(AuthRepository()),
      child: MyApp(),
    ),
  );
}

// 3. 위젯에서 사용
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state.isAuthenticated) return HomeScreen();
    return LoginScreen();
  },
);
```

### GetX

```dart
// 1. AuthController 정의
class AuthController extends GetxController {
  final AuthRepository _authRepo;
  final Rx<AuthState> state = const AuthState.initial().obs;

  AuthController(this._authRepo);

  @override
  void onInit() {
    super.onInit();
    _authRepo.authStateChanges.listen((s) => state.value = s);
  }

  Future<void> signIn(AuthProvider provider) async {
    state.value = const AuthState.loading();
    try {
      await _authRepo.signIn(provider);
    } on AuthException catch (e) {
      state.value = AuthState.error(e);
      Get.snackbar('오류', e.message);
    }
  }
}

// 2. main.dart
void main() {
  runApp(GetMaterialApp(
    initialBinding: BindingsBuilder(() {
      Get.put(AuthController(AuthRepository()));
    }),
    home: AuthGate(),
  ));
}

// 3. 위젯에서 사용
Obx(() {
  final auth = Get.find<AuthController>();
  if (auth.state.value.isAuthenticated) return HomeScreen();
  return LoginScreen();
});
```

### Vanilla (상태 관리 없음)

```dart
// StatefulWidget + StreamBuilder
class AuthGate extends StatelessWidget {
  final _authRepo = AuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authRepo.authStateChanges,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state?.isAuthenticated ?? false) {
          return HomeScreen(user: state!.user!);
        }
        return LoginScreen(authRepo: _authRepo);
      },
    );
  }
}

// 로그인 화면
class LoginScreen extends StatefulWidget {
  final AuthRepository authRepo;
  // ...
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signIn(AuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await widget.authRepo.signIn(provider);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
```

> 💡 **Tip**: 각 상태 관리별 상세 예시는 `lib/src/integrations/` 폴더의 예시 파일을 참고하세요.

## 고급 사용법

### 함수형 처리 (fold, when)

```dart
final result = await authRepo.signInWithResult(KakaoAuthProvider());

// fold: 성공/실패 분기
result.fold(
  onSuccess: (user) => navigateToHome(user),
  onFailure: (error) => showError(error),
);

// when: 성공/취소/실패 세분화
result.when(
  success: (user) => navigateToHome(user),
  cancelled: () => showToast('로그인이 취소되었습니다'),
  failure: (code, message) => showError(message),
);

// 체이닝
result
  .onSuccess((user) => saveUser(user))
  .onFailure((code, message) => logError(code, message));

// 사용자 정보 변환
final customUser = result.mapUser((user) => MyUser.fromAuth(user));
```

### AuthUser 필드

| 필드 | 타입 | 설명 |
|------|------|------|
| `uid` | `String` | 고유 ID |
| `email` | `String?` | 이메일 |
| `displayName` | `String?` | 표시 이름 |
| `photoURL` | `String?` | 프로필 이미지 |
| `providerId` | `String` | Provider ID |
| `rawData` | `Map?` | Provider별 원본 데이터 |

### 인증 상태 구독

```dart
// Riverpod
ref.watch(authStateProvider).when(
  data: (state) {
    if (state.isAuthenticated) {
      return HomeScreen(user: state.user!);
    }
    return LoginScreen();
  },
  loading: () => SplashScreen(),
  error: (e, _) => ErrorScreen(e),
);

// StreamBuilder
StreamBuilder<AuthState>(
  stream: authRepo.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.data?.isAuthenticated ?? false) {
      return HomeScreen(user: snapshot.data!.user!);
    }
    return LoginScreen();
  },
)
```

### 서버 연동

```dart
// 로그인 후 서버 검증 데이터 추출
final user = await authRepo.signIn(KakaoAuthProvider());
final verificationData = authRepo.getServerVerificationData();

// 백엔드 API 호출
final response = await http.post(
  Uri.parse('https://api.myserver.com/auth/social'),
  body: jsonEncode({
    'provider': verificationData.provider,
    'accessToken': verificationData.accessToken,
    'idToken': verificationData.idToken,
  }),
);

final jwt = jsonDecode(response.body)['jwt'];
```

### 토큰 갱신

```dart
// 수동 갱신
await authRepo.refresh();

// 토큰 이벤트 구독
authRepo.tokenEvents.listen((event) {
  switch (event.type) {
    case TokenEventType.expiringSoon:
      print('토큰이 곧 만료됩니다');
      break;
    case TokenEventType.expired:
      print('토큰이 만료되었습니다');
      // 재로그인 유도
      break;
    case TokenEventType.refreshed:
      print('토큰이 갱신되었습니다');
      break;
    case TokenEventType.refreshFailed:
      print('토큰 갱신 실패');
      break;
  }
});
```

### 설정 진단

```dart
final config = AuthConfig(
  kakao: KakaoConfig(appKey: 'YOUR_APP_KEY'),
  naver: NaverConfig(
    clientId: 'YOUR_CLIENT_ID',
    clientSecret: 'YOUR_CLIENT_SECRET',
    appName: 'My App',
  ),
);

final result = AuthDiagnostic.run(config);
if (result.hasErrors) {
  print(result.prettyPrint());
  // 출력 예시:
  // ❌ [kakao] 네이티브 앱 키가 설정되지 않았습니다.
  // ⚠️ [google] iOS 클라이언트 ID가 없으면 iOS에서 로그인이 실패합니다.
  // ✅ [naver] 설정이 올바릅니다.
}
```

### 테스트

```dart
import 'package:open_k_auth/testing.dart';

void main() {
  test('로그인 성공 테스트', () async {
    final mockProvider = MockAuthProvider.withTestUser(
      displayName: '테스트 유저',
      email: 'test@example.com',
    );
    final repo = AuthRepository();
    
    final user = await repo.signIn(mockProvider);
    
    expect(user.displayName, '테스트 유저');
    expect(repo.currentState.isAuthenticated, true);
  });

  test('로그인 실패 테스트', () async {
    final mockProvider = MockAuthProvider.failing(
      errorMessage: '네트워크 오류',
    );
    final repo = AuthRepository();
    
    expect(
      () => repo.signIn(mockProvider),
      throwsA(isA<AuthException>()),
    );
  });
}
```

## 전체 예제

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_k_auth/open_k_auth.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      home: ref.watch(authStateProvider).when(
        data: (state) {
          if (state.isAuthenticated) {
            return HomeScreen(user: state.user!);
          }
          return const LoginScreen();
        },
        loading: () => const SplashScreen(),
        error: (e, _) => ErrorScreen(error: e),
      ),
    );
  }
}
```

### login_screen.dart

```dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthProviderType? _loadingProvider;

  Future<void> _signIn(AuthProviderType providerType) async {
    setState(() => _loadingProvider = providerType);

    try {
      final provider = switch (providerType) {
        AuthProviderType.kakao => KakaoAuthProvider(),
        AuthProviderType.naver => NaverAuthProvider(),
        AuthProviderType.google => GoogleAuthProvider(),
        AuthProviderType.apple => AppleAuthProvider(),
      };

      await ref.read(authNotifierProvider.notifier).signIn(provider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
      }
    } on AuthException catch (e) {
      if (e.code == 'cancelled') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인이 취소되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProvider = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '로그인',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 48),
              LoginButtonGroup(
                providers: const [
                  AuthProviderType.kakao,
                  AuthProviderType.naver,
                  AuthProviderType.google,
                  AuthProviderType.apple,
                ],
                onPressed: _signIn,
                loadingProvider: _loadingProvider,
                spacing: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### home_screen.dart

```dart
class HomeScreen extends ConsumerWidget {
  final AuthUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (user.photoURL != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user.photoURL!),
              ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? '사용자',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (user.email != null) ...[
              const SizedBox(height: 8),
              Text(user.email!),
            ],
            const SizedBox(height: 24),
            Text('Provider: ${user.providerId}'),
          ],
        ),
      ),
    );
  }
}
```

## 트러블슈팅

### 카카오

#### "KAKAO_ERROR: invalid_client"
- **원인**: 네이티브 앱 키가 잘못되었거나 플랫폼 설정이 없음
- **해결**:
  1. 카카오 개발자 콘솔에서 **네이티브 앱 키** 확인 (REST API 키 아님!)
  2. 플랫폼 설정에서 패키지명/번들 ID 확인
  3. Android: 키 해시 등록 확인

#### "KAKAO_ERROR: misconfigured"
- **원인**: 카카오 로그인이 활성화되지 않음
- **해결**: 카카오 개발자 콘솔 > 카카오 로그인 > 활성화 설정 ON

#### iOS에서 카카오톡 앱이 열리지 않음
- **원인**: LSApplicationQueriesSchemes 미설정
- **해결**: Info.plist에 카카오 관련 scheme 추가

### 네이버

#### Android에서 "NaverThirdPartyLogin" 에러

- **원인**: MainActivity가 FlutterFragmentActivity를 상속하지 않음
- **해결**: MainActivity.kt 수정

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity: FlutterFragmentActivity()
```

#### "NAVER_ERROR: invalid_request"
- **원인**: Client ID 또는 Client Secret이 잘못됨
- **해결**:
  1. 네이버 개발자 센터에서 Client ID/Secret 재확인
  2. 앱 이름이 개발자 센터 등록명과 일치하는지 확인

### 구글

#### iOS에서 "GOOGLE_ERROR: missing_client_id"
- **원인**: iOS 클라이언트 ID가 설정되지 않음
- **해결**: GoogleAuthProvider에 iosClientId 설정

#### Android에서 "GOOGLE_ERROR: sign_in_failed"
- **원인**: SHA-1 인증서 지문이 등록되지 않음
- **해결**:
  1. SHA-1 지문 확인: `./gradlew signingReport`
  2. Google Cloud Console에서 SHA-1 인증서 지문 추가

### 애플

#### "APPLE_ERROR: not_available"
- **원인**: iOS 13 미만이거나 Capability가 추가되지 않음
- **해결**:
  1. Xcode > Signing & Capabilities > Sign in with Apple 추가
  2. Apple Developer에서 App ID에 Sign in with Apple 활성화

#### 이름/이메일이 null로 반환됨
- **원인**: Apple은 최초 로그인 시에만 이름/이메일 제공
- **해결**:
  - 최초 로그인 시 받은 정보를 서버에 저장
  - 테스트 시: Apple ID 설정 > 암호 및 보안 > Apple로 로그인하는 앱에서 앱 연결 해제 후 재시도

### 공통

#### "AuthException: no_provider"
- **원인**: SDK가 초기화되지 않음
- **해결**: Provider를 올바르게 생성했는지 확인

설정 진단 사용:
```dart
final result = AuthDiagnostic.run(config);
print(result.prettyPrint());
```

### 에러 코드

| 코드 | 설명 |
|------|------|
| `cancelled` | 사용자가 로그인 취소 |
| `network_error` | 네트워크 오류 |
| `signin_failed` | 로그인 실패 |
| `signout_failed` | 로그아웃 실패 |
| `refresh_failed` | 토큰 갱신 실패 |
| `not_available` | 해당 플랫폼에서 사용 불가 |
| `not_supported` | 지원하지 않는 기능 |

## 공식 문서 참고

각 Provider의 상세 설정은 공식 문서를 참고하세요:

- [Kakao Flutter SDK](https://developers.kakao.com/docs/latest/ko/kakaologin/flutter)
- [flutter_naver_login](https://pub.dev/packages/flutter_naver_login)
- [google_sign_in](https://pub.dev/packages/google_sign_in)
- [sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)

## Contributing

이슈와 PR을 환영합니다!

## License

MIT License
