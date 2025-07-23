// lib/controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/product.dart';
import '../services/api_services.dart';


class ProductController extends GetxController {
  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final fetchedProducts = await ApiService.fetchAllProducts();
      products.assignAll(fetchedProducts);
    } catch (e) {
      errorMessage.value = 'Failed to load products: ${e.toString()}';
      _showErrorSnackbar('Fetch Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct(String name, {Map<String, dynamic>? data}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final newProduct = await ApiService.createProduct(name, data: data);
      _showSuccessSnackbar('Success', 'Product created: ${newProduct.name} (ID: ${newProduct.id})');
      fetchProducts();
    } catch (e) {
      errorMessage.value = 'Error creating product: ${e.toString()}';
      _showErrorSnackbar('Creation Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProductPut(String id, String name, Map<String, dynamic> data) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final updatedProduct = await ApiService.updateProductPut(id, name, data);
      _showSuccessSnackbar('Success', 'Product ID $id updated (PUT): ${updatedProduct.name}');
      fetchProducts();
    } catch (e) {
      errorMessage.value = 'Error updating product (PUT) ID $id: ${e.toString()}';
      _showErrorSnackbar('Update (PUT) Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProductPatch(String id, {String? name, Map<String, dynamic>? data}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final patchedProduct = await ApiService.updateProductPatch(id, name: name, data: data);
      _showSuccessSnackbar('Success', 'Product ID $id updated (PATCH): ${patchedProduct.name}');
      fetchProducts();
    } catch (e) {
      errorMessage.value = 'Error updating product (PATCH) ID $id: ${e.toString()}';
      _showErrorSnackbar('Update (PATCH) Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await ApiService.deleteProduct(id);
      _showSuccessSnackbar('Success', 'Product ID $id deleted successfully.');
      products.removeWhere((product) => product.id == id);
      fetchProducts();
    } catch (e) {
      errorMessage.value = 'Error deleting product ID $id: ${e.toString()}';
      _showErrorSnackbar('Deletion Failed', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }
}