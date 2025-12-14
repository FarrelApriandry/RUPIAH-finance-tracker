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

  // Kita siapin sekalian buat nanti nampilin history (Day 8)
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
