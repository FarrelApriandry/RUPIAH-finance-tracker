import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart'; // Import ini
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    });
  }

  // BARU: Update Profile (Nama & Foto)
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (displayName != null) await user.updateDisplayName(displayName);
        if (photoURL != null) await user.updatePhotoURL(photoURL);

        // Reload user biar UI update
        await user.reload();
      }
    });
  }
}
