import 'package:flutter_naver_login/flutter_naver_login.dart';
import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

/// Naver 소셜 로그인 Provider
///
/// 사용 전 네이버 개발자 센터에서 앱 등록 필요:
/// https://developers.naver.com/apps
///
/// Android: AndroidManifest.xml에 client_id, client_secret, client_name 설정
/// iOS: Info.plist에 URL Scheme 설정
class NaverAuthProvider implements AuthProvider {
  @override
  String get providerId => 'naver';

  @override
  Future<AuthUser> signIn() async {
    try {
      final result = await FlutterNaverLogin.logIn();

      if (result.status == NaverLoginStatus.error) {
        throw const AuthException('signin_failed', '네이버 로그인 실패');
      }

      if (result.status != NaverLoginStatus.loggedIn) {
        throw const AuthException('cancelled', '사용자가 로그인을 취소했습니다');
      }

      final account = result.account;
      if (account == null) {
        throw const AuthException('signin_failed', '사용자 정보를 가져올 수 없습니다');
      }

      final token = await FlutterNaverLogin.getCurrentAccessToken();

      final displayName = (account.name.isNotEmpty)
          ? account.name
          : account.nickname;

      return AuthUser(
        uid: account.id,
        displayName: displayName,
        email: account.email,
        photoURL: account.profileImage,
        providerId: providerId,
        rawData: {
          'accessToken': token.accessToken,
          'refreshToken': token.refreshToken,
          'tokenType': token.tokenType,
          'expiresAt': token.expiresAt,
          'nickname': account.nickname,
          'gender': account.gender,
          'age': account.age,
          'birthday': account.birthday,
          'mobile': account.mobile,
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
      await FlutterNaverLogin.logOut();
    } catch (e) {
      throw AuthException('signout_failed', e.toString(), e);
    }
  }

  /// 네이버 계정 연결 해제 (앱 연동 완전 해제)
  Future<void> unlink() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
    } catch (e) {
      throw AuthException('unlink_failed', e.toString(), e);
    }
  }

  @override
  Future<AuthUser?> get currentUser async {
    try {
      final token = await FlutterNaverLogin.getCurrentAccessToken();
      if (!token.isValid()) return null;

      final account = await FlutterNaverLogin.getCurrentAccount();

      return AuthUser(
        uid: account.id,
        displayName: account.name.isNotEmpty ? account.name : account.nickname,
        email: account.email,
        photoURL: account.profileImage,
        providerId: providerId,
        rawData: {
          'accessToken': token.accessToken,
          'refreshToken': token.refreshToken,
        },
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> refresh() async {
    try {
      // 네이버 SDK는 토큰 갱신을 자동으로 처리함
      // getCurrentAccessToken 호출 시 필요하면 자동 갱신
      final token = await FlutterNaverLogin.getCurrentAccessToken();
      if (!token.isValid()) {
        throw const AuthException('refresh_failed', '토큰이 유효하지 않습니다');
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('refresh_failed', e.toString(), e);
    }
  }
}
