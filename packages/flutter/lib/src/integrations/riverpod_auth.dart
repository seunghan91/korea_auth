import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import '../core/auth_state.dart';
import '../core/auth_user.dart';
import '../core/auth_provider.dart';
import '../core/token_manager.dart';
import '../core/server_verification.dart';

/// Provider for the [AuthRepository] instance.
///
/// 사용 예시:
/// ```dart
/// final repo = ref.read(authRepositoryProvider);
/// await repo.signIn(GoogleAuthProvider());
/// ```
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final repo = AuthRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// StreamProvider that emits [AuthState] changes.
///
/// 사용 예시:
/// ```dart
/// ref.watch(authStateProvider).when(
///   data: (state) => state.isAuthenticated ? HomeScreen() : LoginScreen(),
///   loading: () => LoadingScreen(),
///   error: (e, _) => ErrorScreen(e),
/// );
/// ```
final authStateProvider = StreamProvider<AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

/// Provider for the current authenticated user.
/// Returns null if not authenticated.
final currentUserProvider = Provider<AuthUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (state) => state.user);
});

/// Provider that returns true if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.whenOrNull(data: (state) => state.isAuthenticated) ?? false;
});

/// Provider that returns true if authentication is loading.
final isAuthLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading ||
      (authState.whenOrNull(data: (state) => state.isLoading) ?? false);
});

/// StreamProvider for token events (refresh, expiry, etc.)
///
/// 사용 예시:
/// ```dart
/// ref.listen(tokenEventsProvider, (_, next) {
///   next.whenData((event) {
///     if (event.type == TokenEventType.expired) {
///       // Handle token expiry
///     }
///   });
/// });
/// ```
final tokenEventsProvider = StreamProvider<TokenEvent>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.tokenEvents;
});

/// Notifier for authentication actions.
///
/// 사용 예시:
/// ```dart
/// await ref.read(authNotifierProvider.notifier).signIn(GoogleAuthProvider());
/// await ref.read(authNotifierProvider.notifier).signOut();
/// ```
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  /// Sign in with the specified provider.
  Future<AuthUser> signIn(AuthProvider provider) async {
    state = const AuthState.loading();
    try {
      final user = await _repo.signIn(provider);
      state = AuthState.authenticated(user);
      return user;
    } catch (e) {
      state = AuthState.error(e);
      rethrow;
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _repo.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e);
      rethrow;
    }
  }

  /// Refresh the current session.
  Future<void> refresh() async {
    try {
      await _repo.refresh();
      final user = _repo.currentUser;
      if (user != null) {
        state = AuthState.authenticated(user);
      }
    } catch (e) {
      state = AuthState.error(e);
      rethrow;
    }
  }

  /// Check for existing session and restore it.
  Future<bool> checkExistingSession(AuthProvider provider) async {
    state = const AuthState.loading();
    final restored = await _repo.checkExistingSession(provider);
    if (!restored) {
      state = const AuthState.unauthenticated();
    }
    return restored;
  }

  /// Get server verification data.
  ServerVerificationData getServerVerificationData() {
    return _repo.getServerVerificationData();
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
