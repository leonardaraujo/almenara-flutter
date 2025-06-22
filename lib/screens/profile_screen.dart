import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;

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

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = doc.data();
    if (data != null) {
      setState(() {
        imagenBase64 = data['imgProfile'];
        nombre = data['name'];
        telefono = data['phone'];
        email = data['email'];
      });
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

    try {
      final bytes = await imagenSeleccionada!.readAsBytes();

      // Decodificar imagen
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('No se pudo leer la imagen.');

      // Redimensionar si es muy grande
      if (image.width > 600 || image.height > 600) {
        image = img.copyResize(image, width: 600);
      }

      // Comprimir la imagen
      final compressedBytes = img.encodeJpg(image, quality: 70);

      // Convertir a Base64
      final base64Image = base64Encode(compressedBytes);

      // Validar tamaño
      if (base64Image.length > 700000) {
        throw Exception('La imagen es demasiado grande. Selecciona otra más liviana.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'imgProfile': base64Image,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      setState(() {
        imagenBase64 = base64Image;
        imagenSeleccionada = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagen de perfil actualizada exitosamente'),
          backgroundColor: Color(0xFF191919),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? imageWidget;

    if (imagenSeleccionada != null) {
      imageWidget = FileImage(imagenSeleccionada!);
    } else if (imagenBase64 != null) {
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE5E7EB),
              ),
              padding: const EdgeInsets.all(5),
              child: CircleAvatar(
                radius: 70,
                backgroundImage: imageWidget,
                backgroundColor: const Color(0xFF959595),
                child: imageWidget == null
                    ? const Icon(Icons.person, size: 70, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            // Datos del usuario con diseño
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
                  if (nombre != null)
                    _datoUsuario(icon: Icons.person, titulo: "Nombre", valor: nombre!),
                  if (telefono != null)
                    _datoUsuario(icon: Icons.phone, titulo: "Teléfono", valor: telefono!),
                  if (email != null)
                    _datoUsuario(icon: Icons.email, titulo: "Email", valor: email!),
                ],
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => seleccionarImagen(ImageSource.gallery),
              icon: const Icon(Icons.photo),
              label: const Text("Seleccionar desde galería"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => seleccionarImagen(ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Tomar foto"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF0000),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                  minimumSize: const Size.fromHeight(45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFFF0000), size: 24),
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
                    fontWeight: FontWeight.w400,
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
