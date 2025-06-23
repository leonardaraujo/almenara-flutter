// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart'; // Ajusta con tu nombre de app

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product_detail', arguments: product);
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: const Color(0xFFF6F6F6), // Light Gray
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5E7EB), // Very Light Gray
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category.isNotEmpty)
                    Chip(
                      label: Text(
                        product.category,
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: const Color(0xFFFF0000), // Red
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                    ),
                  const SizedBox(height: 12),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919), // Black
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF959595), // Dark Gray
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'S/.${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191919), // Black
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
}