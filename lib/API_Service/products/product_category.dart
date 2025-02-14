import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_ecommerce/Model/product.dart';

class ProductService {
  // URL for your API endpoint
  final String baseUrl = 'http://localhost:3006/api/products';

  // Function to get products by category name (string)
  Future<List<Product>> getProductsByCategory(String categoryKey) async {
    final response = await http.get(Uri.parse('$baseUrl?categoryId=$categoryKey'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      // Return an empty list if no products are found
      return data.isEmpty ? [] : data.map((item) => Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
