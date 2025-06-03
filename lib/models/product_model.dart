import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  pan,
  galleta,
  dulces,
}


class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
  });

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num).toDouble(),
      category: _parseCategory(data['category']),
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  static ProductCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pan':
        return ProductCategory.pan;
      case 'galleta':
        return ProductCategory.galleta;
      case 'dulces':
        return ProductCategory.dulces;

      default:
        return ProductCategory.pan;
    }
  }

  String get categoryName {
    switch (category) {
      case ProductCategory.pan:
        return 'pan';
      case ProductCategory.galleta:
        return 'galleta';
      case ProductCategory.dulces:
        return 'dulces';
    }
  }
}