import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../wallets/presentation/wallet_controller.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/transaction_model.dart'; // Import Model
import '../transaction_controller.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  // Tambahkan parameter opsional ini
  final TransactionModel? transactionToEdit;

  const AddTransactionSheet({super.key, this.transactionToEdit});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _customCategoryController;

  String? _selectedWalletId;
  bool _isExpense = true;
  String _selectedCategory = 'Makan';
  late DateTime _selectedDate;

  final List<String> _categories = [
    'Makan',
    'Transport',
    'Belanja',
    'Gaji',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    // 1. CEK APAKAH INI MODE EDIT?
    final t = widget.transactionToEdit;

    // Inisialisasi data awal
    _selectedDate = t?.date ?? DateTime.now();
    _selectedWalletId = t?.walletId;

    // Kalau edit, ambil amountnya (pastiin jadi positif dulu buat ditampilin)
    double initialAmount = t != null ? t.amount.abs() : 0;

    // Setup Controller dengan data awal (kalau ada)
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

    // Logic Kategori & Type
    if (t != null) {
      _isExpense = t.amount < 0;

      if (_categories.contains(t.category)) {
        _selectedCategory = t.category;
        _customCategoryController = TextEditingController();
      } else {
        _selectedCategory = 'Lainnya';
        _customCategoryController = TextEditingController(text: t.category);
      }
    } else {
      _customCategoryController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletListAsync = ref.watch(walletListProvider);
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

            // 1. Pilih Wallet
            walletListAsync.when(
              data: (wallets) {
                if (wallets.isEmpty) return const Text("Buat dompet dulu!");
                // Kalau new transaction & belum pilih, pilih pertama
                if (_selectedWalletId == null && wallets.isNotEmpty) {
                  _selectedWalletId = wallets.first.id;
                }

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
                  items: wallets.map((w) {
                    return DropdownMenuItem(value: w.id, child: Text(w.name));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedWalletId = val),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text("Error: $e"),
            ),

            const SizedBox(height: 16),

            // 2. Jenis Transaksi
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
                              : Border.all(color: Colors.grey, width: 2),
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
                          color: !_isExpense
                              ? Colors.green
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: !_isExpense
                              ? null
                              : Border.all(color: Colors.grey, width: 2),
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

            // 4. Kategori
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: "Kategori",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedCategory = val!;
                if (_selectedCategory != 'Lainnya')
                  _customCategoryController.clear();
              }),
            ),

            if (_selectedCategory == 'Lainnya') ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customCategoryController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: "Nama Kategori Lainnya",
                  hintText: "Contoh: Parkir, Amal",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_outlined),
                  filled: true,
                  fillColor: Colors.yellow.shade50,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 5. Catatan
            TextField(
              controller: _noteController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: "Catatan (Opsional)",
                hintText: "Contoh: Makan siang bareng",
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

    if (_selectedCategory == 'Lainnya' &&
        _customCategoryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi kategori lainnya!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = CurrencyInputFormatter.parse(_amountController.text);
    final finalCategory = _selectedCategory == 'Lainnya'
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (widget.transactionToEdit != null) {
      // MODE EDIT
      await ref
          .read(transactionControllerProvider.notifier)
          .editTransaction(
            id: widget.transactionToEdit!.id, // ID Lama
            walletId: _selectedWalletId!,
            amount: amount,
            isExpense: _isExpense,
            category: finalCategory,
            date: _selectedDate,
            note: _noteController.text,
          );
    } else {
      // MODE ADD
      await ref
          .read(transactionControllerProvider.notifier)
          .addTransaction(
            walletId: _selectedWalletId!,
            amount: amount,
            isExpense: _isExpense,
            category: finalCategory,
            date: _selectedDate,
            note: _noteController.text,
          );
    }

    if (mounted) Navigator.pop(context);
  }
}
