import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import 'home_screen.dart';
import 'registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al iniciar sesión: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _contactarSoporte() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'soporte.ligaroca@gmail.com',
      query: 'subject=Consulta sobre Liga Roca App',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        throw 'No se pudo abrir el correo';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Escriba a: soporte.ligaroca@gmail.com')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorTexto = Color(0xFFFDFDF5);
    const colorInputBg = Color(0xFF1E293B);
    const colorBorde = Color(0xFF334155);
    const colorAcento = Color(0xFF4ade80);

    return AuthBackground(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Forzamos ancho completo
          children: [
            const Text(
              'INICIAR SESIÓN',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colorAcento,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _emailController,
              style: const TextStyle(color: colorTexto),
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[400]),
                filled: true,
                fillColor: colorInputBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: colorBorde, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: colorAcento, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Ingrese su email' : null,
            ),
            
            const SizedBox(height: 20),
            
            TextFormField(
              controller: _passwordController,
              style: const TextStyle(color: colorTexto),
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[400],
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: colorInputBg,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: colorBorde, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: colorAcento, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Ingrese su contraseña' : null,
            ),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: colorAcento))
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAcento,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'INGRESAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
            ),
            
            const SizedBox(height: 30),
            
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿No tienes cuenta?', style: TextStyle(color: Colors.grey[400])),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const RegistroScreen()),
                        );
                      },
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: colorAcento,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: _contactarSoporte,
                  icon: Icon(Icons.help_outline, size: 16, color: Colors.grey[500]),
                  label: Text(
                    'Ayuda',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
