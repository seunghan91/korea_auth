/// BLoC / Cubit 패턴 사용 예시
///
/// flutter_bloc 패키지가 필요합니다: flutter pub add flutter_bloc
///
/// ```yaml
/// dependencies:
///   flutter_bloc: ^8.1.0
/// ```
///
/// ## Cubit vs BLoC 선택 가이드
///
/// | 방식 | 추천 상황 | 특징 |
/// |------|----------|------|
/// | **Cubit** | 간단한 상태 관리, 대부분의 인증 로직 | 함수 호출로 상태 변경, 간결함 |
/// | **BLoC** | 복잡한 이벤트 처리, 이벤트 로깅 필요 시 | 이벤트 기반, 더 명시적 |
///
/// 인증 로직은 대부분 **Cubit**으로 충분합니다.
///
/// ---
///
/// ## 방법 1: Cubit (권장)
///
/// ```dart
/// // 1. AuthCubit 정의
/// class AuthCubit extends Cubit<AuthState> {
///   final AuthRepository _authRepo;
///   StreamSubscription? _authSub;
///
///   AuthCubit(this._authRepo) : super(const AuthState.initial()) {
///     _authSub = _authRepo.authStateChanges.listen(emit);
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
///     emit(const AuthState.loading());
///     try {
///       await _authRepo.signOut();
///       emit(const AuthState.unauthenticated());
///     } catch (e) {
///       emit(AuthState.error(e));
///     }
///   }
///
///   Future<void> signInWithKakao() => signIn(KakaoAuthProvider());
///   Future<void> signInWithNaver() => signIn(NaverAuthProvider());
///   Future<void> signInWithGoogle() => signIn(GoogleAuthProvider());
///   Future<void> signInWithApple() => signIn(AppleAuthProvider());
///
///   @override
///   Future<void> close() {
///     _authSub?.cancel();
///     return super.close();
///   }
/// }
///
/// // 2. main.dart
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
///         return AuthButton.kakao(
///           onPressed: () => context.read<AuthCubit>().signInWithKakao(),
///           isLoading: state.isLoading,
///         );
///       },
///     );
///   }
/// }
///
/// // 4. BlocListener로 사이드 이펙트 처리
/// class LoginPage extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocListener<AuthCubit, AuthState>(
///       listener: (context, state) {
///         if (state.hasError) {
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text(state.error.toString())),
///           );
///         }
///       },
///       child: LoginScreen(),
///     );
///   }
/// }
///
/// // 5. BlocConsumer로 빌더 + 리스너 결합
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocConsumer<AuthCubit, AuthState>(
///       listener: (context, state) {
///         if (state.hasError) {
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text('오류: ${state.error}')),
///           );
///         }
///       },
///       builder: (context, state) {
///         if (state.isLoading) return SplashScreen();
///         if (state.isAuthenticated) return HomeScreen(user: state.user!);
///         return LoginScreen();
///       },
///     );
///   }
/// }
/// ```
///
/// ---
///
/// ## 방법 2: BLoC (이벤트 기반)
///
/// 이벤트 로깅, 복잡한 이벤트 변환이 필요한 경우 사용합니다.
///
/// ```dart
/// // 1. 이벤트 정의
/// abstract class AuthEvent {}
///
/// class SignInRequested extends AuthEvent {
///   final AuthProvider provider;
///   SignInRequested(this.provider);
/// }
///
/// class SignInWithKakaoRequested extends AuthEvent {}
/// class SignInWithNaverRequested extends AuthEvent {}
/// class SignInWithGoogleRequested extends AuthEvent {}
/// class SignInWithAppleRequested extends AuthEvent {}
/// class SignOutRequested extends AuthEvent {}
///
/// // 2. AuthBloc 정의
/// class AuthBloc extends Bloc<AuthEvent, AuthState> {
///   final AuthRepository _authRepo;
///   StreamSubscription? _authSub;
///
///   AuthBloc(this._authRepo) : super(const AuthState.initial()) {
///     _authSub = _authRepo.authStateChanges.listen((state) {
///       // Repository 상태 변화를 Bloc 상태에 반영
///     });
///
///     on<SignInRequested>(_onSignIn);
///     on<SignInWithKakaoRequested>((e, emit) =>
///       _onSignIn(SignInRequested(KakaoAuthProvider()), emit));
///     on<SignInWithNaverRequested>((e, emit) =>
///       _onSignIn(SignInRequested(NaverAuthProvider()), emit));
///     on<SignInWithGoogleRequested>((e, emit) =>
///       _onSignIn(SignInRequested(GoogleAuthProvider()), emit));
///     on<SignInWithAppleRequested>((e, emit) =>
///       _onSignIn(SignInRequested(AppleAuthProvider()), emit));
///     on<SignOutRequested>(_onSignOut);
///   }
///
///   Future<void> _onSignIn(SignInRequested event, Emitter<AuthState> emit) async {
///     emit(const AuthState.loading());
///     try {
///       final user = await _authRepo.signIn(event.provider);
///       emit(AuthState.authenticated(user));
///     } on AuthException catch (e) {
///       emit(AuthState.error(e));
///     }
///   }
///
///   Future<void> _onSignOut(SignOutRequested event, Emitter<AuthState> emit) async {
///     emit(const AuthState.loading());
///     try {
///       await _authRepo.signOut();
///       emit(const AuthState.unauthenticated());
///     } catch (e) {
///       emit(AuthState.error(e));
///     }
///   }
///
///   @override
///   Future<void> close() {
///     _authSub?.cancel();
///     return super.close();
///   }
/// }
///
/// // 3. 위젯에서 사용
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return BlocBuilder<AuthBloc, AuthState>(
///       builder: (context, state) {
///         return Column(
///           children: [
///             AuthButton.kakao(
///               onPressed: () => context.read<AuthBloc>().add(SignInWithKakaoRequested()),
///               isLoading: state.isLoading,
///             ),
///             AuthButton.naver(
///               onPressed: () => context.read<AuthBloc>().add(SignInWithNaverRequested()),
///               isLoading: state.isLoading,
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
/// ```
///
/// ---
///
/// ## 이벤트 로깅 (BlocObserver)
///
/// ```dart
/// class AuthBlocObserver extends BlocObserver {
///   @override
///   void onEvent(Bloc bloc, Object? event) {
///     super.onEvent(bloc, event);
///     print('${bloc.runtimeType} Event: $event');
///   }
///
///   @override
///   void onChange(BlocBase bloc, Change change) {
///     super.onChange(bloc, change);
///     print('${bloc.runtimeType} Change: $change');
///   }
///
///   @override
///   void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
///     super.onError(bloc, error, stackTrace);
///     print('${bloc.runtimeType} Error: $error');
///   }
/// }
///
/// void main() {
///   Bloc.observer = AuthBlocObserver();
///   runApp(MyApp());
/// }
/// ```
library bloc_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 BLoC/Cubit 구현은 프로젝트에서 직접 작성하세요.
