// lib/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  final String? currentRoute; // Opcional: para resaltar la opción activa

  const AppDrawer({super.key, this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF191919)), // Negro
            child: Text(
              'Menú',
              style: TextStyle(
                color: Color(0xFFF6F6F6), // Blanco suave
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(
            context: context,
            route: '/products',
            icon: Icons.shopping_cart,
            label: 'Productos',
            isActive: currentRoute == '/products',
          ),
          _buildDrawerItem(
            context: context,
            route: '/purchase_history',
            icon: Icons.history,
            label: 'Historial de compras',
            isActive: currentRoute == '/purchase_history',
          ),
          _buildDrawerItem(
            context: context,
            route: '/profile',
            icon: Icons.person,
            label: 'Perfil',
            isActive: currentRoute == '/profile',
          ),
          _buildDrawerItem(
            context: context,
            route: '/login',
            icon: Icons.logout,
            label: 'Cerrar sesión',
            isActive: false,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required String route,
    required IconData icon,
    required String label,
    required bool isActive,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.red : null),
      title: Text(
        label,
        style: TextStyle(
          color: isLogout ? const Color(0xFF191919) : null,
          fontWeight: isActive ? FontWeight.bold : null,
        ),
      ),
      onTap: () async {
        if (isLogout) {
          await FirebaseAuth.instance.signOut();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        } else {
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, route);
          }
        }
      },
    );
  }
}