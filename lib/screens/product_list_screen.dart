// lib/screens/product_list_screen.dart
import 'dart:convert'; // Required for jsonEncode/jsonDecode
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import '../controllers/product_controller.dart'; // Import your controller
import '../models/product.dart'; // Still need Product model for displaying data

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Inject the ProductController into the widget tree.
  // Using Get.put() here ensures it's initialized when this screen is built
  final ProductController productController = Get.put(ProductController());

  // --- Dialogs for User Input (use Get.dialog and Get.back()) ---

  // Dialog for POST (Create) operation
  Future<void> _showCreateProductDialog() async {
    productController.nameController.clear();
    productController.dataController.clear();

    return Get.dialog(
      AlertDialog(
        title: const Text('Create New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productController.nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: productController.dataController,
                decoration: const InputDecoration(
                  labelText: 'Product Data (JSON String, optional)',
                  hintText: 'e.g., {"color": "blue", "size": "M"}',
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            // The controller handles closing the dialog, etc.
            onPressed: productController.createProduct,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  // Dialog for Update operation (maps to PUT in ApiService)
  // This dialog will be pre-filled if opened from a list item's edit button
  Future<void> _showUpdateProductDialog(String? productId) async {
    // Clear controllers if not pre-filling from an item
    if (productId == null) {
      productController.searchController
          .clear(); // Using searchController for ID here for manual input
      productController.nameController.clear();
      productController.dataController.clear();
    } else {
      // If called from list item's edit button, the controllers are already pre-filled
      // by the IconButton's onPressed handler.
    }

    return Get.dialog(
      AlertDialog(
        title: const Text('Update Product (PUT)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productController.searchController,
                // Using searchController for ID input
                decoration: const InputDecoration(
                  labelText: 'Product ID to Update',
                ),
                keyboardType: TextInputType.text,
                readOnly: productId != null, // Make ID read-only if pre-filled
              ),
              TextField(
                controller: productController.nameController,
                decoration: const InputDecoration(
                  labelText: 'New Product Name',
                ),
              ),
              TextField(
                controller: productController.dataController,
                decoration: const InputDecoration(
                  labelText: 'New Product Data (JSON String)',
                  hintText: 'e.g., {"color": "red", "capacity": "256 GB"}',
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final id = productController.searchController.text.trim();
              if (id.isNotEmpty) {
                // The controller handles closing the dialog, etc.
                productController.updateProduct(id);
              } else {
                Get.snackbar(
                  'Input Error',
                  'Product ID cannot be empty.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Dialog for DELETE operation
  Future<void> _showDeleteProductDialog(String? productId) async {
    if (productId == null) {
      productController.searchController.clear(); // Clear for manual ID entry
    } else {
      productController.searchController.text =
          productId; // Pre-fill ID if called from list item
    }

    return Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: TextField(
          controller: productController.searchController,
          // Using searchController for ID input
          decoration: const InputDecoration(labelText: 'Product ID to Delete'),
          keyboardType: TextInputType.text,
          readOnly: productId != null, // Make ID read-only if pre-filled
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final id = productController.searchController.text.trim();
              if (id.isNotEmpty) {
                // The controller handles closing the dialog, etc.
                productController.deleteProduct(id);
              } else {
                Get.snackbar(
                  'Input Error',
                  'Product ID cannot be empty for DELETE.',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API '),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: productController.isLoading.value
                  ? null
                  : productController.fetchAllProducts,
              tooltip: 'Refresh All Products',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search by ID section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: productController.searchController,
                    // Shared text field for search IDs
                    decoration: const InputDecoration(
                      labelText: 'Search by ID(s)',
                      hintText: 'e.g., 7 (single) or 1,2,3 (multi)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: productController.isLoading.value
                      ? null
                      : productController.fetchProductById,
                  child: const Text('Get Single'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: productController.isLoading.value
                      ? null
                      : productController.fetchProductsByMultipleIds,
                  child: const Text('Get Multi'),
                ),
              ],
            ),
          ),
          const Divider(),

          // CRUD Action Buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                ElevatedButton.icon(
                  onPressed: _showCreateProductDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('POST (Create)'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUpdateProductDialog(null),
                  // Call with null to manually enter ID
                  icon: const Icon(Icons.edit),
                  label: const Text('PUT (Update)'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteProductDialog(null),
                  // Call with null to manually enter ID
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('DELETE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Product List Display Section
          Obx(() {
            if (productController.isLoading.value &&
                productController.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (productController.products.isEmpty) {
              return const Center(
                child: Text('No products found. Use search or create one!'),
              );
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID: ${product.id}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (product.data != null &&
                                product
                                    .data!
                                    .isNotEmpty) // Check if data is not empty
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  // Use `jsonEncode` for pretty printing Map data
                                  'Details: ${jsonEncode(product.data)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_note,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                // Pre-fill controllers for editing
                                productController.searchController.text =
                                    product.id;
                                productController.nameController.text =
                                    product.name;
                                productController.dataController.text =
                                    jsonEncode(product.data ?? {});
                                _showUpdateProductDialog(
                                  product.id,
                                ); // Pass ID to pre-fill in dialog
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteProductDialog(
                                  product.id,
                                ); // Pass ID to pre-fill in dialog
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
