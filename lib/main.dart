import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeFirebase();
  
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Intenta inicializar Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "TU_API_KEY",
        appId: "TU_APP_ID",
        messagingSenderId: "TU_MESSAGING_SENDER_ID",
        projectId: "TU_PROJECT_ID",
        // Otros parámetros según sea necesario
      ),
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Firebase ya está inicializado, podemos continuar
      return;
    }
    // Para otros errores de Firebase, los relanzamos
    rethrow;
  } catch (e) {
    // Manejo de otros tipos de errores
    print('Error inicializando Firebase: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda de Productos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductsScreen(),
    );
  }
}