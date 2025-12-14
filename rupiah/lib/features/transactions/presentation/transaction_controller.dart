import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_model.dart';

// TAMBAHAN BARU: Provider untuk mengambil list transaksi real-time
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
}
