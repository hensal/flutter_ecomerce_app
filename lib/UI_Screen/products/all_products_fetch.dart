import 'package:flutter/material.dart';
import 'package:shop_ecommerce/Model/product.dart';
import 'package:shop_ecommerce/API_Service/products/fetch_product.dart';
import 'package:shop_ecommerce/UI_Screen/products/product.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _products = _productService.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _products,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Log the error in the terminal
          debugPrint('Error fetching products: ${snapshot.error}');
          return const Center(
            child: Text('No products found'),
            //child: Text('Error: ${snapshot.error}'),
            //THIS WILL GIVE THE EXACT ERROR OF THE BACKEND
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No products found'));
        } else {
          final products = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3 / 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          );
        }
      },
    );
  }
}
