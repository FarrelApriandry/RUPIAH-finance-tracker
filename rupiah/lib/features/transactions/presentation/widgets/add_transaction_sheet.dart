import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../wallets/presentation/wallet_controller.dart';
import '../../../../core/utils/currency_formatter.dart'; // Import Formatter
import '../transaction_controller.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  const AddTransactionSheet({super.key});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedWalletId;
  bool _isExpense = true;
  String _selectedCategory = 'Makan';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Makan',
    'Transport',
    'Belanja',
    'Gaji',
    'Lainnya',
  ];

  @override
  Widget build(BuildContext context) {
    final walletListAsync = ref.watch(walletListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Catat Transaksi",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 1. Pilih Wallet
          walletListAsync.when(
            data: (wallets) {
              if (wallets.isEmpty) return const Text("Buat dompet dulu!");
              if (_selectedWalletId == null && wallets.isNotEmpty) {
                _selectedWalletId = wallets.first.id;
              }

              return DropdownButtonFormField<String>(
                value: _selectedWalletId,
                decoration: const InputDecoration(
                  labelText: "Pilih Dompet",
                  border: OutlineInputBorder(),
                ),
                items: wallets.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Text(
                      "${w.name} (${NumberFormat.compact().format(w.initialBalance)})",
                    ),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedWalletId = val),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text("Error loading wallets: $e"),
          ),

          const SizedBox(height: 12),

          // 2. Jenis Transaksi
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text("Pengeluaran"),
                  selected: _isExpense,
                  onSelected: (val) => setState(() => _isExpense = true),
                  selectedColor: Colors.red.shade100,
                  labelStyle: TextStyle(
                    color: _isExpense ? Colors.red : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Text("Pemasukan"),
                  selected: !_isExpense,
                  onSelected: (val) => setState(() => _isExpense = false),
                  selectedColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    color: !_isExpense ? Colors.green : Colors.black,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Input Nominal (DENGAN FORMATTER)
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            // PASANG FORMATTER DISINI
            inputFormatters: [CurrencyInputFormatter()],
            decoration: const InputDecoration(
              labelText: "Nominal (Rp)",
              prefixText: "Rp ",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 12),

          // 4. Kategori
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: "Kategori",
              border: OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _selectedCategory = val!),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("SIMPAN TRANSAKSI"),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _submit() async {
    if (_selectedWalletId == null || _amountController.text.isEmpty) return;

    // PARSE ANGKA DARI STRING YANG ADA TITIKNYA
    final amount = CurrencyInputFormatter.parse(_amountController.text);

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

    if (mounted) Navigator.pop(context);
  }
}
