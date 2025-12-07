/// BLoC 패턴 사용 예시
///
/// BLoC을 사용하는 경우 이 파일을 참고하여 구현하세요.
/// flutter_bloc 패키지가 필요합니다: flutter pub add flutter_bloc
///
/// ```yaml
/// dependencies:
///   flutter_bloc: ^8.1.0
/// ```
///
/// ## 사용 예시
///
/// ```dart
/// // 1. AuthCubit 정의
/// class AuthCubit extends Cubit<AuthState> {
///   final AuthRepository _authRepo;
///
///   AuthCubit(this._authRepo) : super(const AuthState.initial()) {
///     _authRepo.authStateChanges.listen((state) {
///       emit(state);
///     });
///   }
///
///   Future<void> signIn(AuthProvider provider) async {
///     emit(const AuthState.loading());
///     try {
///       final user = await _authRepo.signIn(provider);
///       emit(AuthState.authenticated(user));
///     } on AuthException catch (e) {
///       emit(AuthState.error(e));
///     }
///   }
///
///   Future<void> signOut() async {
///     await _authRepo.signOut();
///     emit(const AuthState.unauthenticated());
///   }
/// }
///
/// // 2. main.dart에서 Provider 설정
/// void main() {
///   runApp(
///     BlocProvider(
///       create: (_) => AuthCubit(AuthRepository()),
///       child: MyApp(),
///     ),
///   );
/// }
///
/// // 3. 위젯에서 사용
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocBuilder<AuthCubit, AuthState>(
///       builder: (context, state) {
///         if (state.isLoading) {
///           return CircularProgressIndicator();
///         }
///         return AuthButton.kakao(
///           onPressed: () => context.read<AuthCubit>().signIn(KakaoAuthProvider()),
///         );
///       },
///     );
///   }
/// }
///
/// // 4. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocBuilder<AuthCubit, AuthState>(
///       builder: (context, state) {
///         if (state.isAuthenticated) {
///           return HomeScreen(user: state.user!);
///         }
///         return LoginScreen();
///       },
///     );
///   }
/// }
/// ```
library bloc_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 BLoC 구현은 프로젝트에서 직접 작성하세요.
