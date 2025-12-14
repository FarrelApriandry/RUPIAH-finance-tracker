import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../domain/wallet_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(firestoreServiceProvider));
});

class WalletRepository {
  final FirestoreService _firestoreService;

  WalletRepository(this._firestoreService);

  // Tambah Wallet Baru
  Future<void> addWallet(Wallet wallet) async {
    await _firestoreService.addWallet(wallet.toMap());
  }

  // Hapus Wallet
  Future<void> deleteWallet(String id) async {
    await _firestoreService.deleteWallet(id);
  }

  // Ambil data real-time (Stream)
  Stream<List<Wallet>> getWallets() {
    return _firestoreService.getWallets().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Wallet.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
