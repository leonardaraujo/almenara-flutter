
import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se ha registrado correctamente')),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _loading = true);
    try {
      await _authService.signInWithGoogle();
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu correo';
    final regex = RegExp(r'^\S+@\S+\.\S+$');
    if (!regex.hasMatch(value)) return 'Correo inválido';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) {
      return 'Debe contener un carácter especial';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu nombre completo';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu número telefónico';
    if (!RegExp(r'^\\d{7,15}\$').hasMatch(value)) {
      return 'Número telefónico inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrarse'),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF3E0), Color(0xFFFFCDD2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nombre completo'),
                validator: _validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Número telefónico'),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: _validatePassword,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar contraseña'),
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Registrar'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loading ? null : _registerWithGoogle,
                child: const Text('Registrarse con Google'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Ya tengo cuenta'),
              ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

