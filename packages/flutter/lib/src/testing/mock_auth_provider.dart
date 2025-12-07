import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

/// 테스트용 Mock AuthProvider
///
/// 실제 소셜 로그인 없이 인증 플로우를 테스트할 수 있습니다.
///
/// 사용 예시:
/// ```dart
/// // 테스트 설정
/// final mockProvider = MockAuthProvider(
///   providerId: 'mock',
///   mockUser: AuthUser(
///     uid: 'test-123',
///     displayName: '테스트 유저',
///     email: 'test@example.com',
///     providerId: 'mock',
///   ),
/// );
///
/// // 로그인 테스트
/// final user = await mockProvider.signIn();
/// expect(user.uid, 'test-123');
/// ```
class MockAuthProvider implements AuthProvider {
  @override
  final String providerId;

  /// Mock 사용자 정보
  final AuthUser? mockUser;

  /// 로그인 시 발생시킬 에러 (테스트용)
  final AuthException? signInError;

  /// 로그아웃 시 발생시킬 에러 (테스트용)
  final AuthException? signOutError;

  /// 로그인 지연 시간 (네트워크 지연 시뮬레이션)
  final Duration? signInDelay;

  AuthUser? _currentUser;
  bool _isSignedIn = false;

  MockAuthProvider({
    this.providerId = 'mock',
    this.mockUser,
    this.signInError,
    this.signOutError,
    this.signInDelay,
  });

  /// 미리 정의된 테스트 유저로 Mock Provider 생성
  factory MockAuthProvider.withTestUser({
    String uid = 'test-user-123',
    String displayName = '테스트 유저',
    String email = 'test@example.com',
    String? photoURL,
    String providerId = 'mock',
  }) {
    return MockAuthProvider(
      providerId: providerId,
      mockUser: AuthUser(
        uid: uid,
        displayName: displayName,
        email: email,
        photoURL: photoURL,
        providerId: providerId,
        rawData: {
          'accessToken':
              'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
          'refreshToken': 'mock-refresh-token',
        },
      ),
    );
  }

  /// 로그인 실패를 시뮬레이션하는 Mock Provider 생성
  factory MockAuthProvider.failing({
    String providerId = 'mock',
    String errorCode = 'mock_error',
    String errorMessage = '테스트 에러',
  }) {
    return MockAuthProvider(
      providerId: providerId,
      signInError: AuthException(errorCode, errorMessage),
    );
  }

  @override
  Future<AuthUser> signIn() async {
    if (signInDelay != null) {
      await Future.delayed(signInDelay!);
    }

    if (signInError != null) {
      throw signInError!;
    }

    if (mockUser == null) {
      throw const AuthException('no_mock_user', 'Mock user not configured');
    }

    _currentUser = mockUser;
    _isSignedIn = true;
    return mockUser!;
  }

  @override
  Future<void> signOut() async {
    if (signOutError != null) {
      throw signOutError!;
    }

    _currentUser = null;
    _isSignedIn = false;
  }

  @override
  Future<AuthUser?> get currentUser async {
    return _isSignedIn ? _currentUser : null;
  }

  @override
  Future<void> refresh() async {
    if (!_isSignedIn || _currentUser == null) {
      throw const AuthException(
        'not_signed_in',
        'No active session to refresh',
      );
    }
    // Mock refresh - just return success
  }

  /// 현재 로그인 상태
  bool get isSignedIn => _isSignedIn;

  /// 로그인 상태 직접 설정 (테스트용)
  void setSignedIn(bool value, [AuthUser? user]) {
    _isSignedIn = value;
    _currentUser = value ? (user ?? mockUser) : null;
  }
}

/// 여러 Provider를 Mock으로 대체하는 헬퍼
class MockAuthProviders {
  final Map<String, MockAuthProvider> _providers = {};

  MockAuthProviders();

  /// Mock Provider 등록
  void register(MockAuthProvider provider) {
    _providers[provider.providerId] = provider;
  }

  /// Provider ID로 Mock Provider 가져오기
  MockAuthProvider? get(String providerId) => _providers[providerId];

  /// 모든 Mock Provider 초기화
  void resetAll() {
    for (final provider in _providers.values) {
      provider.setSignedIn(false);
    }
  }

  /// 기본 테스트 Provider 세트 생성
  static MockAuthProviders defaults() {
    final providers = MockAuthProviders();
    providers.register(
      MockAuthProvider.withTestUser(
        providerId: 'kakao',
        displayName: '카카오 테스트',
        email: 'kakao@test.com',
      ),
    );
    providers.register(
      MockAuthProvider.withTestUser(
        providerId: 'naver',
        displayName: '네이버 테스트',
        email: 'naver@test.com',
      ),
    );
    providers.register(
      MockAuthProvider.withTestUser(
        providerId: 'google',
        displayName: 'Google Test',
        email: 'google@test.com',
      ),
    );
    providers.register(
      MockAuthProvider.withTestUser(
        providerId: 'apple',
        displayName: 'Apple Test',
        email: 'apple@test.com',
      ),
    );
    return providers;
  }
}
