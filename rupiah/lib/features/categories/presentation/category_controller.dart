import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/firestore_service.dart';
import '../domain/category_model.dart';

// --- REPOSITORY ---
class CategoryRepository {
  final FirestoreService _service;
  CategoryRepository(this._service);

  Future<void> addCategory(CategoryModel category) =>
      _service.addCategory(category.toMap());
  Future<void> deleteCategory(String id) => _service.deleteCategory(id);
  Stream<List<CategoryModel>> getCategories() {
    return _service.getCategories().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => CategoryModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    });
  }
}

final categoryRepositoryProvider = Provider(
  (ref) => CategoryRepository(ref.watch(firestoreServiceProvider)),
);

// --- PROVIDER LIST (Stream) ---
final categoryListProvider = StreamProvider<List<CategoryModel>>((ref) {
  return ref.watch(categoryRepositoryProvider).getCategories();
});

// --- CONTROLLER (Action) ---
final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, void>(CategoryController.new);

class CategoryController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() => null;

  Future<void> addCategory({
    required String name,
    required int color,
    required int iconCode,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(categoryRepositoryProvider);
      final newCat = CategoryModel(
        id: '',
        name: name,
        color: color,
        iconCode: iconCode,
      );
      await repo.addCategory(newCat);
    });
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteCategory(id);
    });
  }
}
