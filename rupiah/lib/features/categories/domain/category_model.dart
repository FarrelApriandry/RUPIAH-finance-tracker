import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int color; // Disimpan sebagai integer (0xFF...)
  final int iconCode; // Disimpan sebagai CodePoint dari IconData

  CategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.iconCode,
  });

  // Helper buat convert data Icon biar gampang dipakai di UI
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      color: map['color'] ?? 0xFF9E9E9E,
      iconCode: map['iconCode'] ?? 57522, // Default icon code
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'color': color, 'iconCode': iconCode};
  }
}
