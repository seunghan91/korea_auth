
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_k_auth/open_k_auth.dart';
import 'package:open_k_auth/src/providers/google_auth_provider.dart';
import 'package:open_k_auth/src/providers/kakao_auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Open K-Auth Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final authRepo = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Open K-Auth Example')),
      body: Center(
        child: authState.when(
          data: (state) {
            if (state.isAuthenticated) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.user?.photoURL != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(state.user!.photoURL!),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, ${state.user?.displayName ?? 'User'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text('Provider: ${state.user?.providerId}'),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => authRepo.signOut(),
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            }
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  AuthButton.google(
                    onPressed: () => authRepo.signIn(GoogleAuthProvider()),
                    isLoading: state.isLoading,
                  ),
                  const SizedBox(height: 16),
                  AuthButton.kakao(
                    onPressed: () => authRepo.signIn(KakaoAuthProvider()),
                    isLoading: state.isLoading,
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Text('Error: $e'),
        ),
      ),
    );
  }
}
