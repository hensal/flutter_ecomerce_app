class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final double rating;
  bool isFavorite;  // Mutable field

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.isFavorite,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'No Name',
      description: json['description'] ?? 'No Description',
      price: (json['price'] != null)
          ? (json['price'] is String
              ? double.tryParse(json['price']) ?? 0.0
              : (json['price'] as num).toDouble())
          : 0.0,
      imageUrl: json['image_url'] ?? '',
      rating: (json['rating'] != null)
          ? (json['rating'] is String
              ? double.tryParse(json['rating']) ?? 0.0
              : (json['rating'] as num).toDouble())
          : 0.0,
      // Use null-aware operator to set default value if favorite is null
      isFavorite: json['favorite'] as bool? ?? false,
    );
  }
}
