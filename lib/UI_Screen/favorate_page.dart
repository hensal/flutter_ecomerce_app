import 'package:flutter/material.dart';
import 'package:shop_ecommerce/API_Service/products/add_to_cart_service.dart';
import 'package:shop_ecommerce/Model/product.dart';
import 'package:shop_ecommerce/UI_Screen/button_nav.dart';

// Favourite Page
class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  // List to hold favorite products
  List<Product> favoriteProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchFavoriteProducts();
  }

  // Fetch favorite products
  Future<void> _fetchFavoriteProducts() async {
    List<Product> products = await CartService().getFavoriteProducts();

    // Debugging API response
    for (var product in products) {
      print(
          'Product ID: ${product.id}, Name: ${product.name}, Image: ${product.imageUrl}');
    }

    setState(() {
      favoriteProducts = products;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const NavButtonPage()), // Navigate and replace the current page
            );
          },
        ),
        title: const Text('My Favorites'),
      ),
      body: favoriteProducts.isEmpty
          ? const Center(
              child: Text(
                  'No favorite products found.')) // Show message if no favorites
          : ListView.builder(
              itemCount: favoriteProducts.length,
              itemBuilder: (context, index) {
                final product = favoriteProducts[index];
                return Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Image on the left
                      Image.network(
                        product.imageUrl.isNotEmpty
                            ? product.imageUrl
                            : 'https://via.placeholder.com/150',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      // Centered product name and rating
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.yellow, size: 16),
                                Text(
                                  product.rating.toString(),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Favorite icon on the right
                      IconButton(
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product.isFavorite ? Colors.red : Colors.grey,
                          size: 30,
                        ),
                        onPressed: () async {
                          // Toggle favorite status
                          bool success = await CartService().toggleFavorite(
                            product.id,
                            !product.isFavorite, // Toggle the favorite status
                          );

                          if (success) {
                            setState(() {
                              product.isFavorite = !product.isFavorite;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Failed to update favorite status')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
