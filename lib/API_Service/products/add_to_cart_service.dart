import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_ecommerce/Model/product.dart';

class CartService {
  final String baseUrl = "http://localhost:3006"; // Replace with your API URL

  Future<bool> addToCart(int? productId, int? quantity) async {
    if (productId == null || quantity == null) {
      print('Product ID or quantity is null');
      return false;
    }

    // Check token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null || token.isEmpty) {
      print('Token is missing');
      return false; // Token is missing, user is not authenticated
    }

    final url = Uri.parse('$baseUrl/cart');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'quantity': quantity,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Product added successfully');
        return true;
      } else {
        print('Failed to add product. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding product to cart: $e');
      return false;
    }
  }

  // Method to fetch cart items
  Future<List<Map<String, dynamic>>> getCartItems() async {
    try {
      // Retrieve the authentication token from SharedPreferences or another secure storage
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      // Make the HTTP request with the token in the Authorization header
      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token', // Add the token in the headers
        },
      );

      if (response.statusCode == 200) {
        // Parse the JSON response and return it as a list of maps
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
      print("Error fetching cart data: $e");
      rethrow;
    }
  }

// Function to update the quantity of a cart item
  Future<bool> updateCartItemQuantity(int productId, int newQuantity) async {
    try {
      // Retrieve the authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {
          'Authorization': 'Bearer $token', // Include the token in the headers
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'quantity': newQuantity,
        }),
      );

      if (response.statusCode == 200) {
        // Success: cart item quantity updated
        return true;
      } else {
        // Log the error response
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
      return false;
    }
  }

// Function to remove a product from the cart
  Future<bool> removeProduct(int productId) async {
    try {
      // Retrieve the authentication token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      // Make the HTTP request to remove the product with the token in the Authorization header
      final response = await http.delete(
        Uri.parse('$baseUrl/cart/$productId'),
        headers: {
          'Authorization': 'Bearer $token', // Add the token in the headers
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success: product removed from cart
        return true;
      } else {
        // Failed to remove product
        return false;
      }
    } catch (e) {
      print('Error removing product: $e');
      return false;
    }
  }

  Future<bool> toggleFavorite(int productId, bool isFavorite) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');

      if (token == null) {
        throw Exception('User is not authenticated');
      }

      var response = await http.post(
        Uri.parse('$baseUrl/toggle_favorite'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'productId': productId, 'isFavorite': isFavorite}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('Response: $responseData');
        return true;
      } else {
        print('Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<List<Product>> getFavoriteProducts() async {
    // Get the authentication token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token == null) {
      throw Exception('User not authenticated');
    }

    // Make the API call with the Authorization header
    final response = await http.get(
      Uri.parse('$baseUrl/get_favorite_products'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load favorite products: ${response.statusCode}');
    }
  }
}
