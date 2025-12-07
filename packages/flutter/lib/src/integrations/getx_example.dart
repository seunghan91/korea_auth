/// GetX 패턴 사용 예시
///
/// GetX를 사용하는 경우 이 파일을 참고하여 구현하세요.
/// get 패키지가 필요합니다: flutter pub add get
///
/// ```yaml
/// dependencies:
///   get: ^4.6.0
/// ```
///
/// ## 사용 예시
///
/// ```dart
/// // 1. AuthController 정의
/// class AuthController extends GetxController {
///   final AuthRepository _authRepo;
///   final Rx<AuthState> _state = const AuthState.initial().obs;
///
///   AuthController(this._authRepo);
///
///   AuthState get state => _state.value;
///   bool get isAuthenticated => _state.value.isAuthenticated;
///   bool get isLoading => _state.value.isLoading;
///   AuthUser? get user => _state.value.user;
///
///   @override
///   void onInit() {
///     super.onInit();
///     _authRepo.authStateChanges.listen((state) {
///       _state.value = state;
///     });
///   }
///
///   Future<void> signIn(AuthProvider provider) async {
///     _state.value = const AuthState.loading();
///     try {
///       final user = await _authRepo.signIn(provider);
///       _state.value = AuthState.authenticated(user);
///     } on AuthException catch (e) {
///       _state.value = AuthState.error(e);
///       Get.snackbar('로그인 실패', e.message);
///     }
///   }
///
///   Future<void> signOut() async {
///     await _authRepo.signOut();
///     _state.value = const AuthState.unauthenticated();
///   }
/// }
///
/// // 2. main.dart에서 바인딩 설정
/// class AuthBinding extends Bindings {
///   @override
///   void dependencies() {
///     Get.lazyPut(() => AuthController(AuthRepository()));
///   }
/// }
///
/// void main() {
///   runApp(GetMaterialApp(
///     initialBinding: AuthBinding(),
///     home: AuthGate(),
///   ));
/// }
///
/// // 3. 위젯에서 사용
/// class LoginScreen extends StatelessWidget {
///   final authCtrl = Get.find<AuthController>();
///
///   @override
///   Widget build(BuildContext context) {
///     return Obx(() {
///       if (authCtrl.isLoading) {
///         return CircularProgressIndicator();
///       }
///       return AuthButton.kakao(
///         onPressed: () => authCtrl.signIn(KakaoAuthProvider()),
///       );
///     });
///   }
/// }
///
/// // 4. 인증 상태에 따른 화면 전환
/// class AuthGate extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     return GetBuilder<AuthController>(
///       builder: (auth) {
///         if (auth.isAuthenticated) {
///           return HomeScreen(user: auth.user!);
///         }
///         return LoginScreen();
///       },
///     );
///   }
/// }
///
/// // 또는 Obx 사용
/// class AuthGateObx extends StatelessWidget {
///   final authCtrl = Get.find<AuthController>();
///
///   @override
///   Widget build(BuildContext context) {
///     return Obx(() {
///       if (authCtrl.isAuthenticated) {
///         return HomeScreen(user: authCtrl.user!);
///       }
///       return LoginScreen();
///     });
///   }
/// }
/// ```
library getx_example;

// 이 파일은 예시 코드만 포함합니다.
// 실제 GetX 구현은 프로젝트에서 직접 작성하세요.
