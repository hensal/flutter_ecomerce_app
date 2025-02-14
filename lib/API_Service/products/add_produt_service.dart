import 'dart:convert';
import 'package:http/http.dart' as http;

// In your ProductService class
class ProductService {
  Future<bool> submitProduct(Map<String, dynamic> product) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3006/add-product'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(product),
      );

      if (response.statusCode == 201) {
        // Product added successfully
        return true;
      } else {
        // Return the error message from the API
        throw Exception('Failed to add product: ${response.body}');
      }
    } catch (e) {
      // Catch any other errors (e.g., network issues) and throw them
      throw Exception('Failed to add product: $e');
    }
  }
}

