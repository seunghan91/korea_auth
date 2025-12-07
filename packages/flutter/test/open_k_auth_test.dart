import 'package:flutter_test/flutter_test.dart';
import 'package:open_k_auth/open_k_auth.dart';

void main() {
  group('AuthUser', () {
    test('creates AuthUser with all fields', () {
      final user = AuthUser(
        uid: '123',
        displayName: 'John Doe',
        email: 'john@example.com',
        photoURL: 'https://example.com/photo.jpg',
        providerId: 'google',
        rawData: {'key': 'value'},
      );

      expect(user.uid, '123');
      expect(user.displayName, 'John Doe');
      expect(user.email, 'john@example.com');
      expect(user.photoURL, 'https://example.com/photo.jpg');
      expect(user.providerId, 'google');
      expect(user.rawData, {'key': 'value'});
    });

    test('creates AuthUser with minimal fields', () {
      final user = AuthUser(
        uid: '123',
        providerId: 'kakao',
      );

      expect(user.uid, '123');
      expect(user.displayName, isNull);
      expect(user.email, isNull);
      expect(user.photoURL, isNull);
      expect(user.providerId, 'kakao');
      expect(user.rawData, isNull);
    });

    test('toString returns formatted string', () {
      final user = AuthUser(
        uid: '123',
        displayName: 'John Doe',
        email: 'john@example.com',
        providerId: 'google',
      );

      final string = user.toString();
      expect(string.contains('AuthUser'), true);
      expect(string.contains('uid: 123'), true);
      expect(string.contains('google'), true);
    });
  });

  group('AuthException', () {
    test('creates AuthException with code and message', () {
      final exception = AuthException('signin_failed', 'Sign in failed');

      expect(exception.code, 'signin_failed');
      expect(exception.message, 'Sign in failed');
      expect(exception.originalException, isNull);
    });

    test('creates AuthException with original exception', () {
      final originalError = Exception('Original error');
      final exception = AuthException(
        'signin_failed',
        'Sign in failed',
        originalError,
      );

      expect(exception.code, 'signin_failed');
      expect(exception.message, 'Sign in failed');
      expect(exception.originalException, originalError);
    });

    test('toString returns formatted string', () {
      final exception = AuthException('signin_failed', 'Sign in failed');
      final string = exception.toString();

      expect(string.contains('AuthException'), true);
      expect(string.contains('signin_failed'), true);
    });
  });

  group('AuthState', () {
    test('unauthenticated state is initial', () {
      final state = AuthState.unauthenticated();

      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });

    test('authenticated state with user', () {
      final user = AuthUser(uid: '123', providerId: 'google');
      final state = AuthState.authenticated(user);

      expect(state.isAuthenticated, true);
      expect(state.user, user);
    });

    test('loading state', () {
      final state = AuthState.loading();

      expect(state.isLoading, true);
      expect(state.user, isNull);
    });

    test('error state', () {
      final exception = AuthException('error', 'Error message');
      final state = AuthState.error(exception);

      expect(state.error, exception);
      expect(state.user, isNull);
    });
  });

  group('AuthResult', () {
    test('success result with user', () {
      final user = AuthUser(uid: '123', providerId: 'google');
      final result = AuthResult.success(user);

      expect(result.isSuccess, true);
      expect(result.user, user);
      expect(result.error, isNull);
    });

    test('failure result with exception', () {
      final exception = AuthException('error', 'Error message');
      final result = AuthResult.failure(exception);

      expect(result.isSuccess, false);
      expect(result.user, isNull);
      expect(result.error, exception);
    });

    test('fold on success', () {
      final user = AuthUser(uid: '123', providerId: 'google');
      final result = AuthResult.success(user);

      final value = result.fold(
        onSuccess: (u) => 'Success: ${u.displayName}',
        onFailure: (e) => 'Failure: ${e.message}',
      );

      expect(value, 'Success: null');
    });

    test('fold on failure', () {
      final exception = AuthException('error', 'Error message');
      final result = AuthResult.failure(exception);

      final value = result.fold(
        onSuccess: (u) => 'Success',
        onFailure: (e) => 'Failure: ${e.message}',
      );

      expect(value, 'Failure: Error message');
    });
  });

  group('MockAuthProvider', () {
    test('signs in successfully', () async {
      final provider = MockAuthProvider(
        uid: '123',
        displayName: 'Test User',
        email: 'test@example.com',
      );

      final user = await provider.signIn();

      expect(user.uid, '123');
      expect(user.displayName, 'Test User');
      expect(user.email, 'test@example.com');
      expect(user.providerId, 'mock');
    });

    test('signs out successfully', () async {
      final provider = MockAuthProvider();

      // Should not throw
      await provider.signOut();
    });

    test('returns current user', () async {
      final provider = MockAuthProvider(
        uid: '123',
        displayName: 'Test User',
      );

      final user = await provider.currentUser;

      expect(user, isNotNull);
      expect(user!.uid, '123');
    });

    test('refreshes token', () async {
      final provider = MockAuthProvider();

      // Should not throw
      await provider.refresh();
    });

    test('returns correct provider id', () {
      final provider = MockAuthProvider();

      expect(provider.providerId, 'mock');
    });
  });

  group('AuthRepository', () {
    test('initializes with default values', () {
      final repo = AuthRepository();

      expect(repo != null, true);
    });
  });

  group('ServerVerification', () {
    test('creates verification request with provider and token', () {
      final verification = ServerVerification(
        provider: 'google',
        token: 'access_token_123',
        idToken: 'id_token_456',
      );

      expect(verification.provider, 'google');
      expect(verification.token, 'access_token_123');
      expect(verification.idToken, 'id_token_456');
    });

    test('converts to JSON', () {
      final verification = ServerVerification(
        provider: 'kakao',
        token: 'token_123',
      );

      final json = verification.toJson();

      expect(json['provider'], 'kakao');
      expect(json['token'], 'token_123');
    });
  });

  group('AuthToken', () {
    test('creates token with access token', () {
      final token = AuthToken(
        accessToken: 'access_123',
        refreshToken: 'refresh_123',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      expect(token.accessToken, 'access_123');
      expect(token.refreshToken, 'refresh_123');
      expect(token.isExpired, false);
    });

    test('detects expired token', () {
      final token = AuthToken(
        accessToken: 'access_123',
        expiresAt: DateTime.now().subtract(Duration(hours: 1)),
      );

      expect(token.isExpired, true);
    });

    test('detects valid token', () {
      final token = AuthToken(
        accessToken: 'access_123',
        expiresAt: DateTime.now().add(Duration(hours: 1)),
      );

      expect(token.isExpired, false);
    });
  });

  group('AuthConfig', () {
    test('creates config with default values', () {
      final config = AuthConfig();

      expect(config != null, true);
    });

    test('creates config with custom scopes', () {
      final config = AuthConfig(
        googleScopes: ['email', 'profile'],
      );

      expect(config.googleScopes, ['email', 'profile']);
    });
  });
}
