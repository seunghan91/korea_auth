/// 서버 검증용 데이터
///
/// 클라이언트에서 소셜 로그인 후 백엔드 서버에서 토큰을 검증할 때 사용합니다.
///
/// 사용 예시:
/// ```dart
/// final verificationData = await authRepo.getServerVerificationData();
/// final response = await http.post(
///   Uri.parse('https://api.example.com/auth/verify'),
///   body: verificationData.toJson(),
/// );
/// ```
class ServerVerificationData {
  /// 인증 제공자 (kakao, naver, google, apple)
  final String provider;

  /// 액세스 토큰 (카카오, 네이버, 구글)
  final String? accessToken;

  /// ID 토큰 (구글, 애플 - JWT 형식)
  final String? idToken;

  /// 인증 코드 (애플 - 서버에서 토큰 교환 시 사용)
  final String? authorizationCode;

  /// 사용자 ID (클라이언트에서 받은 값, 서버에서 검증 필요)
  final String? userId;

  const ServerVerificationData({
    required this.provider,
    this.accessToken,
    this.idToken,
    this.authorizationCode,
    this.userId,
  });

  /// JSON 변환
  Map<String, dynamic> toJson() => {
    'provider': provider,
    if (accessToken != null) 'accessToken': accessToken,
    if (idToken != null) 'idToken': idToken,
    if (authorizationCode != null) 'authorizationCode': authorizationCode,
    if (userId != null) 'userId': userId,
  };

  @override
  String toString() =>
      'ServerVerificationData(provider: $provider, hasAccessToken: ${accessToken != null}, hasIdToken: ${idToken != null})';
}

/// 서버 검증 결과
class ServerVerificationResult {
  /// 검증 성공 여부
  final bool success;

  /// 서버에서 반환한 사용자 ID
  final String? userId;

  /// 서버에서 반환한 세션 토큰 또는 JWT
  final String? sessionToken;

  /// 에러 메시지
  final String? errorMessage;

  /// 서버 응답 원본
  final Map<String, dynamic>? rawResponse;

  const ServerVerificationResult({
    required this.success,
    this.userId,
    this.sessionToken,
    this.errorMessage,
    this.rawResponse,
  });

  factory ServerVerificationResult.success({
    required String userId,
    String? sessionToken,
    Map<String, dynamic>? rawResponse,
  }) => ServerVerificationResult(
    success: true,
    userId: userId,
    sessionToken: sessionToken,
    rawResponse: rawResponse,
  );

  factory ServerVerificationResult.failure({
    required String errorMessage,
    Map<String, dynamic>? rawResponse,
  }) => ServerVerificationResult(
    success: false,
    errorMessage: errorMessage,
    rawResponse: rawResponse,
  );
}
