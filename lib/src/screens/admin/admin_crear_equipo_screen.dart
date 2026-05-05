import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

class AdminCrearEquipoScreen extends StatefulWidget {
  const AdminCrearEquipoScreen({super.key});

  @override
  State<AdminCrearEquipoScreen> createState() => _AdminCrearEquipoScreenState();
}

class _AdminCrearEquipoScreenState extends State<AdminCrearEquipoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _escudoUrlController = TextEditingController();
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  static final Color verdeEsmeralda = const Color(0xFF00C853);
  static final Color negroProfundo = const Color(0xFF000000);
  static final Color cardColor = const Color(0xFF1E272E);

  Future<void> _guardarEquipo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // CORRECCIÓN AQUÍ: Pasamos los argumentos sin los nombres 'nombre:' y 'escudoUrl:'
        // porque tu servicio los espera como argumentos posicionales.
        await _firestoreService.crearEquipo(
          _nombreController.text.trim(),
          _escudoUrlController.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Equipo creado con éxito'))
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'))
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
      backgroundColor: negroProfundo,
      appBar: AppBar(
        title: const Text('NUEVO EQUIPO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF051209),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: verdeEsmeralda))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel("Nombre del Equipo"),
              _buildTextField(_nombreController, "Ej: Sportivo Roca", (v) => v!.isEmpty ? 'Ingresa el nombre' : null),

              const SizedBox(height: 25),

              _buildLabel("URL del Escudo (Imagen)"),
              _buildTextField(_escudoUrlController, "https://...", (v) => v!.isEmpty ? 'Ingresa la URL del escudo' : null),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _guardarEquipo,
                  icon: const Icon(Icons.save, color: Colors.black),
                  label: const Text('GUARDAR EQUIPO', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdeEsmeralda,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(texto, style: TextStyle(color: verdeEsmeralda, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, String? Function(String?)? validator) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: verdeEsmeralda)),
      ),
    );
  }
}