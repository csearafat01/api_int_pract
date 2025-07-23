import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bindings/product_binding.dart';
import 'screens/product_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialBinding: ProductBinding(), // ✅ required
      home: const ProductListScreen(),
    );

  }
}
