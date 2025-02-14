import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_ecommerce/Model/product.dart';

class ProductService {
  final String baseUrl = 'http://localhost:3006'; // Base URL.

  // Fetch Products Method
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Map JSON to List<Product>
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch products');
      }
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }
}
