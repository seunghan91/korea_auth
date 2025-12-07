/// Redux 패턴 사용 예시
///
/// Redux를 사용하는 경우 이 파일을 참고하여 구현하세요.
/// flutter_redux 패키지가 필요합니다.
///
/// ```yaml
/// dependencies:
///   redux: ^5.0.0
///   flutter_redux: ^0.10.0
/// ```
///
/// ## Redux 특징
///
/// - **단일 진실의 원천**: 중앙 집중식 Store
/// - **단방향 데이터 흐름**: 예측 가능한 상태 변화
/// - **순수 함수 Reducer**: 테스트 용이
/// - **대규모 엔터프라이즈 앱**에 적합
///
/// ---
///
/// ## 사용 예시
///
/// ```dart
/// // 1. State 정의
/// class AppState {
///   final AuthState authState;
///
///   AppState({required this.authState});
///
///   factory AppState.initial() => AppState(
///     authState: const AuthState.initial(),
///   );
/// }
///
/// // 2. Actions 정의
/// class SignInAction {
///   final AuthProvider provider;
///   SignInAction(this.provider);
/// }
///
/// class SignInWithKakaoAction {}
/// class SignInWithNaverAction {}
/// class SignInWithGoogleAction {}
/// class SignInWithAppleAction {}
/// class SignOutAction {}
///
/// class SetAuthStateAction {
///   final AuthState authState;
///   SetAuthStateAction(this.authState);
/// }
///
/// // 3. Reducer 정의
/// AppState appReducer(AppState state, dynamic action) {
///   return AppState(
///     authState: authReducer(state.authState, action),
///   );
/// }
///
/// AuthState authReducer(AuthState state, dynamic action) {
///   if (action is SetAuthStateAction) {
///     return action.authState;
///   }
///   return state;
/// }
///
/// // 4. Middleware 정의 (비동기 로직)
/// List<Middleware<AppState>> createAuthMiddleware(AuthRepository authRepo) {
///   return [
///     TypedMiddleware<AppState, SignInAction>(_signIn(authRepo)),
///     TypedMiddleware<AppState, SignInWithKakaoAction>(_signInWithKakao(authRepo)),
///     TypedMiddleware<AppState, SignInWithNaverAction>(_signInWithNaver(authRepo)),
///     TypedMiddleware<AppState, SignInWithGoogleAction>(_signInWithGoogle(authRepo)),
///     TypedMiddleware<AppState, SignInWithAppleAction>(_signInWithApple(authRepo)),
///     TypedMiddleware<AppState, SignOutAction>(_signOut(authRepo)),
///   ];
/// }
///
/// Middleware<AppState> _signIn(AuthRepository authRepo) {
///   return (Store<AppState> store, dynamic action, NextDispatcher next) async {
///     next(action);
///     if (action is SignInAction) {
///       store.dispatch(SetAuthStateAction(const AuthState.loading()));
///       try {
///         final user = await authRepo.signIn(action.provider);
///         store.dispatch(SetAuthStateAction(AuthState.authenticated(user)));
///       } on AuthException catch (e) {
///         store.dispatch(SetAuthStateAction(AuthState.error(e)));
///       }
///     }
///   };
/// }
///
/// Middleware<AppState> _signInWithKakao(AuthRepository authRepo) {
///   return (store, action, next) {
///     next(action);
///     store.dispatch(SignInAction(KakaoAuthProvider()));
///   };
/// }
///
/// Middleware<AppState> _signInWithNaver(AuthRepository authRepo) {
///   return (store, action, next) {
///     next(action);
///     store.dispatch(SignInAction(NaverAuthProvider()));
///   };
/// }
///
/// Middleware<AppState> _signInWithGoogle(AuthRepository authRepo) {
///   return (store, action, next) {
///     next(action);
///     store.dispatch(SignInAction(GoogleAuthProvider()));
///   };
/// }
///
/// Middleware<AppState> _signInWithApple(AuthRepository authRepo) {
///   return (store, action, next) {
///     next(action);
///     store.dispatch(SignInAction(AppleAuthProvider()));
///   };
/// }
///
/// Middleware<AppState> _signOut(AuthRepository authRepo) {
///   return (store, action, next) async {
///     next(action);
///     store.dispatch(SetAuthStateAction(const AuthState.loading()));
///     try {
///       await authRepo.signOut();
///       store.dispatch(SetAuthStateAction(const AuthState.unauthenticated()));
///     } catch (e) {
///       store.dispatch(SetAuthStateAction(AuthState.error(e)));
///     }
///   };
/// }
///
/// // 5. Store 생성 및 main.dart
/// void main() {
///   final authRepo = AuthRepository();
///   final store = Store<AppState>(
///     appReducer,
///     initialState: AppState.initial(),
///     middleware: createAuthMiddleware(authRepo),
///   );
///
///   runApp(
///     StoreProvider<AppState>(
///       store: store,
///       child: MyApp(),
///     ),
///   );
/// }
///
/// // 6. 위젯에서 사용 (StoreConnector)
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return StoreConnector<AppState, _LoginViewModel>(
///       converter: (store) => _LoginViewModel(
///         isLoading: store.state.authState.isLoading,
///         signInWithKakao: () => store.dispatch(SignInWithKakaoAction()),
///         signInWithNaver: () => store.dispatch(SignInWithNaverAction()),
///         signInWithGoogle: () => store.dispatch(SignInWithGoogleAction()),
///         signInWithApple: () => store.dispatch(SignInWithAppleAction()),
///       ),
///       builder: (context, vm) {
///         return Column(
///           children: [
///             AuthButton.kakao(
///               onPressed: vm.isLoading ? null : vm.signInWithKakao,
///               isLoading: vm.isLoading,
///             ),
///             AuthButton.naver(
///               onPressed: vm.isLoading ? null : vm.signInWithNaver,
///               isLoading: vm.isLoading,
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
///
/// class _LoginViewModel {
///   final bool isLoading;
///   final VoidCallback signInWithKakao;
///   final VoidCallback signInWithNaver;
///   final VoidCallback signInWithGoogle;
///   final VoidCallback signInWithApple;
///
///   _LoginViewModel({
///     required this.isLoading,
///     required this.signInWithKakao,
///     required this.signInWithNaver,
///     required this.signInWithGoogle,
///     required this.signInWithApple,
///   });
/// }
///
/// // 7. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return StoreConnector<AppState, AuthState>(
///       converter: (store) => store.state.authState,
///       builder: (context, authState) {
///         if (authState.isLoading) return SplashScreen();
///         if (authState.isAuthenticated) return HomeScreen(user: authState.user!);
///         return LoginScreen();
///       },
///     );
///   }
/// }
/// ```
library redux_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 Redux 구현은 프로젝트에서 직접 작성하세요.
