/// 카카오 설정
class KakaoConfig {
  /// 네이티브 앱 키 (필수)
  final String appKey;

  /// 요청할 동의 항목
  final List<String> scopes;

  const KakaoConfig({
    required this.appKey,
    this.scopes = const ['profile_nickname', 'profile_image', 'account_email'],
  });
}

/// 네이버 설정
class NaverConfig {
  /// Client ID (필수)
  final String clientId;

  /// Client Secret (필수)
  final String clientSecret;

  /// 앱 이름 (동의 화면에 표시, 필수)
  final String appName;

  /// URL Scheme (iOS용)
  final String? urlScheme;

  const NaverConfig({
    required this.clientId,
    required this.clientSecret,
    required this.appName,
    this.urlScheme,
  });
}

/// 구글 설정
class GoogleConfig {
  /// iOS 클라이언트 ID (iOS 필수)
  final String? iosClientId;

  /// 서버 클라이언트 ID (백엔드 연동 시)
  final String? serverClientId;

  /// 요청할 scope
  final List<String> scopes;

  const GoogleConfig({
    this.iosClientId,
    this.serverClientId,
    this.scopes = const ['email', 'profile'],
  });
}

/// 애플 설정
class AppleConfig {
  /// Services ID (Android 웹 로그인용)
  final String? servicesId;

  /// Redirect URI (Android 웹 로그인용)
  final String? redirectUri;

  const AppleConfig({this.servicesId, this.redirectUri});
}

/// 전체 인증 설정
class AuthConfig {
  final KakaoConfig? kakao;
  final NaverConfig? naver;
  final GoogleConfig? google;
  final AppleConfig? apple;

  const AuthConfig({this.kakao, this.naver, this.google, this.apple});

  /// 설정된 Provider 목록
  List<String> get configuredProviders {
    final providers = <String>[];
    if (kakao != null) providers.add('kakao');
    if (naver != null) providers.add('naver');
    if (google != null) providers.add('google');
    if (apple != null) providers.add('apple');
    return providers;
  }
}
