import 'package:flutter/material.dart';
import 'package:shop_ecommerce/API_Service/products/add_to_cart_service.dart';
import 'package:shop_ecommerce/API_Service/users/login_check.dart';
import 'package:shop_ecommerce/Model/product.dart';
import 'package:shop_ecommerce/UI_Screen/authentication/sign_in.dart';
import 'package:shop_ecommerce/UI_Screen/products/product_details.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final CartService cartService = CartService();
  final AuthService authService = AuthService();
  bool isFavorite = false;
  int quantity = 1;

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

  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> checkUserAndProceed({
    required BuildContext context,
    required Future<void> Function() onAuthenticated,
  }) async {
    bool loggedIn = await checkLoginStatus();

    if (!loggedIn) {
      // If not logged in, navigate to the login page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      // If logged in, proceed with the action
      await onAuthenticated();
    }
  }

  Future<void> _saveFavoriteStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save favorite status if necessary, this depends on your app's requirements
    prefs.setBool('favorite_${widget.product.id}', status);
  }

  Future<bool> checkLoginStatus1() async {
    // Check if the user is logged in (this example uses SharedPreferences)
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ??
        false; // Change this based on your actual login check logic
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: widget.product),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Image
                Image.network(
                  widget.product.imageUrl.isNotEmpty
                      ? widget.product.imageUrl
                      : 'https://via.placeholder.com/150',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
                // Favorite emoji (Top-left)
                Positioned(
                  top: 8,
                  left: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 30,
                    ),
                    onPressed: () async {
                      // Use the checkUserAndProceed function to handle login and proceed with favorite action
                      await checkUserAndProceed(
                        context: context,
                        onAuthenticated: () async {
                          setState(() {
                            // Toggle the favorite status
                            isFavorite = !isFavorite;
                          });

                          // Save the favorite status to SharedPreferences
                          await _saveFavoriteStatus(isFavorite);

                          // Update the favorite status in the database
                          bool success = await cartService.toggleFavorite(
                              widget.product.id, isFavorite);

                          if (!success) {
                            // Handle failure case
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Failed to update favorite status')),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
                // Add to Cart button (Top-right)
                Positioned(
                  top: 8,
                  right: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      print('Product ID: ${widget.product.id}');
                      print('Quantity: $quantity');

                      bool loggedIn = await checkLoginStatus1();
                      if (!loggedIn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      } else {
                        // Directly add the product to the cart
                        bool isAdded = await cartService.addToCart(
                            widget.product.id, quantity);

                        if (isAdded) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Product added to cart')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Failed to add product to cart')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.all(8),
                    ),
                    child: const Icon(Icons.add_shopping_cart, size: 20),
                  ),
                ),
              ],
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product name
                  Text(
                    widget.product.name, // Add a fallback if name is null
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  // Row for rating icon and number
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.yellow, size: 16),
                      Text(
                        widget.product.rating.toString(), // Add a fallback if rating is null
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Price Text
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Text(
                '\$${(widget.product.price).toStringAsFixed(2)}', // Add a fallback if price is null
              ),
            ),
          ],
        ),
      ),
    );
  }
}
