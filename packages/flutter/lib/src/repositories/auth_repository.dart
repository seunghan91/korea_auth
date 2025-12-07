import 'dart:async';
import '../core/auth_provider.dart';
import '../core/auth_state.dart';
import '../core/auth_exception.dart';
import '../core/auth_user.dart';
import '../core/auth_token.dart';
import '../core/token_manager.dart';
import '../core/server_verification.dart';

/// Repository to manage authentication state and interactions with providers.
class AuthRepository {
  AuthProvider? _currentProvider;
  AuthUser? _currentUser;
  final _authStateController = StreamController<AuthState>.broadcast();
  final TokenManager _tokenManager;

  /// Stream of authentication state changes.
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  /// Stream of token events (refresh, expiry, etc.)
  Stream<TokenEvent> get tokenEvents => _tokenManager.tokenEvents;

  AuthState _currentState = const AuthState.initial();

  /// The current authentication state.
  AuthState get currentState => _currentState;

  /// The currently authenticated user.
  AuthUser? get currentUser => _currentUser;

  /// The current provider ID.
  String? get currentProviderId => _currentProvider?.providerId;

  /// Whether auto token refresh is enabled.
  bool get autoRefreshEnabled => _tokenManager.autoRefresh;

  AuthRepository({
    bool autoRefresh = true,
    Duration refreshThreshold = const Duration(minutes: 5),
  }) : _tokenManager = TokenManager(
         autoRefresh: autoRefresh,
         refreshThreshold: refreshThreshold,
       ) {
    _tokenManager.setRefreshCallback(_performRefresh);
  }

  void _updateState(AuthState state) {
    _currentState = state;
    _authStateController.add(state);
  }

  /// Signs in using the specified [provider].
  Future<AuthUser> signIn(AuthProvider provider) async {
    try {
      _updateState(const AuthState.loading());
      _currentProvider = provider;
      final user = await provider.signIn();
      _currentUser = user;

      // Extract token from rawData if available
      _extractAndSetToken(user);

      _updateState(AuthState.authenticated(user));
      return user;
    } catch (e) {
      _updateState(AuthState.error(e));
      rethrow;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    try {
      _updateState(const AuthState.loading());
      if (_currentProvider != null) {
        await _currentProvider!.signOut();
      }
      _currentProvider = null;
      _currentUser = null;
      _tokenManager.clearToken();
      _updateState(const AuthState.unauthenticated());
    } catch (e) {
      _updateState(AuthState.error(e));
      rethrow;
    }
  }

  /// Refreshes the current session.
  Future<void> refresh() async {
    if (_currentProvider == null) {
      throw const AuthException(
        'no_provider',
        'No active provider to refresh.',
      );
    }
    try {
      await _currentProvider!.refresh();
      final user = await _currentProvider!.currentUser;
      if (user != null) {
        _currentUser = user;
        _extractAndSetToken(user);
        _updateState(AuthState.authenticated(user));
      }
    } catch (e) {
      _updateState(AuthState.error(e));
      rethrow;
    }
  }

  Future<AuthToken> _performRefresh() async {
    await refresh();
    final token = _tokenManager.currentToken;
    if (token == null) {
      throw const AuthException('refresh_failed', 'Failed to get new token');
    }
    return token;
  }

  void _extractAndSetToken(AuthUser user) {
    final rawData = user.rawData;
    if (rawData == null) return;

    final accessToken = rawData['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) return;

    DateTime? expiresAt;
    final expiresAtStr = rawData['expiresAt'] as String?;
    if (expiresAtStr != null) {
      try {
        expiresAt = DateTime.parse(expiresAtStr);
      } catch (_) {}
    }

    final token = AuthToken(
      accessToken: accessToken,
      refreshToken: rawData['refreshToken'] as String?,
      idToken: rawData['idToken'] as String?,
      expiresAt: expiresAt,
    );

    _tokenManager.setToken(token);
  }

  /// Retrieves data needed for server-side verification.
  ServerVerificationData getServerVerificationData() {
    if (_currentProvider == null || _currentUser == null) {
      throw const AuthException('no_provider', 'No active session.');
    }

    final rawData = _currentUser!.rawData ?? {};

    return ServerVerificationData(
      provider: _currentProvider!.providerId,
      accessToken: rawData['accessToken'] as String?,
      idToken: rawData['idToken'] as String?,
      authorizationCode: rawData['authorizationCode'] as String?,
      userId: _currentUser!.uid,
    );
  }

  /// Check if there's an existing session and restore it.
  Future<bool> checkExistingSession(AuthProvider provider) async {
    try {
      final user = await provider.currentUser;
      if (user != null) {
        _currentProvider = provider;
        _currentUser = user;
        _extractAndSetToken(user);
        _updateState(AuthState.authenticated(user));
        return true;
      }
    } catch (_) {}
    _updateState(const AuthState.unauthenticated());
    return false;
  }

  void dispose() {
    _authStateController.close();
    _tokenManager.dispose();
  }
}
