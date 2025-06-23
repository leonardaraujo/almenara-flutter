// products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/product_repository.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../widgets/app_drawer.dart'; // Import the new AppDrawer widget
import '../widgets/product_card.dart'; // Import the ProductCard widget

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});
  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ProductRepository _productRepository = ProductRepository();
  late Stream<List<Product>> _productsStream;
  String _searchQuery = '';
  String? _selectedCategory;
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _productsStream = _productRepository.getProductsStream();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final categories = await _productRepository.getUniqueCategories();
    setState(() {
      _categories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F6F6), // Light Gray
        foregroundColor: const Color(0xFF191919), // Black
        title: const Text('Productos de Pastelería'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.pushNamed(context, '/cart');
                },
              ),
              Positioned(
                right: 4,
                top: 4,
                child: Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    final count = cart.items.values.fold<int>(
                      0,
                      (sum, item) => sum + item.quantity,
                    );
                    return count == 0
                        ? const SizedBox.shrink()
                        : Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0000), // Red
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(currentRoute: '/products'), // Use the reusable AppDrawer
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar productos',
                labelStyle: const TextStyle(color: Color(0xFF959595)), // Dark Gray
                prefixIcon: const Icon(Icons.search, color: Color(0xFF191919)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Color(0xFF191919)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF191919)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Color(0xFF191919)),
                ),
              ),
              style: const TextStyle(color: Color(0xFF191919)),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filtrar por categoría',
                      labelStyle: const TextStyle(color: Color(0xFF959595)), // Dark Gray
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF191919)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(color: Color(0xFF191919)),
                      ),
                    ),
                    value: _selectedCategory,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Todas las categorías'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                  ),
                ),
                if (_selectedCategory != null)
                  IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF191919)),
                    onPressed: () {
                      setState(() {
                        _selectedCategory = null;
                      });
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                final filteredProducts =
                    products.where((product) {
                      final matchesSearch = product.name.toLowerCase().contains(
                        _searchQuery,
                      );
                      final matchesCategory =
                          _selectedCategory == null ||
                          (product.category.toLowerCase() ==
                              _selectedCategory?.toLowerCase());
                      return matchesSearch && matchesCategory;
                    }).toList();
                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No se encontraron productos'),
                        const SizedBox(height: 20),
                        if (_searchQuery.isNotEmpty ||
                            _selectedCategory != null)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = null;
                                _searchController.clear();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF0000), // Red
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Limpiar filtros'),
                          ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}