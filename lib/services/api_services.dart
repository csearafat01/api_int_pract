// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://api.restful-api.dev';

  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl)); // Dio instance

  static void _logResponse(String method, Response? response, DioException? error) {
    if (kDebugMode) {
      print('--- $method Response ---');
    }
    if (response != null) {
      if (kDebugMode) {
        print('Status Code: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Headers: ${response.headers}');
      }
      if (kDebugMode) {
        print('Body: ${response.data ?? "[No Body]"}');
      }
    } else if (error != null) {
      if (kDebugMode) {
        print('DioException Type: ${error.type}');
      }
      if (kDebugMode) {
        print('Status Code: ${error.response?.statusCode}');
      }
      if (kDebugMode) {
        print('Message: ${error.message}');
      }
      if (kDebugMode) {
        print('Response Body: ${error.response?.data}');
      }
    }
    if (kDebugMode) {
      print('------------------------');
    }
  }

  // --- GET Operations ---
  static Future<List<Product>> fetchAllProducts() async {
    try {
      final response = await _dio.get('/objects');
      _logResponse('GET /objects', response, null);

      if (response.statusCode == 200) {
        List<dynamic> jsonList = response.data;
        return jsonList.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('GET /objects', null, e);
      throw Exception('Failed to load products: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  static Future<Product> fetchProductById(String id) async {
    try {
      final response = await _dio.get('/objects/$id');
      _logResponse('GET /objects/$id', response, null);

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to load product with ID $id: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('GET /objects/$id', null, e);
      throw Exception('Failed to load product with ID $id: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- POST Operation (Create) ---
  static Future<Product> createProduct(String name, {Map<String, dynamic>? data}) async {
    final Map<String, dynamic> requestBody = {'name': name};
    if (data != null) {
      requestBody['data'] = data;
    }

    try {
      final response = await _dio.post(
        '/objects',
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );
      _logResponse('POST /objects', response, null);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to create product: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('POST /objects', null, e);
      throw Exception('Failed to create product: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- PUT Operation (Full Update/Replace) ---
  static Future<Product> updateProductPut(String id, String name, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/objects/$id',
        data: {
          'id': id,
          'name': name,
          'data': data,
        },
        options: Options(
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );
      _logResponse('PUT /objects/$id', response, null);

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to update product (PUT) with ID $id: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('PUT /objects/$id', null, e);
      throw Exception('Failed to update product (PUT) with ID $id: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- PATCH Operation (Partial Update) ---
  static Future<Product> updateProductPatch(String id, {String? name, Map<String, dynamic>? data}) async {
    final Map<String, dynamic> updatePayload = {};
    if (name != null) {
      updatePayload['name'] = name;
    }
    if (data != null) {
      updatePayload['data'] = data;
    }

    try {
      final response = await _dio.patch(
        '/objects/$id',
        data: updatePayload,
        options: Options(
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
        ),
      );
      _logResponse('PATCH /objects/$id', response, null);

      if (response.statusCode == 200) {
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to update product (PATCH) with ID $id: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('PATCH /objects/$id', null, e);
      throw Exception('Failed to update product (PATCH) with ID $id: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  // --- DELETE Operation ---
  static Future<void> deleteProduct(String id) async {
    try {
      final response = await _dio.delete('/objects/$id');
      _logResponse('DELETE /objects/$id', response, null);

      if (response.statusCode == 200 || response.statusCode == 204) {
        if (kDebugMode) {
          print('Object with ID $id deleted successfully.');
        }
        if (response.data != null) {
          if (kDebugMode) {
            print('Delete response: ${response.data}');
          }
        }
      } else {
        throw Exception('Failed to delete product with ID $id: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      _logResponse('DELETE /objects/$id', null, e);
      throw Exception('Failed to delete product with ID $id: ${e.response?.statusCode ?? 'N/A'} - ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}