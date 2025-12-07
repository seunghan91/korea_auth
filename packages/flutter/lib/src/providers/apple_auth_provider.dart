import 'dart:math';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

/// Apple 소셜 로그인 Provider
///
/// iOS 13+, macOS 10.15+ 지원
/// Android에서는 웹 기반 로그인 사용 (서버 설정 필요)
///
/// 설정 필요:
/// - Apple Developer Console에서 Sign in with Apple 활성화
/// - iOS: Runner.entitlements에 Sign in with Apple capability 추가
/// - Android: servicesId, redirectUri 설정 필요
class AppleAuthProvider implements AuthProvider {
  final String? servicesId;
  final String? redirectUri;
  final List<AppleIDAuthorizationScopes> scopes;

  AppleAuthProvider({
    this.servicesId,
    this.redirectUri,
    this.scopes = const [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
  });

  @override
  String get providerId => 'apple';

  @override
  Future<AuthUser> signIn() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw const AuthException(
          'not_available',
          'Apple 로그인을 사용할 수 없습니다. iOS 13 이상이 필요합니다.',
        );
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: scopes,
        webAuthenticationOptions: servicesId != null && redirectUri != null
            ? WebAuthenticationOptions(
                clientId: servicesId!,
                redirectUri: Uri.parse(redirectUri!),
              )
            : null,
        nonce: _generateNonce(),
      );

      // Apple은 최초 로그인 시에만 이름/이메일 제공
      // 이후 로그인에서는 null일 수 있음
      final displayName =
          credential.givenName != null || credential.familyName != null
          ? '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim()
          : null;

      return AuthUser(
        uid: credential.userIdentifier ?? '',
        displayName: displayName,
        email: credential.email,
        photoURL: null, // Apple은 프로필 사진을 제공하지 않음
        providerId: providerId,
        rawData: {
          'identityToken': credential.identityToken,
          'authorizationCode': credential.authorizationCode,
          'state': credential.state,
          'givenName': credential.givenName,
          'familyName': credential.familyName,
        },
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthException('cancelled', '사용자가 로그인을 취소했습니다');
      }
      throw AuthException('signin_failed', e.message, e);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('signin_failed', e.toString(), e);
    }
  }

  @override
  Future<void> signOut() async {
    // Apple Sign In은 클라이언트 측 로그아웃 API를 제공하지 않음
    // 앱 내부 세션만 정리하면 됨
    // 실제 Apple ID 연결 해제는 사용자가 설정에서 직접 해야 함
  }

  @override
  Future<AuthUser?> get currentUser async {
    // Apple은 세션 상태를 확인하는 API를 제공하지 않음
    // 서버에서 토큰 유효성을 검증해야 함
    return null;
  }

  @override
  Future<void> refresh() async {
    // Apple은 클라이언트 측 토큰 갱신을 지원하지 않음
    // 서버에서 refresh token으로 갱신해야 함
    throw const AuthException(
      'not_supported',
      'Apple 로그인은 클라이언트 측 토큰 갱신을 지원하지 않습니다. 서버에서 처리해야 합니다.',
    );
  }

  /// 보안을 위한 nonce 생성
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}
