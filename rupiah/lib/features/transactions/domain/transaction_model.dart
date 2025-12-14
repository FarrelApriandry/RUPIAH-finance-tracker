class TransactionModel {
  final String id;
  final String walletId;
  final double amount; // (-) Expense, (+) Income
  final String category;
  final String? note;
  final DateTime date; // Tanggal transaksi terjadi
  final DateTime createdAt; // Tanggal user input data

  TransactionModel({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.category,
    this.note,
    required this.date,
    required this.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String docId) {
    return TransactionModel(
      id: docId,
      walletId: map['walletId'] ?? '',
      amount: (map['amount'] ?? 0).toDouble(),
      category: map['category'] ?? 'General',
      note: map['note'],
      date: map['date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['date'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'walletId': walletId,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date,
      'createdAt': createdAt,
    };
  }
}
