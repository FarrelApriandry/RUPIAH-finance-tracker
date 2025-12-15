import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");
  return FirestoreService(FirebaseFirestore.instance, user.uid);
});

class FirestoreService {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreService(this._firestore, this._uid);

  CollectionReference get _walletsRef =>
      _firestore.collection('users').doc(_uid).collection('wallets');

  CollectionReference get _transactionsRef =>
      _firestore.collection('users').doc(_uid).collection('transactions');

  // --- WALLET METHODS ---
  Future<void> addWallet(Map<String, dynamic> data) async {
    await _walletsRef.add(data);
  }

  Future<void> deleteWallet(String id) async {
    await _walletsRef.doc(id).delete();
  }

  Stream<QuerySnapshot> getWallets() {
    return _walletsRef.orderBy('createdAt', descending: false).snapshots();
  }

  // --- TRANSACTION METHODS (UPDATED) ---
  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _transactionsRef.add(data);
  }

  // BARU: Update Transaksi
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async {
    await _transactionsRef.doc(id).update(data);
  }

  // BARU: Hapus Transaksi
  Future<void> deleteTransaction(String id) async {
    await _transactionsRef.doc(id).delete();
  }

  Stream<QuerySnapshot> getTransactions() {
    return _transactionsRef.orderBy('date', descending: true).snapshots();
  }
}
