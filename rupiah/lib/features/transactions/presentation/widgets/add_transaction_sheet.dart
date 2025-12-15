import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../wallets/presentation/wallet_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/transaction_model.dart';
import '../transaction_controller.dart';
import '../../../categories/presentation/category_controller.dart';
import '../../../categories/presentation/manage_category_screen.dart'; // Import Screen Manage

class AddTransactionSheet extends ConsumerStatefulWidget {
  final TransactionModel? transactionToEdit;
  const AddTransactionSheet({super.key, this.transactionToEdit});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  String? _selectedWalletId;
  bool _isExpense = true;
  String _selectedCategory = 'Makan'; // Default awal
  late DateTime _selectedDate;

  // Kategori Bawaan (Static)
  final List<String> _defaultCategories = [
    'Makan',
    'Transport',
    'Belanja',
    'Gaji',
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transactionToEdit;

    _selectedDate = t?.date ?? DateTime.now();
    _selectedWalletId = t?.walletId;

    double initialAmount = t != null ? t.amount.abs() : 0;
    _amountController = TextEditingController(
      text: t != null
          ? NumberFormat.currency(
              locale: 'id',
              symbol: '',
              decimalDigits: 0,
            ).format(initialAmount)
          : '',
    );
    _noteController = TextEditingController(text: t?.note ?? '');

    if (t != null) {
      _isExpense = t.amount < 0;
      _selectedCategory = t.category;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletListAsync = ref.watch(walletListProvider);
    // AMBIL KATEGORI CUSTOM DARI FIRESTORE
    final customCategoriesAsync = ref.watch(categoryListProvider);

    final isEditing = widget.transactionToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? "Edit Transaksi" : "Catat Transaksi",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. Pilih Wallet (Sama seperti sebelumnya)
            walletListAsync.when(
              data: (wallets) {
                if (wallets.isEmpty) return const Text("Buat dompet dulu!");
                if (_selectedWalletId == null && wallets.isNotEmpty)
                  _selectedWalletId = wallets.first.id;

                return DropdownButtonFormField<String>(
                  value: _selectedWalletId,
                  decoration: InputDecoration(
                    labelText: "Pilih Dompet",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  items: wallets
                      .map(
                        (w) =>
                            DropdownMenuItem(value: w.id, child: Text(w.name)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
            ),

            const SizedBox(height: 16),

            // 2. Jenis Transaksi
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isExpense ? Colors.red : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: _isExpense
                            ? null
                            : Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        "Pengeluaran",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isExpense ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isExpense = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isExpense ? Colors.green : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: !_isExpense
                            ? null
                            : Border.all(color: Colors.grey),
                      ),
                      child: Text(
                        "Pemasukan",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: !_isExpense ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 3. Nominal
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: "Nominal",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. KATEGORI DINAMIS
            customCategoriesAsync.when(
              data: (customCats) {
                // GABUNGKAN DEFAULT + CUSTOM
                final List<String> allCategoryNames = [
                  ..._defaultCategories,
                  ...customCats.map((c) => c.name),
                ];

                // Pastikan kategori yang terpilih ada di list (kalau dihapus user, fallback ke default)
                if (!allCategoryNames.contains(_selectedCategory)) {
                  _selectedCategory = allCategoryNames.first;
                }

                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: "Kategori",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category_outlined),
                      ),
                      items: allCategoryNames
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setState(() => _selectedCategory = val!),
                    ),

                    // Link ke Halaman Kelola Kategori
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ManageCategoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text("Kelola Kategori"),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const Text("Error loading categories"),
            ),

            const SizedBox(height: 8),

            // 5. Catatan
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: "Catatan (Opsional)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isEditing ? "UPDATE TRANSAKSI" : "SIMPAN TRANSAKSI",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (_selectedWalletId == null || _amountController.text.isEmpty) return;

    final amount = CurrencyInputFormatter.parse(_amountController.text);

    if (widget.transactionToEdit != null) {
      await ref
          .read(transactionControllerProvider.notifier)
          .editTransaction(
            id: widget.transactionToEdit!.id,
            walletId: _selectedWalletId!,
            amount: amount,
            isExpense: _isExpense,
            category: _selectedCategory,
            date: _selectedDate,
            note: _noteController.text,
          );
    } else {
      await ref
          .read(transactionControllerProvider.notifier)
          .addTransaction(
            walletId: _selectedWalletId!,
            amount: amount,
            isExpense: _isExpense,
            category: _selectedCategory,
            date: _selectedDate,
            note: _noteController.text,
          );
    }

    if (mounted) Navigator.pop(context);
  }
}
