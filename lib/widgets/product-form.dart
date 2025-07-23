/*
import 'package:flutter/material.dart';

class ProductForm extends StatefulWidget {
  final String? initialName;
  final Map<String, dynamic>? initialData;
  final void Function(String, Map<String, dynamic>) onSubmit;

  const ProductForm({
    this.initialName,
    this.initialData,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _nameController = TextEditingController();
  final _dataController = TextEditingController();

  @override
  void initState() {
    _nameController.text = widget.initialName ?? '';
    _dataController.text = widget.initialData?.toString() ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _dataController,
            decoration: const InputDecoration(labelText: "Data (JSON-like)"),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final name = _nameController.text;
              final data = _dataController.text;
              widget.onSubmit(name, {"info": data});
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}
*/
