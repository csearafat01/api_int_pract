// lib/screens/product_list_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductController productController = Get.put(ProductController());

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  // --- Dialogs for User Input ---
  Future<void> _showCreateProductDialog() async {
    _nameController.clear();
    _dataController.clear();
    return Get.dialog(
      AlertDialog(
        title: const Text('Create New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: _dataController,
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
            onPressed: () {
              Get.back();
              _handleCreateProduct();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateProductPutDialog() async {
    _idController.clear();
    _nameController.clear();
    _dataController.clear();
    return Get.dialog(
      AlertDialog(
        title: const Text('Update Product (PUT)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Product ID to Update'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'New Product Name (Full)'),
              ),
              TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'New Product Data (Full JSON String)',
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
              Get.back();
              _handleUpdateProductPut();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUpdateProductPatchDialog() async {
    _idController.clear();
    _nameController.clear();
    _dataController.clear();
    return Get.dialog(
      AlertDialog(
        title: const Text('Partially Update Product (PATCH)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Product ID to Patch'),
                keyboardType: TextInputType.text,
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'New Product Name (Optional)',
                  hintText: 'Leave empty to not change name',
                ),
              ),
              TextField(
                controller: _dataController,
                decoration: const InputDecoration(
                  labelText: 'New Product Data (Partial JSON String, optional)',
                  hintText: 'e.g., {"color": "yellow"}',
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
              Get.back();
              _handleUpdateProductPatch();
            },
            child: const Text('Patch'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteProductDialog() async {
    _idController.clear();
    return Get.dialog(
      AlertDialog(
        title: const Text('Delete Product'),
        content: TextField(
          controller: _idController,
          decoration: const InputDecoration(labelText: 'Product ID to Delete'),
          keyboardType: TextInputType.text,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _handleDeleteProduct();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- API Call Handlers (call controller methods, controller handles snackbars) ---

  void _handleCreateProduct() {
    final name = _nameController.text.trim();
    final dataString = _dataController.text.trim();
    Map<String, dynamic>? data;

    if (name.isEmpty) {
      Get.snackbar('Input Error', 'Product name cannot be empty.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (dataString.isNotEmpty) {
      try {
        data = jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        Get.snackbar('Input Error', 'Invalid JSON data. Please check format.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }
    productController.createProduct(name, data: data);
  }

  void _handleUpdateProductPut() {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final dataString = _dataController.text.trim();
    Map<String, dynamic> data;

    if (id.isEmpty || name.isEmpty || dataString.isEmpty) {
      Get.snackbar('Input Error', 'ID, Name, and Data cannot be empty for PUT.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      data = jsonDecode(dataString) as Map<String, dynamic>;
    } catch (e) {
      Get.snackbar('Input Error', 'Invalid JSON data for PUT. Please check format.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    productController.updateProductPut(id, name, data);
  }

  void _handleUpdateProductPatch() {
    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final dataString = _dataController.text.trim();
    Map<String, dynamic>? data;

    if (id.isEmpty) {
      Get.snackbar('Input Error', 'Product ID cannot be empty for PATCH.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (dataString.isNotEmpty) {
      try {
        data = jsonDecode(dataString) as Map<String, dynamic>;
      } catch (e) {
        Get.snackbar('Input Error', 'Invalid JSON data for PATCH. Please check format.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
    }

    if (name.isEmpty && data == null) {
      Get.snackbar('Input Error', 'Either Name or Data must be provided for PATCH.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    productController.updateProductPatch(id, name: name.isNotEmpty ? name : null, data: data);
  }

  void _handleDeleteProduct() {
    final id = _idController.text.trim();
    if (id.isEmpty) {
      Get.snackbar('Input Error', 'Product ID cannot be empty for DELETE.', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    productController.deleteProduct(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Demo (GetX)'),
        centerTitle: true,
        actions: [
          Obx(() =>
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: productController.isLoading.value ? null : productController.fetchProducts,
                tooltip: 'Refresh Products List',
              ),
          ),
        ],
      ),
      body: Column(
        children: [
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
                  onPressed: _showUpdateProductPutDialog,
                  icon: const Icon(Icons.edit),
                  label: const Text('PUT (Update)'),
                ),
                ElevatedButton.icon(
                  onPressed: _showUpdateProductPatchDialog,
                  icon: const Icon(Icons.compare_arrows),
                  label: const Text('PATCH (Update)'),
                ),
                ElevatedButton.icon(
                  onPressed: _showDeleteProductDialog,
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

          Obx(() {
            if (productController.isLoading.value && productController.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (productController.errorMessage.isNotEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    productController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              );
            } else if (productController.products.isEmpty) {
              return const Center(child: Text('No products found. Create one!'));
            } else {
              return Expanded(
                child: ListView.builder(
                  itemCount: productController.products.length,
                  itemBuilder: (context, index) {
                    final product = productController.products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${product.id}', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                            if (product.data != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'Details: ${product.data}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_note, color: Colors.blue),
                              onPressed: () {
                                _idController.text = product.id;
                                _nameController.text = product.name;
                                _dataController.text = jsonEncode(product.data ?? {});
                                _showUpdateProductPutDialog();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _idController.text = product.id;
                                _showDeleteProductDialog();
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