import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // 👈 Importa la biblioteca para usar File
import 'dart:convert'; // 👈 Importa la biblioteca para usar base64Encode
import 'package:image_picker/image_picker.dart'; // 👈 Importa la biblioteca para usar ImagePicker
import 'package:image/image.dart' as img; // 👈 Importa la biblioteca para manipular imágenes
import '../widgets/app_drawer.dart'; // 👈 Importa tu AppDrawer

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? imagenBase64;
  File? imagenSeleccionada;
  String? nombre;
  String? telefono;
  String? email;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    obtenerDatosPerfil();
  }

  Future<void> obtenerDatosPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          setState(() {
            imagenBase64 = data['imgProfile'];
            nombre = data['name'] ?? user.displayName;
            telefono = data['phone'];
            email = data['email'] ?? user.email;
          });
        }
      } else {
        final userEmail = user.email ?? '';
        final userName = user.displayName ?? 'Usuario';
        await docRef.set({
          'email': userEmail,
          'name': userName,
          'phone': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        setState(() {
          email = userEmail;
          nombre = userName;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> seleccionarImagen(ImageSource source) async {
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    setState(() {
      imagenSeleccionada = File(picked.path);
    });
  }

  Future<void> subirImagen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || imagenSeleccionada == null) return;

    final loadingOverlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF0000)),
        ),
      ),
    );
    Overlay.of(context).insert(loadingOverlay);

    try {
      final bytes = await imagenSeleccionada!.readAsBytes();
      var image = img.decodeImage(bytes);
      if (image == null) throw Exception('No se pudo leer la imagen.');

      if (image.width > 500 || image.height > 500) {
        image = img.copyResize(image, width: 500);
      }

      final compressedBytes = img.encodeJpg(image, quality: 65);
      final base64Image = base64Encode(compressedBytes);

      if (base64Image.length > 700000) {
        throw Exception('La imagen es demasiado grande.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'imgProfile': base64Image,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        imagenBase64 = base64Image;
        imagenSeleccionada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Imagen de perfil actualizada exitosamente!'),
          backgroundColor: Color(0xFF191919),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      loadingOverlay.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageWidget;
    if (imagenSeleccionada != null) {
      imageWidget = FileImage(imagenSeleccionada!);
    } else if (imagenBase64 != null && imagenBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(imagenBase64!);
        imageWidget = MemoryImage(bytes);
      } catch (e) {
        imageWidget = null;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF191919),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      drawer: const AppDrawer(currentRoute: '/profile'), // 👈 Drawer con ruta actual
      body: RefreshIndicator(
        onRefresh: obtenerDatosPerfil,
        color: const Color(0xFFFF0000),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE5E7EB),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: imageWidget,
                  backgroundColor: const Color(0xFF959595),
                  child: imageWidget == null
                      ? const Icon(Icons.person, size: 75, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              if (nombre != null && nombre!.isNotEmpty)
                Text(
                  nombre!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191919),
                  ),
                ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF191919),
                      ),
                    ),
                    const Divider(height: 30, color: Color(0xFFE5E7EB)),
                    if (nombre != null)
                      _datoUsuario(icon: Icons.person, titulo: "Nombre", valor: nombre!),
                    if (telefono != null && telefono!.isNotEmpty)
                      _datoUsuario(icon: Icons.phone, titulo: "Teléfono", valor: telefono!),
                    if (email != null)
                      _datoUsuario(icon: Icons.email, titulo: "Email", valor: email!),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Editar foto de perfil",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF191919).withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () => seleccionarImagen(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: const Text("Seleccionar desde galería"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => seleccionarImagen(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Tomar foto"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF0000),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 20),
              if (imagenSeleccionada != null)
                ElevatedButton.icon(
                  onPressed: subirImagen,
                  icon: const Icon(Icons.upload),
                  label: const Text("Guardar imagen"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF191919),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _datoUsuario({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0000).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF0000), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF959595),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Color(0xFF191919),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}