import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../transactions/presentation/transaction_controller.dart';
import 'wallet_controller.dart';

// 1. Menghitung Total Kekayaan (Net Worth) - Semua Dompet
final netWorthProvider = Provider<double>((ref) {
  final wallets = ref.watch(walletListProvider).value ?? [];
  final transactions = ref.watch(transactionListProvider).value ?? [];

  double total = 0;

  for (var wallet in wallets) {
    // Saldo Awal
    double walletBalance = wallet.initialBalance;

    // Tambah/Kurang dengan transaksi terkait dompet ini
    final walletTransactions = transactions.where(
      (t) => t.walletId == wallet.id,
    );
    for (var t in walletTransactions) {
      walletBalance += t.amount;
    }

    total += walletBalance;
  }

  return total;
});

// 2. Menghitung Saldo Per Dompet (Specific Wallet Balance)
// Menggunakan .family karena butuh parameter walletId
final walletBalanceProvider = Provider.family<double, String>((ref, walletId) {
  final wallets = ref.watch(walletListProvider).value ?? [];
  final transactions = ref.watch(transactionListProvider).value ?? [];

  // Cari dompetnya (safe search)
  final wallet = wallets.firstWhere(
    (w) => w.id == walletId,
    orElse: () => throw Exception('Wallet not found'),
  );

  double balance = wallet.initialBalance;

  // Filter transaksi cuma buat dompet ini
  final walletTransactions = transactions.where((t) => t.walletId == walletId);
  for (var t in walletTransactions) {
    balance += t.amount;
  }

  return balance;
});
