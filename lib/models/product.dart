// lib/models/product.dart
import 'dart:convert'; // Required for jsonEncode/jsonDecode if you use it in UI/logs

class Product {
  final String id;
  final String name;
  // The 'data' field from the API can have varying structures,
  // so using Map<String, dynamic>? is the most flexible approach.
  final Map<String, dynamic>? data;

  Product({
    required this.id,
    required this.name,
    this.data, // Make it nullable as 'data' can be null in the API response
  });

  // Factory constructor to create a Product object from a JSON map
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String, // 'id' is always a String
      name: json['name'] as String, // 'name' is always a String
      // 'data' can be a Map or null.
      // We cast it to Map<String, dynamic>?
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  // Method to convert a Product object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data, // This will be null or a map
    };
  }
}