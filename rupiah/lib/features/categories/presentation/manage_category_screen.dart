import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_controller.dart';
import '../domain/category_model.dart';

class ManageCategoryScreen extends ConsumerStatefulWidget {
  const ManageCategoryScreen({super.key});

  @override
  ConsumerState<ManageCategoryScreen> createState() =>
      _ManageCategoryScreenState();
}

class _ManageCategoryScreenState extends ConsumerState<ManageCategoryScreen> {
  final _nameController = TextEditingController();
  int _selectedColor = 0xFF2196F3; // Default Blue
  IconData _selectedIcon = Icons.fastfood; // Default Makan

  // Preset Pilihan Warna
  final List<int> _colors = [
    0xFF2196F3,
    0xFF4CAF50,
    0xFFF44336,
    0xFFFFC107,
    0xFF9C27B0,
    0xFF607D8B,
    0xFF795548,
    0xFFE91E63,
  ];

  // Preset Pilihan Icon
  final List<IconData> _icons = [
    Icons.fastfood,
    Icons.directions_car,
    Icons.shopping_bag,
    Icons.work,
    Icons.home,
    Icons.movie,
    Icons.sports_soccer,
    Icons.school,
    Icons.medical_services,
    Icons.flight,
    Icons.pets,
    Icons.gamepad,
  ];

  @override
  Widget build(BuildContext context) {
    final categoryList = ref.watch(categoryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Kategori")),
      body: Column(
        children: [
          // 1. LIST KATEGORI YANG ADA
          Expanded(
            child: categoryList.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(
                    child: Text("Belum ada kategori custom."),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(cat.color).withOpacity(0.2),
                          child: Icon(cat.icon, color: Color(cat.color)),
                        ),
                        title: Text(cat.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => ref
                              .read(categoryControllerProvider.notifier)
                              .deleteCategory(cat.id),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text("Err: $e")),
            ),
          ),

          // 2. FORM TAMBAH BARU (Bottom Sheet Style tapi nempel)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Buat Kategori Baru",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Input Nama
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: "Nama Kategori (misal: Skincare)",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),

                // Pilih Icon
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _icons.length,
                    itemBuilder: (context, index) {
                      final icon = _icons[index];
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Pilih Warna
                SizedBox(
                  height: 30,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, index) {
                      final color = _colors[index];
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Tombol Simpan
                ElevatedButton(
                  onPressed: () {
                    final name = _nameController.text.trim();
                    if (name.isNotEmpty) {
                      ref
                          .read(categoryControllerProvider.notifier)
                          .addCategory(
                            name: name,
                            color: _selectedColor,
                            iconCode: _selectedIcon.codePoint,
                          );
                      _nameController.clear(); // Reset form
                      // Tutup keyboard
                      FocusScope.of(context).unfocus();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("TAMBAH KATEGORI"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
