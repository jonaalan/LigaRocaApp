import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Equipo? _equipoSeleccionado;
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _registrarse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.registrarUsuario(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nombre: _nombreController.text.trim(),
          equipoFavorito: _equipoSeleccionado!,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al registrarse: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro Liga Roca')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre Completo'),
                validator: (v) => v!.isEmpty ? 'Ingrese su nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v!.isEmpty ? 'Ingrese su email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),

              // Selector de Equipos desde Firestore
              StreamBuilder<List<Equipo>>(
                stream: _firestoreService.getEquipos(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error cargando equipos: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final equipos = snapshot.data!;

                  return DropdownButtonFormField<Equipo>(
                    decoration: const InputDecoration(labelText: 'Equipo Favorito'),
                    value: _equipoSeleccionado,
                    items: equipos.map((equipo) {
                      return DropdownMenuItem(
                        value: equipo,
                        child: Text(equipo.nombre),
                      );
                    }).toList(),
                    onChanged: (Equipo? nuevoEquipo) {
                      setState(() {
                        _equipoSeleccionado = nuevoEquipo;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione un equipo' : null,
                  );
                },
              ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registrarse,
                      child: const Text('Registrarse'),
                    ),
              
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('¿Ya tienes cuenta? Inicia sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
