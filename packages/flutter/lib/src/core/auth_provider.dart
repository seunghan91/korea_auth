
import 'auth_user.dart';

/// Interface that all authentication providers must implement.
abstract class AuthProvider {
  /// Unique identifier for the provider (e.g., 'google', 'kakao').
  String get providerId;

  /// Initiates the sign-in process.
  Future<AuthUser> signIn();

  /// Signs out the current user.
  Future<void> signOut();

  /// Returns the currently signed-in user, or null if none.
  Future<AuthUser?> get currentUser;

  /// Refreshes the authentication token/session if supported.
  /// Should throw [AuthException] if refresh fails.
  Future<void> refresh();
}
