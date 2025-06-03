import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  pan,
  galleta,
  dulces,
  helados,
  kekes, // Nueva categoría
  minimaria, // Nueva categoría
  porciones, // Nueva categoría
  tortas, // Nueva categoría
  decoracion, // Nueva categoría
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
      case 'helados':
        return ProductCategory.helados;
      case 'kekes': // Nueva categoría
        return ProductCategory.kekes;
      case 'minimaria': // Nueva categoría
        return ProductCategory.minimaria;
      case 'porciones': // Nueva categoría
        return ProductCategory.porciones;
      case 'tortas': // Nueva categoría
        return ProductCategory.tortas;
      case 'decoracion': // Nueva categoría
        return ProductCategory.decoracion;
      default:
        return ProductCategory.pan; // Valor por defecto
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
      case ProductCategory.helados:
        return 'helados';
      case ProductCategory.kekes: // Nueva categoría
        return 'kekes';
      case ProductCategory.minimaria: // Nueva categoría
        return 'minimaria';
      case ProductCategory.porciones: // Nueva categoría
        return 'porciones';
      case ProductCategory.tortas: // Nueva categoría
        return 'tortas';
      case ProductCategory.decoracion: // Nueva categoría
        return 'decoracion';
    }
  }
}