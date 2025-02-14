import 'package:flutter/material.dart';
import 'package:shop_ecommerce/API_Service/products/product_category.dart';
import 'package:shop_ecommerce/Model/product.dart';

class ProductFetchScreen extends StatefulWidget {
  final String categoryKey; // This should be a category name (e.g., 'books', 'clothes')

  const ProductFetchScreen({super.key, required this.categoryKey});

  @override
  // ignore: library_private_types_in_public_api
  _ProductFetchScreenState createState() => _ProductFetchScreenState();
}

class _ProductFetchScreenState extends State<ProductFetchScreen> {
  List<Product> categoryProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductsByCategory();
  }

  Future<void> _fetchProductsByCategory() async {
    try {
      var products = await ProductService().getProductsByCategory(widget.categoryKey);
      setState(() {
        categoryProducts = products;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products found!!!!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category Products')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categoryProducts.isEmpty
              ? const Center(child: Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
              : ListView.builder(
                  itemCount: categoryProducts.length,
                  itemBuilder: (context, index) {
                    final product = categoryProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text('\$${product.price}'),
                      leading: Image.network(product.imageUrl),
                    );
                  },
                ),
    );
  }
}
