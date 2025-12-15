import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/firestore_service.dart';
import '../domain/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(ref.watch(firestoreServiceProvider));
});

class TransactionRepository {
  final FirestoreService _firestoreService;

  TransactionRepository(this._firestoreService);

  Future<void> addTransaction(TransactionModel transaction) async {
    await _firestoreService.addTransaction(transaction.toMap());
  }

  // BARU: Update
  Future<void> updateTransaction(TransactionModel transaction) async {
    // Kita butuh ID doc untuk update
    await _firestoreService.updateTransaction(
      transaction.id,
      transaction.toMap(),
    );
  }

  // BARU: Delete
  Future<void> deleteTransaction(String id) async {
    await _firestoreService.deleteTransaction(id);
  }

  Stream<List<TransactionModel>> getTransactions() {
    return _firestoreService.getTransactions().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }
}
