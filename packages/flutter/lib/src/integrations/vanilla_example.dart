/// 상태 관리 없이 사용하는 예시 (Vanilla Flutter)
///
/// 별도의 상태 관리 패키지 없이 StatefulWidget만으로 사용하는 경우입니다.
/// 간단한 앱이나 프로토타입에 적합합니다.
///
/// ## 사용 예시
///
/// ```dart
/// // 1. AuthRepository를 직접 사용
/// class LoginScreen extends StatefulWidget {
///   @override
///   State<LoginScreen> createState() => _LoginScreenState();
/// }
///
/// class _LoginScreenState extends State<LoginScreen> {
///   final _authRepo = AuthRepository();
///   bool _isLoading = false;
///   String? _error;
///
///   @override
///   void initState() {
///     super.initState();
///     // 인증 상태 변화 구독
///     _authRepo.authStateChanges.listen((state) {
///       if (state.isAuthenticated && mounted) {
///         Navigator.pushReplacement(
///           context,
///           MaterialPageRoute(builder: (_) => HomeScreen(user: state.user!)),
///         );
///       }
///     });
///   }
///
///   Future<void> _signIn(AuthProvider provider) async {
///     setState(() {
///       _isLoading = true;
///       _error = null;
///     });
///
///     try {
///       await _authRepo.signIn(provider);
///     } on AuthException catch (e) {
///       setState(() => _error = e.message);
///     } finally {
///       if (mounted) {
///         setState(() => _isLoading = false);
///       }
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: Column(
///         mainAxisAlignment: MainAxisAlignment.center,
///         children: [
///           if (_error != null)
///             Text(_error!, style: TextStyle(color: Colors.red)),
///           AuthButton.kakao(
///             onPressed: _isLoading ? null : () => _signIn(KakaoAuthProvider()),
///             isLoading: _isLoading,
///           ),
///           SizedBox(height: 12),
///           AuthButton.naver(
///             onPressed: _isLoading ? null : () => _signIn(NaverAuthProvider()),
///             isLoading: _isLoading,
///           ),
///         ],
///       ),
///     );
///   }
/// }
///
/// // 2. StreamBuilder로 인증 상태 구독
/// class AuthGate extends StatelessWidget {
///   final _authRepo = AuthRepository();
///
///   @override
///   Widget build(BuildContext context) {
///     return StreamBuilder<AuthState>(
///       stream: _authRepo.authStateChanges,
///       initialData: const AuthState.initial(),
///       builder: (context, snapshot) {
///         final state = snapshot.data!;
///
///         if (state.isLoading) {
///           return Scaffold(
///             body: Center(child: CircularProgressIndicator()),
///           );
///         }
///
///         if (state.isAuthenticated) {
///           return HomeScreen(user: state.user!);
///         }
///
///         return LoginScreen();
///       },
///     );
///   }
/// }
///
/// // 3. 홈 화면
/// class HomeScreen extends StatelessWidget {
///   final AuthUser user;
///   final _authRepo = AuthRepository();
///
///   HomeScreen({required this.user});
///
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       appBar: AppBar(
///         title: Text('홈'),
///         actions: [
///           IconButton(
///             icon: Icon(Icons.logout),
///             onPressed: () async {
///               await _authRepo.signOut();
///               Navigator.pushReplacement(
///                 context,
///                 MaterialPageRoute(builder: (_) => LoginScreen()),
///               );
///             },
///           ),
///         ],
///       ),
///       body: Center(
///         child: Column(
///           mainAxisAlignment: MainAxisAlignment.center,
///           children: [
///             if (user.photoURL != null)
///               CircleAvatar(
///                 radius: 50,
///                 backgroundImage: NetworkImage(user.photoURL!),
///               ),
///             SizedBox(height: 16),
///             Text(user.displayName ?? '사용자'),
///             if (user.email != null) Text(user.email!),
///           ],
///         ),
///       ),
///     );
///   }
/// }
/// ```
library vanilla_example;

// 이 파일은 예시 코드만 포함합니다.
// 상태 관리 패키지 없이 직접 구현할 때 참고하세요.
