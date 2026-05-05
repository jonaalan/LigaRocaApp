import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- PALETA DARK ESMERALDA ---
  final Color _verdeEsmeralda = const Color(0xFF00C853);
  final Color _verdeMuyOscuro = const Color(0xFF051209);
  final Color _negroProfundo = const Color(0xFF000000);
  final Color _inputBackground = const Color(0xFF1E272E);
  final Color _grisPlata = const Color(0xFFBDC3C7);

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _authService.login(_emailController.text.trim(), _passwordController.text.trim());
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al ingresar: Verifique sus datos')),
        );
      }
    }
  }

  // --- FUNCIÓN PARA RECUPERAR CONTRASEÑA ---
  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu email para recuperar la contraseña')),
      );
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo de recuperación enviado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al enviar el correo de recuperación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _negroProfundo,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.5),
            radius: 1.2,
            colors: [_verdeMuyOscuro, _negroProfundo],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // --- PELOTA 3D ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _verdeEsmeralda.withOpacity(0.2),
                              blurRadius: 60,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      Image.network(
                        'https://pngimg.com/uploads/football/football_PNG52789.png',
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.sports_soccer, size: 80, color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // --- TEXTO CHITO (Estilo Alpha) ---
                  Text(
                    'CHITO',
                    style: TextStyle(
                      color: _verdeEsmeralda,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                  ),
                  const Text(
                    'LIGA ROCA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- INPUTS ---
                  _buildInput(
                    controller: _emailController,
                    hint: 'CORREO ELECTRÓNICO',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 15),
                  _buildInput(
                    controller: _passwordController,
                    hint: 'CONTRASEÑA',
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  // --- BOTÓN RECUPERAR ---
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: _grisPlata, fontSize: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // --- BOTÓN ENTRAR ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _verdeEsmeralda,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('INGRESAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- REGISTRO ---
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistroScreen())),
                    child: RichText(
                      text: TextSpan(
                        text: '¿NUEVO AQUÍ? ',
                        style: TextStyle(color: _grisPlata, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'REGÍSTRATE',
                            style: TextStyle(color: _verdeEsmeralda, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF95A5A6), fontSize: 12),
          prefixIcon: Icon(icon, color: _grisPlata, size: 18),
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: _grisPlata, size: 18),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}