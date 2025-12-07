
/// Represents an authenticated user in the Open K-Auth system.
class AuthUser {
  /// Unique identifier for the user (provider specific).
  final String uid;

  /// The user's display name, if available.
  final String? displayName;

  /// The user's email address, if available.
  final String? email;

  /// URL to the user's profile photo, if available.
  final String? photoURL;

  /// The ID of the provider used to sign in (e.g., 'google', 'kakao').
  final String providerId;

  /// Raw data returned by the underlying provider SDK.
  /// Useful for accessing provider-specific fields not covered by this class.
  final Map<String, dynamic>? rawData;

  const AuthUser({
    required this.uid,
    this.displayName,
    this.email,
    this.photoURL,
    required this.providerId,
    this.rawData,
  });

  @override
  String toString() {
    return 'AuthUser(uid: $uid, displayName: $displayName, email: $email, providerId: $providerId)';
  }
}
