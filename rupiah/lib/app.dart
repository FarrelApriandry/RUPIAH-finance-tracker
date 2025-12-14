import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/wallets/presentation/dashboard_screen.dart';

// Provider untuk memantau status Auth user secara realtime
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pantau authState
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      // Logic Gate: Menentukan halaman mana yang muncul
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen(); // User sudah login
          } else {
            return const LoginScreen(); // User belum login
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, stack) => Scaffold(body: Center(child: Text("Error: $e"))),
      ),
    );
  }
}
