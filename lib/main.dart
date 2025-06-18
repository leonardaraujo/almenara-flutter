import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'screens/splash_screen.dart'; // 👈 Añadido

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda de Productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
        ).copyWith(secondary: Colors.purpleAccent),
      ),
      initialRoute: '/',
      routes: {
        '/':
            (_) =>
                const SplashScreen(), // 👈 Splash screen como entrada inicial
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/products': (_) => const ProductsScreen(),
        '/cart': (_) => const CartScreen(),
        '/product_detail': (_) => const ProductDetailScreen(),
      },
    );
  }
}
