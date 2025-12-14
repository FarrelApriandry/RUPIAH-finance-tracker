import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. Kalau user hapus semua, balikin kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Hapus semua karakter aneh (selain angka)
    // Contoh: "10.000" -> "10000"
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // 3. Parse ke integer
    double value = double.tryParse(newText) ?? 0;

    // 4. Format ulang jadi Rupiah (tanpa Rp dan tanpa .00 di belakang)
    // Locale 'id' otomatis ngasih titik sebagai pemisah ribuan
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    );
    String newString = formatter.format(value).trim();

    // 5. Kembalikan text baru dengan posisi kursor di paling kanan
    return newValue.copyWith(
      text: newString,
      selection: TextSelection.collapsed(offset: newString.length),
    );
  }

  // Helper statis buat bersihin format sebelum simpan ke database
  // Contoh: "10.000" -> 10000.0
  static double parse(String text) {
    return double.tryParse(text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }
}
