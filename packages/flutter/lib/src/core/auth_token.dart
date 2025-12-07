/// 인증 토큰 정보를 담는 클래스
class AuthToken {
  /// 액세스 토큰
  final String accessToken;

  /// 리프레시 토큰 (없을 수 있음)
  final String? refreshToken;

  /// ID 토큰 (OpenID Connect 지원 시)
  final String? idToken;

  /// 토큰 만료 시간
  final DateTime? expiresAt;

  /// 토큰 타입 (보통 'Bearer')
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// 토큰이 만료되었는지 확인
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 토큰이 곧 만료되는지 확인 (기본 5분 전)
  bool isExpiringSoon([Duration threshold = const Duration(minutes: 5)]) {
    if (expiresAt == null) return false;
    return DateTime.now().add(threshold).isAfter(expiresAt!);
  }

  /// 토큰이 유효한지 확인
  bool get isValid => accessToken.isNotEmpty && !isExpired;

  /// Authorization 헤더 값
  String get authorizationHeader => '$tokenType $accessToken';

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'expiresAt': expiresAt?.toIso8601String(),
    'tokenType': tokenType,
  };

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    idToken: json['idToken'] as String?,
    expiresAt: json['expiresAt'] != null
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
    tokenType: json['tokenType'] as String? ?? 'Bearer',
  );

  @override
  String toString() =>
      'AuthToken(accessToken: ${accessToken.substring(0, 10)}..., expiresAt: $expiresAt)';
}
