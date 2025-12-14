import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/data/auth_repository.dart';
import '../../transactions/presentation/widgets/add_transaction_sheet.dart';
import '../../../core/utils/currency_formatter.dart'; // Import Formatter
import 'wallet_controller.dart';
import 'balance_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;
    final walletListAsync = ref.watch(walletListProvider);

    final netWorth = ref.watch(netWorthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(netWorth)}",
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_card),
            tooltip: "Tambah Dompet",
            onPressed: () => _showAddWalletDialog(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTransactionSheet(),
          );
        },
        label: const Text("Transaksi Baru"),
        icon: const Icon(Icons.receipt_long),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: walletListAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada dompet.\nKlik ikon kartu di pojok kanan atas!",
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return _WalletCard(walletId: wallet.id);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text("Error: $e")),
      ),
    );
  }

  void _showAddWalletDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Dompet Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nama Dompet (cth: BCA, Tunai)",
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: balanceController,
              decoration: const InputDecoration(labelText: "Saldo Awal (Rp)"),
              keyboardType: TextInputType.number,
              // PASANG FORMATTER DISINI
              inputFormatters: [CurrencyInputFormatter()],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              // GUNAKAN PARSER DARI CLASS TADI
              final balance = CurrencyInputFormatter.parse(
                balanceController.text,
              );

              if (name.isNotEmpty) {
                ref
                    .read(walletControllerProvider.notifier)
                    .addWallet(
                      name: name,
                      initialBalance: balance,
                      color: 0xFF2196F3,
                      icon: 'wallet',
                    );
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}

class _WalletCard extends ConsumerWidget {
  final String walletId;
  const _WalletCard({required this.walletId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallets = ref.watch(walletListProvider).value ?? [];
    final wallet = wallets.firstWhere((w) => w.id == walletId);

    final currentBalance = ref.watch(walletBalanceProvider(walletId));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(wallet.color),
          child: const Icon(Icons.account_balance_wallet, color: Colors.white),
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          ).format(currentBalance),
          style: TextStyle(
            color: currentBalance < 0 ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => ref
              .read(walletControllerProvider.notifier)
              .deleteWallet(wallet.id),
        ),
      ),
    );
  }
}
