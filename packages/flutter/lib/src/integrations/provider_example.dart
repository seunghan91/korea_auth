/// Provider 패턴 사용 예시
///
/// Provider를 사용하는 경우 이 파일을 참고하여 구현하세요.
/// provider 패키지가 필요합니다: flutter pub add provider
///
/// ```yaml
/// dependencies:
///   provider: ^6.0.0
/// ```
///
/// ## 사용 예시
///
/// ```dart
/// // 1. AuthNotifier 정의
/// class AuthNotifier extends ChangeNotifier {
///   final AuthRepository _authRepo;
///   AuthState _state = const AuthState.initial();
///
///   AuthNotifier(this._authRepo) {
///     _authRepo.authStateChanges.listen((state) {
///       _state = state;
///       notifyListeners();
///     });
///   }
///
///   AuthState get state => _state;
///   bool get isAuthenticated => _state.isAuthenticated;
///   bool get isLoading => _state.isLoading;
///   AuthUser? get user => _state.user;
///
///   Future<void> signIn(AuthProvider provider) async {
///     _state = const AuthState.loading();
///     notifyListeners();
///     try {
///       final user = await _authRepo.signIn(provider);
///       _state = AuthState.authenticated(user);
///     } on AuthException catch (e) {
///       _state = AuthState.error(e);
///     }
///     notifyListeners();
///   }
///
///   Future<void> signOut() async {
///     await _authRepo.signOut();
///     _state = const AuthState.unauthenticated();
///     notifyListeners();
///   }
/// }
///
/// // 2. main.dart에서 Provider 설정
/// void main() {
///   runApp(
///     ChangeNotifierProvider(
///       create: (_) => AuthNotifier(AuthRepository()),
///       child: MyApp(),
///     ),
///   );
/// }
///
/// // 3. 위젯에서 사용
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final auth = context.watch<AuthNotifier>();
///
///     if (auth.isLoading) {
///       return CircularProgressIndicator();
///     }
///
///     return AuthButton.kakao(
///       onPressed: () => auth.signIn(KakaoAuthProvider()),
///     );
///   }
/// }
///
/// // 4. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final auth = context.watch<AuthNotifier>();
///
///     if (auth.isAuthenticated) {
///       return HomeScreen(user: auth.user!);
///     }
///     return LoginScreen();
///   }
/// }
///
/// // 5. Consumer 사용 (부분 리빌드)
/// class ProfileWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return Consumer<AuthNotifier>(
///       builder: (context, auth, child) {
///         if (auth.user == null) return SizedBox.shrink();
///         return Text(auth.user!.displayName ?? '');
///       },
///     );
///   }
/// }
/// ```
library provider_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 Provider 구현은 프로젝트에서 직접 작성하세요.
