import 'package:flutter/material.dart';
import 'package:shop_ecommerce/UI_Screen/products/category_product_fetch.dart';

class CategoryItemWidget extends StatelessWidget {
  final IconData icon;
  final String label; 
  final String categoryName; 

  const CategoryItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.categoryName, // Change to categoryName
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the ProductFetchScreen when tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductFetchScreen(categoryKey: categoryName), 
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),          
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

