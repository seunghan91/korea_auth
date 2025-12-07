/// MobX 패턴 사용 예시
///
/// MobX를 사용하는 경우 이 파일을 참고하여 구현하세요.
/// mobx, flutter_mobx 패키지가 필요합니다.
///
/// ```yaml
/// dependencies:
///   mobx: ^2.3.0
///   flutter_mobx: ^2.2.0
///
/// dev_dependencies:
///   build_runner: ^2.4.0
///   mobx_codegen: ^2.6.0
/// ```
///
/// ## MobX 특징
///
/// - **반응형 프로그래밍**: Observable 변경 시 자동 UI 업데이트
/// - **최소 보일러플레이트**: 간결한 코드
/// - **세밀한 반응성**: 필요한 위젯만 리빌드
/// - **중간~복잡한 프로젝트**에 적합
///
/// ---
///
/// ## 사용 예시
///
/// ```dart
/// // 1. AuthStore 정의 (auth_store.dart)
/// import 'package:mobx/mobx.dart';
/// import 'package:open_k_auth/open_k_auth.dart';
///
/// part 'auth_store.g.dart';
///
/// class AuthStore = _AuthStore with _$AuthStore;
///
/// abstract class _AuthStore with Store {
///   final AuthRepository _authRepo;
///
///   _AuthStore(this._authRepo) {
///     _authRepo.authStateChanges.listen((state) {
///       authState = state;
///     });
///   }
///
///   @observable
///   AuthState authState = const AuthState.initial();
///
///   @computed
///   bool get isAuthenticated => authState.isAuthenticated;
///
///   @computed
///   bool get isLoading => authState.isLoading;
///
///   @computed
///   AuthUser? get user => authState.user;
///
///   @action
///   Future<void> signIn(AuthProvider provider) async {
///     authState = const AuthState.loading();
///     try {
///       final user = await _authRepo.signIn(provider);
///       authState = AuthState.authenticated(user);
///     } on AuthException catch (e) {
///       authState = AuthState.error(e);
///     }
///   }
///
///   @action
///   Future<void> signInWithKakao() => signIn(KakaoAuthProvider());
///
///   @action
///   Future<void> signInWithNaver() => signIn(NaverAuthProvider());
///
///   @action
///   Future<void> signInWithGoogle() => signIn(GoogleAuthProvider());
///
///   @action
///   Future<void> signInWithApple() => signIn(AppleAuthProvider());
///
///   @action
///   Future<void> signOut() async {
///     authState = const AuthState.loading();
///     try {
///       await _authRepo.signOut();
///       authState = const AuthState.unauthenticated();
///     } catch (e) {
///       authState = AuthState.error(e);
///     }
///   }
/// }
///
/// // 2. 코드 생성 실행
/// // flutter pub run build_runner build
///
/// // 3. main.dart에서 Store 제공
/// final authStore = AuthStore(AuthRepository());
///
/// void main() {
///   runApp(
///     Provider<AuthStore>.value(
///       value: authStore,
///       child: MyApp(),
///     ),
///   );
/// }
///
/// // 4. 위젯에서 사용 (Observer로 감싸기)
/// class LoginScreen extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final store = Provider.of<AuthStore>(context);
///
///     return Observer(
///       builder: (_) {
///         return Column(
///           children: [
///             AuthButton.kakao(
///               onPressed: store.isLoading ? null : store.signInWithKakao,
///               isLoading: store.isLoading,
///             ),
///             AuthButton.naver(
///               onPressed: store.isLoading ? null : store.signInWithNaver,
///               isLoading: store.isLoading,
///             ),
///           ],
///         );
///       },
///     );
///   }
/// }
///
/// // 5. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final store = Provider.of<AuthStore>(context);
///
///     return Observer(
///       builder: (_) {
///         if (store.isLoading) return SplashScreen();
///         if (store.isAuthenticated) return HomeScreen(user: store.user!);
///         return LoginScreen();
///       },
///     );
///   }
/// }
///
/// // 6. Reaction으로 사이드 이펙트 처리
/// class LoginPage extends StatefulWidget {
///   @override
///   State<LoginPage> createState() => _LoginPageState();
/// }
///
/// class _LoginPageState extends State<LoginPage> {
///   late final ReactionDisposer _disposer;
///
///   @override
///   void initState() {
///     super.initState();
///     final store = Provider.of<AuthStore>(context, listen: false);
///
///     _disposer = reaction(
///       (_) => store.authState,
///       (AuthState state) {
///         if (state.hasError) {
///           ScaffoldMessenger.of(context).showSnackBar(
///             SnackBar(content: Text('오류: ${state.error}')),
///           );
///         }
///       },
///     );
///   }
///
///   @override
///   void dispose() {
///     _disposer();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) => LoginScreen();
/// }
/// ```
library mobx_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 MobX 구현은 프로젝트에서 직접 작성하세요.
// 코드 생성이 필요합니다: flutter pub run build_runner build
