import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_model.dart';

// Provider untuk List Wallet (Stream)
// UI tinggal watch provider ini, otomatis update kalau ada data baru di Firestore
final walletListProvider = StreamProvider<List<Wallet>>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWallets();
});

// Controller untuk Aksi (Add/Delete)
final walletControllerProvider = AsyncNotifierProvider<WalletController, void>(
  () {
    return WalletController();
  },
);

class WalletController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> addWallet({
    required String name,
    required double initialBalance,
    required int color,
    required String icon,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(walletRepositoryProvider);

      final newWallet = Wallet(
        id: '', // ID bakal di-generate Firestore otomatis
        name: name,
        color: color,
        icon: icon,
        initialBalance: initialBalance,
        createdAt: DateTime.now(),
      );

      await repository.addWallet(newWallet);
    });
  }

  Future<void> deleteWallet(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(walletRepositoryProvider);
      // TODO: Nanti di sini kita tambah logic cek transaksi sebelum hapus
      await repository.deleteWallet(id);
    });
  }
}
