import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    double total = cartItems.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF6F6F6), // Light Gray
          foregroundColor: const Color(0xFF191919), // Black
          title: const Text(
            'Carrito de Compras',
            style: TextStyle(color: Color(0xFF191919)), // Black
          ),
        ),
        body: cartItems.isEmpty
            ? Center(
                child: Text(
                  'Tu carrito está vacío',
                  style: const TextStyle(color: Color(0xFF191919)), // Black
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          color: const Color(0xFFF6F6F6), // Light Gray
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFE5E7EB), // Very Light Gray
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              item.product.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191919), // Black
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Precio: S/.${item.product.price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF959595), // Dark Gray
                                  ),
                                ),
                                Text(
                                  'Cantidad: ${item.quantity}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF959595), // Dark Gray
                                  ),
                                ),
                                Text(
                                  'Subtotal: S/.${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF959595), // Dark Gray
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Color(0xFF959595), // Dark Gray
                              ),
                              onPressed: () {
                                cart.removeFromCart(item.product.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Total: S/.${total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191919), // Black
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (cartItems.isEmpty) {
                              _showMessage('Tu carrito está vacío');
                              return;
                            }
                            _showPurchaseConfirmationDialog(context, cart);
                          },
                          icon: const Icon(Icons.payment, color: Colors.white),
                          label: const Text(
                            'Proceder al pago',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000), // Red
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () => cart.clearCart(),
                          icon: const Icon(Icons.delete_forever, color: Colors.white),
                          label: const Text(
                            'Vaciar carrito',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000), // Red
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showMessage(String message) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showPurchaseConfirmationDialog(
      BuildContext context, CartProvider cart) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showMessage('Usuario no autenticado');
      return;
    }

    final cartItems = cart.items.values.toList();
    final purchaseData = {
      'items': cartItems.map((item) => _cartItemToMap(item)).toList(),
      'total': cartItems.fold(0.0,
          (sum, item) => sum + (item.product.price * item.quantity)),
      'timestamp': FieldValue.serverTimestamp(),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar compra'),
          content: const Text('¿Estás seguro de que deseas realizar esta compra?'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('purchases')
                      .add(purchaseData);

                  // Vaciar el carrito
                  cart.clearCart();

                  _showMessage('Compra realizada con éxito');
                } catch (e) {
                  _showMessage('Error al procesar la compra: $e');
                }
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> _cartItemToMap(CartItem item) {
    return {
      'productId': item.product.id,
      'name': item.product.name,
      'price': item.product.price,
      'quantity': item.quantity,
      'imageUrl': item.product.imageUrl,
      'date': DateTime.now().toIso8601String(),
    };
  }
}