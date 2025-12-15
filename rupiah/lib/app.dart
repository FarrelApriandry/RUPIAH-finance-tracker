import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/wallets/presentation/dashboard_screen.dart';
import 'core/providers/theme_provider.dart'; // Import Provider Tema

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

class FinanceApp extends ConsumerWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    // Watch Theme Provider
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light, // Tema Terang
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark, // Tema Gelap
      ),
      themeMode: themeMode, // <--- DINAMIS DARI SINI
      home: authState.when(
        data: (user) {
          if (user != null) {
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (e, stack) => Scaffold(body: Center(child: Text("Error: $e"))),
      ),
    );
  }
}
