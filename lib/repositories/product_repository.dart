import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Product>> getProductsStream() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'category': product.category, // Cambiado para guardar el string directamente
      'imageUrl': product.imageUrl,
    });
  }

  Future<List<Product>> getProductsOnce() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  }

  Future<List<String>> getUniqueCategories() async {
    final snapshot = await _firestore.collection('products').get();
    final categories = snapshot.docs
        .map((doc) => doc['category'] as String? ?? '') // Obtener categoría como string
        .where((category) => category.isNotEmpty) // Filtrar categorías vacías
        .toSet() // Eliminar duplicados
        .toList();
    
    categories.sort(); // Ordenar alfabéticamente
    return categories;
  }
}