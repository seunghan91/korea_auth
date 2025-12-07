/// Testing utilities for open_k_auth
///
/// 테스트에서 Mock Provider를 사용하려면 이 파일을 import하세요.
///
/// ```dart
/// import 'package:open_k_auth/testing.dart';
///
/// void main() {
///   test('로그인 테스트', () async {
///     final mockProvider = MockAuthProvider.withTestUser();
///     final repo = AuthRepository();
///
///     await repo.signIn(mockProvider);
///
///     expect(repo.currentState.isAuthenticated, true);
///   });
/// }
/// ```
library testing;

export 'src/testing/mock_auth_provider.dart';
