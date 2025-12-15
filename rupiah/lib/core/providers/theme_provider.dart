import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Kita ganti StateProvider jadi NotifierProvider (Riverpod 2.0 Style)
final themeModeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Default state: Ikut sistem HP
    return ThemeMode.system;
  }

  // Fungsi untuk mengubah tema secara eksplisit
  void setTheme(ThemeMode mode) {
    state = mode;
  }

  // Fungsi toggle simple
  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }
}
