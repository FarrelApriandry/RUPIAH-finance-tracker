import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/transaction_model.dart';
import '../transaction_controller.dart';
import 'add_transaction_sheet.dart';

class TransactionItem extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFmt = DateFormat('d MMM, HH:mm').format(transaction.date);

    final currencyFmt = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(transaction.amount.abs());

    final isExpense = transaction.amount < 0;

    // FITUR SWIPE TO DELETE (Dismissible)
    return Dismissible(
      key: Key(transaction.id), // Kunci unik
      direction: DismissDirection.endToStart, // Geser dari kanan ke kiri
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        // Konfirmasi Hapus
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Hapus Transaksi?"),
            content: const Text("Saldo dompet akan otomatis disesuaikan."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Hapus", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        // Panggil Controller buat hapus di Firestore
        ref
            .read(transactionControllerProvider.notifier)
            .deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Transaksi dihapus"),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Card(
        elevation: 0,
        color: Colors.grey.shade50,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          // FITUR TAP TO EDIT
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => AddTransactionSheet(
                transactionToEdit: transaction,
              ), // Oper data transaksi
            );
          },
          leading: CircleAvatar(
            backgroundColor: isExpense
                ? Colors.red.shade100
                : Colors.green.shade100,
            child: Icon(
              isExpense ? Icons.arrow_downward : Icons.arrow_upward,
              color: isExpense ? Colors.red : Colors.green,
              size: 20,
            ),
          ),
          title: Text(
            transaction.category,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (transaction.note != null && transaction.note!.isNotEmpty)
                Text(
                  transaction.note!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              Text(
                dateFmt,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          trailing: Text(
            "${isExpense ? '-' : '+'} $currencyFmt",
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
