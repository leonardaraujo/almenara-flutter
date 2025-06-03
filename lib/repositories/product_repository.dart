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
      'category': product.category.toString().split('.').last,
      'imageUrl': product.imageUrl,
    });
  }
  Future<List<Product>> getProductsOnce() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  }
}