import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider global buat akses FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  // Otomatis ambil UID user yang lagi login
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw Exception("User not logged in");
  return FirestoreService(FirebaseFirestore.instance, user.uid);
});

class FirestoreService {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreService(this._firestore, this._uid);

  // --- PATH HELPERS ---
  // users/{uid}/wallets
  CollectionReference get _walletsRef =>
      _firestore.collection('users').doc(_uid).collection('wallets');

  // users/{uid}/transactions
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

  // --- TRANSACTION METHODS ---
  Future<void> addTransaction(Map<String, dynamic> data) async {
    await _transactionsRef.add(data);
  }

  Stream<QuerySnapshot> getTransactions() {
    return _transactionsRef.orderBy('date', descending: true).snapshots();
  }
}
