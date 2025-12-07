
import 'auth_user.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

/// Represents the current state of authentication.
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final Object? error;

  const AuthState._({
    required this.status,
    this.user,
    this.error,
  });

  const AuthState.initial() : this._(status: AuthStatus.initial);
  const AuthState.authenticated(AuthUser user) : this._(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated() : this._(status: AuthStatus.unauthenticated);
  const AuthState.loading() : this._(status: AuthStatus.loading);
  const AuthState.error(Object error) : this._(status: AuthStatus.error, error: error);
  
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasError => status == AuthStatus.error;
}
