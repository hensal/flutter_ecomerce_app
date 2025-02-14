import 'package:flutter/material.dart';
import 'package:shop_ecommerce/API_Service/products/add_to_cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> cartItems;

  @override
  void initState() {
    super.initState();
    cartItems =
        CartService().getCartItems(); // Fetch cart items when page loads
  }

  // Function to handle increasing/decreasing quantity based on increment value
  void updateQuantity(int productId, int newQuantity) async {
    if (newQuantity < 1) return; // Ensure quantity doesn't go below 1

    bool success =
        await CartService().updateCartItemQuantity(productId, newQuantity);
    if (success) {
      setState(() {
        // Refresh cart items after update
        cartItems = CartService().getCartItems();
      });
    } else {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update quantity')),
      );
    }
  }

  // Function to handle removing a product from the cart
  void removeProduct(int productId) async {
    bool success = await CartService().removeProduct(productId);
    if (success) {
      setState(() {
        cartItems =
            CartService().getCartItems(); // Refresh cart items after removal
      });
    } else {
      // Handle error (e.g., show a snackbar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to remove product')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          } else {
            double totalAmount = 0;

            // Calculate total amount of selected products
            for (var cartItem in snapshot.data!) {
              double price =
                  double.tryParse(cartItem['price'].toString()) ?? 0.0;
              int quantity = cartItem['quantity'] ?? 1;
              totalAmount +=
                  price * quantity; // Corrected total amount calculation
            }

            return Column(
              children: [
                // Cart items
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final cartItem = snapshot.data![index];

                      double price =
                          double.tryParse(cartItem['price'].toString()) ?? 0.0;
                      int quantity = cartItem['quantity'] ?? 1;
                      double totalPrice = price *
                          quantity; // Recalculate total price for each item

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.black,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Product image
                              Image.network(
                                cartItem['image_url'] ??
                                    'https://via.placeholder.com/150',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              // Product details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          cartItem['name'] ?? 'Product Name',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => removeProduct(
                                              cartItem['product_id']),
                                        ),
                                      ],
                                    ),
                                    // Price section
                                    Text(
                                        'Price: \$${price.toStringAsFixed(2)}'),
                                    Row(
                                      children: [
                                        Text('Quantity: $quantity'),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.remove_circle_outline),
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  updateQuantity(
                                                      cartItem['product_id'],
                                                      quantity - 1);
                                                }
                                              },
                                            ),
                                            Text('$quantity'),
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.add_circle_outline),
                                              onPressed: () {
                                                updateQuantity(
                                                    cartItem['product_id'],
                                                    quantity + 1);
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // Display updated total price
                                    Text(
                                        'Total: \$${totalPrice.toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Total Price at the bottom
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('\$${totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                // Checkout button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle checkout functionality
                    },
                    child: const Text('Checkout'),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
