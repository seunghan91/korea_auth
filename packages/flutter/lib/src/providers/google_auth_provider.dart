
import 'package:google_sign_in/google_sign_in.dart';
import '../core/auth_provider.dart';
import '../core/auth_user.dart';
import '../core/auth_exception.dart';

class GoogleAuthProvider implements AuthProvider {
  final GoogleSignIn _googleSignIn;

  GoogleAuthProvider({
    List<String> scopes = const ['email'],
    String? clientId,
  }) : _googleSignIn = GoogleSignIn(scopes: scopes, clientId: clientId);

  @override
  String get providerId => 'google';

  @override
  Future<AuthUser> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException('cancelled', 'User cancelled sign in');
      }
      
      final auth = await account.authentication;
      
      return AuthUser(
        uid: account.id,
        displayName: account.displayName,
        email: account.email,
        photoURL: account.photoUrl,
        providerId: providerId,
        rawData: {
          'idToken': auth.idToken,
          'accessToken': auth.accessToken,
          'serverAuthCode': account.serverAuthCode,
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
      await _googleSignIn.signOut();
    } catch (e) {
      throw AuthException('signout_failed', e.toString(), e);
    }
  }

  @override
  Future<AuthUser?> get currentUser async {
    final account = _googleSignIn.currentUser;
    if (account == null) return null;
    
    // We might need to re-authenticate to get fresh tokens if needed
    // For now, just return basic info
    return AuthUser(
      uid: account.id,
      displayName: account.displayName,
      email: account.email,
      photoURL: account.photoUrl,
      providerId: providerId,
    );
  }

  @override
  Future<void> refresh() async {
    // GoogleSignIn handles token refresh internally usually when requesting authentication
    // But we can force silent sign in
    try {
      await _googleSignIn.signInSilently();
    } catch (e) {
      throw AuthException('refresh_failed', e.toString(), e);
    }
  }
}
