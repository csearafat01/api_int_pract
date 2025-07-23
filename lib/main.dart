// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'screens/product_list_screen.dart'; // Import the UI screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,// Changed from MaterialApp to GetMaterialApp for GetX
      title: 'Flutter API Integration Demo (GetX)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.blueGrey,
          actionTextColor: Colors.white,
        ),
      ),
      home: const ProductListScreen(), // Set the ProductListScreen as the home screen
    );
  }
}