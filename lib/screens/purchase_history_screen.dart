import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart'; // 👈 Importa tu AppDrawer reutilizable

class PurchaseHistoryScreen extends StatelessWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Usuario no autenticado',
            style: TextStyle(color: Color(0xFF191919)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Compras'),
        backgroundColor: const Color(0xFFF6F6F6), // Light Gray
        foregroundColor: const Color(0xFF191919), // Black
      ),
      drawer: const AppDrawer(currentRoute: '/purchase_history'), // 👈 Drawer con ruta actual
      backgroundColor: const Color(0xFFF6F6F6), // Light Gray
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('purchases')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No tienes compras registradas.',
                style: TextStyle(color: Color(0xFF191919)),
              ),
            );
          }

          final purchases = snapshot.data!.docs;

          return ListView.builder(
            itemCount: purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchases[index].data() as Map<String, dynamic>;
              final items = List<Map<String, dynamic>>.from(purchase['items']);
              final total = purchase['total'];
              final timestamp = (purchase['timestamp'] as Timestamp).toDate();

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                color: const Color(0xFFE5E7EB), // Very Light Gray
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDate(timestamp),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF191919), // Black
                            ),
                          ),
                          Text(
                            'Total: S/.${total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF0000), // Red
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'],
                                  style: const TextStyle(
                                    color: Color(0xFF191919), // Black
                                  ),
                                ),
                              ),
                              Text(
                                'x${item['quantity']}',
                                style: const TextStyle(
                                  color: Color(0xFF959595), // Dark Gray
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'S/.${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF191919), // Black
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(
                        color: Color(0xFFE5E7EB), // Very Light Gray
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}