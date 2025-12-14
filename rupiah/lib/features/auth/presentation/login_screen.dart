import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login Error: ${next.error}')));
      }
    });

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.monetization_on_outlined,
                size: 80,
                color: Colors.green,
              ),
              const SizedBox(height: 10),
              Text(
                "Rupiah Tracker",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              if (authState.isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signInWithGoogle();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Silahkan masuk dengan Google"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
