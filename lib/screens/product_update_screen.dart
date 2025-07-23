// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/product_controller.dart';
// import '../models/product.dart';
// import '../widgets/product-form.dart';
//
// class ProductUpdateScreen extends StatelessWidget {
//   final Product product;
//   final ProductController controller = Get.find();
//
//   ProductUpdateScreen({required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Update Product")),
//       body: ProductForm(
//         initialName: product.name,
//         initialData: product.data,
//         onSubmit: (name, data) {
//           controller.updateProduct(product.id, Product(id: product.id, name: name, data: data));
//         },
//       ),
//     );
//   }
// }
