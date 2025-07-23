// lib/controllers/product_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert'; // Import for jsonDecode

import '../models/product.dart';
import '../services/api_service.dart';

class ProductController extends GetxController {
  var products = <Product>[].obs; // This list will be displayed in the UI (filtered or all)
  var _allProducts = <Product>[].obs; // Private list to hold all products fetched from the API
  var isLoading = false.obs; // To manage loading state

  // Text controllers for UI input fields
  TextEditingController searchController = TextEditingController(); // For active search, single/multi ID search
  TextEditingController nameController = TextEditingController();
  TextEditingController dataController = TextEditingController(); // For JSON string input

  // Reactive string for debouncing search input
  Rx<String> _searchQuery = ''.obs;

  @override
  void onInit() {
    fetchAllProducts(); // Initial fetch when the controller is initialized

    // Listen to changes in the searchController text
    // We use a listener to update a reactive variable (_searchQuery)
    // and then debounce that reactive variable to prevent too many filters
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });

    // Debounce the search query updates
    // This delays the execution of the filter method for a short period (e.g., 300ms)
    // after the user stops typing, improving performance.
    debounce(_searchQuery, (String query) {
      if (query.isEmpty) {
        // If the search bar is cleared, display all products
        products.assignAll(_allProducts);
      } else {
        // Otherwise, filter the products based on the query
        filterProducts(query);
      }
    }, time: const Duration(milliseconds: 300)); // Adjust debounce time as needed

    super.onInit();
  }

  @override
  void onClose() {
    // Dispose of controllers to prevent memory leaks
    searchController.dispose();
    nameController.dispose();
    dataController.dispose();
    super.onClose();
  }

  // --- Helper methods for Snackbars ---
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

  // --- CRUD Operations ---

  // READ All Products
  void fetchAllProducts() async {
    try {
      isLoading.value = true;
      final fetchedProducts = await ApiService.getAllProducts();
      _allProducts.assignAll(fetchedProducts); // Store all products in the private list
      products.assignAll(fetchedProducts); // Initialize the displayed list with all products
    } catch (e) {
      _showErrorSnackbar('Error', 'Failed to load products: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Active search filtering logic
  void filterProducts(String query) {
    if (query.isEmpty) {
      products.assignAll(_allProducts); // If query is empty, show all products
      return;
    }

    final lowerCaseQuery = query.toLowerCase();
    final filtered = _allProducts.where((product) {
      // Filter by product ID or name (case-insensitive)
      return product.id.toLowerCase().contains(lowerCaseQuery) ||
          product.name.toLowerCase().contains(lowerCaseQuery);
    }).toList();

    products.assignAll(filtered); // Update the displayed list with filtered results
  }

  // READ Single Product by ID (Explicit API Call)
  void fetchProductById() async {
    final id = searchController.text.trim(); // Reads from the common search text field
    if (id.isEmpty) {
      _showErrorSnackbar('Input Error', 'Please enter an ID to search.');
      return;
    }
    try {
      isLoading.value = true;
      final product = await ApiService.getProductById(id);
      products.assignAll([product]); // Display the single fetched product
      _showSuccessSnackbar('Success', 'Product ID $id found.');
    } catch (e) {
      _showErrorSnackbar('Error', 'Error fetching product by ID $id: ${e.toString()}');
      products.clear(); // Clear the list on error for single ID fetch
    } finally {
      isLoading.value = false;
    }
  }

  // READ Products by Multiple IDs (Explicit API Call)
  void fetchProductsByMultipleIds() async {
    final input = searchController.text.trim(); // Reads from the common search text field
    final ids = input.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (ids.isEmpty) {
      _showErrorSnackbar('Input Error', 'Please enter at least one ID, separated by commas.');
      return;
    }

    try {
      isLoading.value = true;
      // Make multiple individual GET requests concurrently
      final fetched = await Future.wait(ids.map(ApiService.getProductById));
      products.assignAll(fetched); // Display the multiple fetched products
      _showSuccessSnackbar('Success', 'Fetched ${fetched.length} products.');
    } catch (e) {
      _showErrorSnackbar('Error', 'One or more products not found or error fetching: ${e.toString()}');
      products.clear(); // Clear the list on error for multi-ID fetch
    } finally {
      isLoading.value = false;
    }
  }

  // CREATE Product
  void createProduct() async {
    try {
      isLoading.value = true;
      final name = nameController.text.trim();
      final dataString = dataController.text.trim();

      if (name.isEmpty) {
        throw Exception('Product name is required.');
      }

      Map<String, dynamic>? dataMap;
      if (dataString.isNotEmpty) {
        try {
          dataMap = jsonDecode(dataString) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Invalid JSON data. Please check format.');
        }
      }

      final newProduct = await ApiService.createProduct(name, dataMap);
      // After creating, re-fetch all products to update both _allProducts and products
      fetchAllProducts();
      _showSuccessSnackbar('Success', 'Product "${newProduct.name}" created (ID: ${newProduct.id})');
    } catch (e) {
      _showErrorSnackbar('Create Failed', 'Error creating product: ${e.toString()}');
    } finally {
      isLoading.value = false;
      nameController.clear();
      dataController.clear();
      Get.back(); // Close dialog after action
    }
  }

  // UPDATE Product (Full PUT operation)
  void updateProduct(String id) async {
    try {
      isLoading.value = true;
      final name = nameController.text.trim();
      final dataString = dataController.text.trim();

      if (name.isEmpty) {
        throw Exception('Product name is required for update.');
      }

      Map<String, dynamic> dataMap;
      if (dataString.isNotEmpty) {
        try {
          dataMap = jsonDecode(dataString) as Map<String, dynamic>;
        } catch (e) {
          throw Exception('Invalid JSON data. Please check format.');
        }
      } else {
        throw Exception('Product data (JSON) is required for full update (PUT).');
      }

      final updated = await ApiService.updateProduct(id, name, dataMap);
      // After updating, re-fetch all products to update both _allProducts and products
      fetchAllProducts();
      _showSuccessSnackbar('Success', 'Product ID $id updated: ${updated.name}');
    } catch (e) {
      _showErrorSnackbar('Update Failed', 'Error updating product: ${e.toString()}');
    } finally {
      isLoading.value = false;
      nameController.clear();
      dataController.clear();
      Get.back(); // Close dialog after action
    }
  }

  // DELETE Product
  void deleteProduct(String id) async {
    try {
      isLoading.value = true;
      await ApiService.deleteProduct(id);
      // After deleting, re-fetch all products to update both _allProducts and products
      fetchAllProducts();
      _showSuccessSnackbar('Success', 'Product ID $id deleted.');
    } catch (e) {
      _showErrorSnackbar('Delete Failed', 'Error deleting product: ${e.toString()}');
    } finally {
      isLoading.value = false;
      searchController.clear(); // Clear search ID if used in delete dialog
      Get.back(); // Close dialog after action
    }
  }
}