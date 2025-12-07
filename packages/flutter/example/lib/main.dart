import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_k_auth/open_k_auth.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Open K-Auth Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: ref
          .watch(authStateProvider)
          .when(
            data: (state) {
              if (state.isAuthenticated) {
                return HomeScreen(user: state.user!);
              }
              return const LoginScreen();
            },
            loading: () => const SplashScreen(),
            error: (e, _) => ErrorScreen(error: e),
          ),
    );
  }
}

/// 스플래시 화면
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('로딩 중...'),
          ],
        ),
      ),
    );
  }
}

/// 에러 화면
class ErrorScreen extends StatelessWidget {
  final Object error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              '오류가 발생했습니다',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text('$error', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// 로그인 화면
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  AuthProviderType? _loadingProvider;

  Future<void> _signIn(AuthProviderType providerType) async {
    setState(() => _loadingProvider = providerType);

    try {
      final provider = switch (providerType) {
        AuthProviderType.kakao => KakaoAuthProvider(),
        AuthProviderType.naver => NaverAuthProvider(),
        AuthProviderType.google => GoogleAuthProvider(),
        AuthProviderType.apple => AppleAuthProvider(),
      };

      await ref.read(authNotifierProvider.notifier).signIn(provider);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인 성공!')));
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'cancelled') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 취소되었습니다')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loadingProvider = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고/타이틀
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              Text('로그인', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                '소셜 계정으로 간편하게 로그인하세요',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // 로그인 버튼 그룹
              LoginButtonGroup(
                providers: const [
                  AuthProviderType.kakao,
                  AuthProviderType.naver,
                  AuthProviderType.google,
                  AuthProviderType.apple,
                ],
                onPressed: _signIn,
                loadingProvider: _loadingProvider,
                spacing: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 홈 화면
class HomeScreen extends ConsumerWidget {
  final AuthUser user;

  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('로그아웃'),
                  content: const Text('정말 로그아웃하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('로그아웃'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로필 이미지
              if (user.photoURL != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(user.photoURL!),
                )
              else
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
              const SizedBox(height: 24),

              // 사용자 정보
              Text(
                user.displayName ?? '사용자',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (user.email != null) ...[
                const SizedBox(height: 8),
                Text(
                  user.email!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),

              // Provider 정보
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getProviderColor(user.providerId).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  user.providerId.toUpperCase(),
                  style: TextStyle(
                    color: _getProviderColor(user.providerId),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 사용자 ID
              Text(
                'UID: ${user.uid}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProviderColor(String providerId) {
    return switch (providerId) {
      'kakao' => const Color(0xFFFEE500),
      'naver' => const Color(0xFF03C75A),
      'google' => const Color(0xFF4285F4),
      'apple' => Colors.black,
      _ => Colors.grey,
    };
  }
}
