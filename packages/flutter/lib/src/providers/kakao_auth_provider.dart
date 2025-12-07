
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

class KakaoAuthProvider implements AuthProvider {
  @override
  String get providerId => 'kakao';

  @override
  Future<AuthUser> signIn() async {
    try {
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          // Fallback to account login if talk login fails
          if (e is kakao.KakaoAuthException && (e.message?.contains('cancelled') ?? false)) {
             throw const AuthException('cancelled', 'User cancelled sign in');
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      final user = await kakao.UserApi.instance.me();
      
      return AuthUser(
        uid: user.id.toString(),
        displayName: user.kakaoAccount?.profile?.nickname,
        email: user.kakaoAccount?.email,
        photoURL: user.kakaoAccount?.profile?.profileImageUrl,
        providerId: providerId,
        rawData: {
          'accessToken': token.accessToken,
          'refreshToken': token.refreshToken,
          'idToken': token.idToken,
        },
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('signin_failed', e.toString(), e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await kakao.UserApi.instance.logout();
    } catch (e) {
      throw AuthException('signout_failed', e.toString(), e);
    }
  }

  @override
  Future<AuthUser?> get currentUser async {
    try {
      // Check if token exists
      if (!await kakao.AuthApi.instance.hasToken()) return null;
      
      // Verify token info
      try {
        await kakao.UserApi.instance.accessTokenInfo();
      } catch (e) {
        return null; 
      }

      final user = await kakao.UserApi.instance.me();
      return AuthUser(
        uid: user.id.toString(),
        displayName: user.kakaoAccount?.profile?.nickname,
        email: user.kakaoAccount?.email,
        photoURL: user.kakaoAccount?.profile?.profileImageUrl,
        providerId: providerId,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refresh() async {
    // Kakao SDK handles refresh automatically on API calls if refresh token is valid.
    // Explicit refresh is not typically exposed/needed unless we want to force it.
    // But we can check token info to ensure validity.
    try {
       await kakao.UserApi.instance.accessTokenInfo();
    } catch (e) {
       throw AuthException('refresh_failed', 'Token invalid or expired', e);
    }
  }
}
