import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

// Provider Stream List Transaksi (Gak berubah)
final transactionListProvider = StreamProvider<List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return repository.getTransactions();
});

final transactionControllerProvider =
    AsyncNotifierProvider<TransactionController, void>(() {
      return TransactionController();
    });

class TransactionController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> addTransaction({
    required String walletId,
    required double amount,
    required bool isExpense,
    required String category,
    String? note,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);

      final finalAmount = isExpense ? (amount * -1) : amount;

      final newTransaction = TransactionModel(
        id: '',
        walletId: walletId,
        amount: finalAmount,
        category: category,
        note: note,
        date: date,
        createdAt: DateTime.now(),
      );

      await repository.addTransaction(newTransaction);
    });
  }

  // BARU: Edit Transaksi
  Future<void> editTransaction({
    required String id, // Butuh ID
    required String walletId,
    required double amount,
    required bool isExpense,
    required String category,
    String? note,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);

      final finalAmount = isExpense ? (amount * -1) : amount;

      // Buat object baru dengan ID yang sama
      final updatedTransaction = TransactionModel(
        id: id,
        walletId: walletId,
        amount: finalAmount,
        category: category,
        note: note,
        date: date,
        createdAt:
            DateTime.now(), // CreatedAt gak perlu diubah sebenernya, tapi gpp
      );

      await repository.updateTransaction(updatedTransaction);
    });
  }

  // BARU: Hapus Transaksi
  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(transactionRepositoryProvider);
      await repository.deleteTransaction(id);
    });
  }
}
