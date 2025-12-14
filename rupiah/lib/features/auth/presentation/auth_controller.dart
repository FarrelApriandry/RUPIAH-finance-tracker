import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

// 🚀 UPGRADE: Menggunakan AsyncNotifier (Riverpod 2.0 Style)
// Ini pengganti StateNotifier yang lebih modern.

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  // Method build() wajib ada di Riverpod 2.0 sebagai inisialisasi
  @override
  FutureOr<void> build() {
    // Return null artinya state awal adalah "Idle" (tidak loading, tidak error)
    return null;
  }

  Future<void> signInWithGoogle() async {
    // 1. Set state jadi loading
    state = const AsyncValue.loading();

    // 2. Jalankan logic login
    // AsyncValue.guard otomatis menangkap Error kalau login gagal
    state = await AsyncValue.guard(() async {
      final repo = ref.read(
        authRepositoryProvider,
      ); // Baca repo langsung di sini
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
}
