import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/equipo.dart';
import '../services/equipo_service.dart';
import '../services/firestore_service.dart'; // 1. IMPORTAMOS EL SERVICIO

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final AuthService _authService = AuthService();
  final EquipoService _equipoService = EquipoService();
  final FirestoreService _firestoreService = FirestoreService(); // 2. INSTANCIAMOS EL SERVICIO

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Equipo? _equipoSeleccionado;
  List<Equipo> _equipos = [];
  bool _isLoading = false;

  final Color _verdeEsmeralda = const Color(0xFF00C853);
  final Color _verdeMuyOscuro = const Color(0xFF051209);
  final Color _negroProfundo = const Color(0xFF000000);
  final Color _inputBackground = const Color(0xFF1E272E);
  final Color _grisPlata = const Color(0xFFBDC3C7);

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  Future<void> _cargarEquipos() async {
    final equipos = await _equipoService.getEquipos();
    setState(() => _equipos = equipos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _negroProfundo,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(center: const Alignment(0, -0.6), radius: 1.2, colors: [_verdeMuyOscuro, _negroProfundo]),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 100),
                Text('NUEVO HINCHA', style: TextStyle(color: _verdeEsmeralda, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const SizedBox(height: 40),
                _buildInput(controller: _nombreController, hint: 'NOMBRE', icon: Icons.person_outline),
                const SizedBox(height: 15),
                _buildInput(controller: _emailController, hint: 'EMAIL', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _buildInput(controller: _passwordController, hint: 'CONTRASEÑA', icon: Icons.lock_outline, isPassword: true),
                const SizedBox(height: 15),

                // Selector de Equipo Estilizado
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(color: _inputBackground, borderRadius: BorderRadius.circular(12)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Equipo>(
                      isExpanded: true,
                      dropdownColor: _inputBackground,
                      value: _equipoSeleccionado,
                      hint: Text('TU EQUIPO', style: TextStyle(color: _grisPlata, fontSize: 12)),
                      style: const TextStyle(color: Colors.white),
                      items: _equipos.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                      onChanged: (val) => setState(() => _equipoSeleccionado = val),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _verdeEsmeralda, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
                    onPressed: _isLoading ? null : () async {
                      if (_equipoSeleccionado == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, selecciona tu equipo favorito')));
                        return;
                      }

                      setState(() => _isLoading = true);
                      try {
                        // 1. REGISTRO EN FIREBASE AUTH
                        await _authService.registrarUsuario(
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                          nombre: _nombreController.text.trim(),
                          equipoFavorito: _equipoSeleccionado!,
                        );

                        // 3. SUSCRIPCIÓN AUTOMÁTICA AL TÓPICO DEL EQUIPO (BOLSILLO)
                        await _firestoreService.suscribirAEquipo(_equipoSeleccionado!.id);

                        print("✅ Hincha registrado y suscrito a: equipo_${_equipoSeleccionado!.id}");

                        if (mounted) {
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.black) : const Text('REGISTRARME', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, bool isPassword = false, TextInputType keyboardType = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: _inputBackground, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: _grisPlata.withOpacity(0.5), fontSize: 12),
          prefixIcon: Icon(icon, color: _grisPlata, size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}