/// Riverpod 상태 관리 통합
///
/// 이 파일은 Riverpod을 사용하는 프로젝트를 위한 통합 코드입니다.
/// 다른 상태 관리를 사용하는 경우 이 파일을 import하지 않아도 됩니다.
///
/// ## 다른 상태 관리 사용 시
///
/// - **Provider**: `provider_example.dart` 참고
/// - **Cubit/BLoC**: `bloc_example.dart` 참고 (Cubit 권장)
/// - **GetX**: `getx_example.dart` 참고
/// - **MobX**: `mobx_example.dart` 참고
/// - **Redux**: `redux_example.dart` 참고
/// - **Signals**: `signals_example.dart` 참고
/// - **Vanilla**: `vanilla_example.dart` 참고
///
/// 모든 예시 파일은 `lib/src/integrations/` 폴더에 있습니다.
///
/// ## 핵심 개념
///
/// open_k_auth의 핵심은 [AuthRepository]입니다.
/// 모든 상태 관리 솔루션은 [AuthRepository]를 래핑하여 사용합니다:
///
/// ```dart
/// // AuthRepository는 상태 관리에 독립적입니다
/// final authRepo = AuthRepository();
///
/// // 인증 상태 스트림 구독
/// authRepo.authStateChanges.listen((state) {
///   // 상태 변화 처리
/// });
///
/// // 로그인
/// await authRepo.signIn(KakaoAuthProvider());
///
/// // 로그아웃
/// await authRepo.signOut();
/// ```
///
/// Riverpod을 사용하지 않는 경우, [AuthRepository]를 직접 사용하거나
/// 프로젝트의 상태 관리 솔루션으로 래핑하세요.
library riverpod_auth;

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
