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

  // BARU: Collection Categories
  CollectionReference get _categoriesRef =>
      _firestore.collection('users').doc(_uid).collection('categories');

  // --- WALLET METHODS ---
  Future<void> addWallet(Map<String, dynamic> data) async =>
      await _walletsRef.add(data);
  Future<void> deleteWallet(String id) async =>
      await _walletsRef.doc(id).delete();
  Stream<QuerySnapshot> getWallets() =>
      _walletsRef.orderBy('createdAt', descending: false).snapshots();

  // --- TRANSACTION METHODS ---
  Future<void> addTransaction(Map<String, dynamic> data) async =>
      await _transactionsRef.add(data);
  Future<void> updateTransaction(String id, Map<String, dynamic> data) async =>
      await _transactionsRef.doc(id).update(data);
  Future<void> deleteTransaction(String id) async =>
      await _transactionsRef.doc(id).delete();
  Stream<QuerySnapshot> getTransactions() =>
      _transactionsRef.orderBy('date', descending: true).snapshots();

  // --- CATEGORY METHODS (BARU) ---
  Future<void> addCategory(Map<String, dynamic> data) async =>
      await _categoriesRef.add(data);
  Future<void> deleteCategory(String id) async =>
      await _categoriesRef.doc(id).delete();
  Stream<QuerySnapshot> getCategories() =>
      _categoriesRef.orderBy('name').snapshots();
}
