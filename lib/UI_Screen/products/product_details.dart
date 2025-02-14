import 'package:flutter/material.dart';
import 'package:shop_ecommerce/Model/product.dart'; // Import the Product model
import 'package:shop_ecommerce/API_Service/products/add_to_cart_service.dart'; // Import the cart service

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  ProductDetailsPage({super.key, required this.product});

  // Create an instance of CartService
  final CartService cartService = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Handle favorite action here
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Product Image
              Center(
                child: Image.network(
                  product.imageUrl.isNotEmpty
                      ? product.imageUrl
                      : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  height: 250,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
              ),
              const SizedBox(height: 16),
              // Product Name and Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 18),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Divider below the product name
              const Divider(),
              const SizedBox(height: 8),
              // Product Details section
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(product.description),
              ),
              const SizedBox(height: 16),
              // Price and Add to Cart button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      bool isAdded = await cartService.addToCart(product.id, 1);
                      if (isAdded) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to add to cart')),
                        );
                      }
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
