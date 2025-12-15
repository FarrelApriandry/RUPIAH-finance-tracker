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

  CollectionReference get _categoriesRef =>
      _firestore.collection('users').doc(_uid).collection('categories');

  // --- EXISTING METHODS (Gak berubah) ---
  Future<void> addWallet(Map<String, dynamic> data) async =>
      await _walletsRef.add(data);
  Future<void> deleteWallet(String id) async =>
      await _walletsRef.doc(id).delete();
  Stream<QuerySnapshot> getWallets() =>
      _walletsRef.orderBy('createdAt', descending: false).snapshots();

  Future<void> addTransaction(Map<String, dynamic> data) async =>
      await _transactionsRef.add(data);
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async =>
      await _transactionsRef.doc(id).update(data);
  Future<void> deleteTransaction(String id) async =>
      await _transactionsRef.doc(id).delete();
  Stream<QuerySnapshot> getTransactions() =>
      _transactionsRef.orderBy('date', descending: true).snapshots();

  Future<void> addCategory(Map<String, dynamic> data) async =>
      await _categoriesRef.add(data);
  Future<void> deleteCategory(String id) async =>
      await _categoriesRef.doc(id).delete();
  Stream<QuerySnapshot> getCategories() =>
      _categoriesRef.orderBy('name').snapshots();

  // --- NEW: DANGEROUS ZONE ---
  Future<void> deleteAllData() async {
    // Hapus semua Transaksi
    final trans = await _transactionsRef.get();
    for (var doc in trans.docs) await doc.reference.delete();

    // Hapus semua Wallet
    final wallets = await _walletsRef.get();
    for (var doc in wallets.docs) await doc.reference.delete();

    // Hapus semua Kategori Custom
    final cats = await _categoriesRef.get();
    for (var doc in cats.docs) await doc.reference.delete();
  }
}
