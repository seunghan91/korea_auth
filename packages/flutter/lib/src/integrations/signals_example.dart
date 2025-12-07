/// Signals 패턴 사용 예시
///
/// Flutter Signals를 사용하는 경우 이 파일을 참고하여 구현하세요.
/// signals 패키지가 필요합니다.
///
/// ```yaml
/// dependencies:
///   signals: ^5.0.0
/// ```
///
/// ## Signals 특징
///
/// - **세밀한 반응성**: 변경된 부분만 리빌드
/// - **간결한 문법**: 최소 보일러플레이트
/// - **자동 의존성 추적**: 명시적 구독 불필요
/// - **2024년 떠오르는 트렌드**
///
/// ---
///
/// ## 사용 예시
///
/// ```dart
/// // 1. Auth Signals 정의
/// import 'package:signals/signals_flutter.dart';
/// import 'package:open_k_auth/open_k_auth.dart';
///
/// class AuthSignals {
///   final AuthRepository _authRepo;
///
///   // Signals
///   late final authState = signal<AuthState>(const AuthState.initial());
///
///   // Computed (파생 상태)
///   late final isAuthenticated = computed(() => authState.value.isAuthenticated);
///   late final isLoading = computed(() => authState.value.isLoading);
///   late final user = computed(() => authState.value.user);
///   late final hasError = computed(() => authState.value.hasError);
///
///   AuthSignals(this._authRepo) {
///     // Repository 상태 변화 구독
///     _authRepo.authStateChanges.listen((state) {
///       authState.value = state;
///     });
///   }
///
///   Future<void> signIn(AuthProvider provider) async {
///     authState.value = const AuthState.loading();
///     try {
///       final user = await _authRepo.signIn(provider);
///       authState.value = AuthState.authenticated(user);
///     } on AuthException catch (e) {
///       authState.value = AuthState.error(e);
///     }
///   }
///
///   Future<void> signInWithKakao() => signIn(KakaoAuthProvider());
///   Future<void> signInWithNaver() => signIn(NaverAuthProvider());
///   Future<void> signInWithGoogle() => signIn(GoogleAuthProvider());
///   Future<void> signInWithApple() => signIn(AppleAuthProvider());
///
///   Future<void> signOut() async {
///     authState.value = const AuthState.loading();
///     try {
///       await _authRepo.signOut();
///       authState.value = const AuthState.unauthenticated();
///     } catch (e) {
///       authState.value = AuthState.error(e);
///     }
///   }
/// }
///
/// // 2. 전역 인스턴스 생성
/// final authSignals = AuthSignals(AuthRepository());
///
/// // 3. main.dart
/// void main() {
///   runApp(MyApp());
/// }
///
/// // 4. 위젯에서 사용 (Watch로 구독)
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final isLoading = authSignals.isLoading.watch(context);
///
///     return Column(
///       children: [
///         AuthButton.kakao(
///           onPressed: isLoading ? null : authSignals.signInWithKakao,
///           isLoading: isLoading,
///         ),
///         AuthButton.naver(
///           onPressed: isLoading ? null : authSignals.signInWithNaver,
///           isLoading: isLoading,
///         ),
///         AuthButton.google(
///           onPressed: isLoading ? null : authSignals.signInWithGoogle,
///           isLoading: isLoading,
///         ),
///         AuthButton.apple(
///           onPressed: isLoading ? null : authSignals.signInWithApple,
///           isLoading: isLoading,
///         ),
///       ],
///     );
///   }
/// }
///
/// // 5. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final isLoading = authSignals.isLoading.watch(context);
///     final isAuthenticated = authSignals.isAuthenticated.watch(context);
///     final user = authSignals.user.watch(context);
///
///     if (isLoading) return SplashScreen();
///     if (isAuthenticated && user != null) return HomeScreen(user: user);
///     return LoginScreen();
///   }
/// }
///
/// // 6. Effect로 사이드 이펙트 처리
/// class LoginPage extends StatefulWidget {
///   @override
///   State<LoginPage> createState() => _LoginPageState();
/// }
///
/// class _LoginPageState extends State<LoginPage> {
///   late final EffectCleanup _cleanup;
///
///   @override
///   void initState() {
///     super.initState();
///     _cleanup = effect(() {
///       if (authSignals.hasError.value) {
///         final error = authSignals.authState.value.error;
///         ScaffoldMessenger.of(context).showSnackBar(
///           SnackBar(content: Text('오류: $error')),
///         );
///       }
///     });
///   }
///
///   @override
///   void dispose() {
///     _cleanup();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => LoginScreen();
/// }
///
/// // 7. Batch로 여러 상태 동시 업데이트
/// void resetAuth() {
///   batch(() {
///     authSignals.authState.value = const AuthState.initial();
///     // 다른 signals도 함께 업데이트 가능
///   });
/// }
/// ```
library signals_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 Signals 구현은 프로젝트에서 직접 작성하세요.
