class Wallet {
  final String id;
  final String name;
  final int color; // Kita simpan kode warna (0xFF...) sebagai int
  final String icon; // Kode icon atau path asset
  final double
  initialBalance; // Saldo awal saat dompet dibuat (bukan saldo saat ini)
  final DateTime createdAt;

  Wallet({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.initialBalance,
    required this.createdAt,
  });

  // Konversi dari Firestore Map ke Object Dart
  factory Wallet.fromMap(Map<String, dynamic> map, String docId) {
    return Wallet(
      id: docId,
      name: map['name'] ?? 'Unnamed Wallet',
      color: map['color'] ?? 0xFF4CAF50, // Default Green
      icon: map['icon'] ?? '',
      initialBalance: (map['initialBalance'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              map['createdAt'].millisecondsSinceEpoch,
            )
          : DateTime.now(),
    );
  }

  // Konversi dari Object Dart ke Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'icon': icon,
      'initialBalance': initialBalance,
      'createdAt': createdAt,
    };
  }
}
