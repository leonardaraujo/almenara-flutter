import 'package:cloud_firestore/cloud_firestore.dart';
import 'cartService.dart';

class PurchaseService {
  final CollectionReference _purchases =
      FirebaseFirestore.instance.collection('compras');

  Future<void> createPurchase(String userId, List<CartItem> items) async {
    await _purchases.add({
      'usuarioId': userId,
      'productos': items
          .map((e) => {'id': e.id, 'cantidad': e.cantidad})
          .toList(),
      'fechaHora': FieldValue.serverTimestamp(),
    });
  }
}
