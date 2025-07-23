// lib/models/product.dart
import 'dart:convert';

class Product {
  final String id;
  final String name;
  final Map<String, dynamic>? data;

  Product({required this.id, required this.name, this.data});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] != null ? json['id'].toString() : 'N/A',
      name: json['name'] ?? 'No Name',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, data: $data)';
  }
}