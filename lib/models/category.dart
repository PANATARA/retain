import 'package:flutter/material.dart';

class Category {
  final String id;
  final String title;
  final String colorHex;
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.title,
    required this.colorHex,
    required this.createdAt,
  });

  Color get color {
    final hexCode = colorHex.replaceAll('#', '');
    if (hexCode.length == 6) {
      return Color(int.parse('FF$hexCode', radix: 16));
    } else if (hexCode.length == 8) {
      return Color(int.parse(hexCode, radix: 16));
    }
    return const Color(0xFFB8A9F8); // Default lavender
  }

  Category copyWith({
    String? id,
    String? title,
    String? colorHex,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      title: title ?? this.title,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'colorHex': colorHex,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      title: json['title'] as String,
      colorHex: json['colorHex'] as String? ?? '#B8A9F8',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
