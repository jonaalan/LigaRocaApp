import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/equipo.dart';

class AdminNotificacionesScreen extends StatefulWidget {
  const AdminNotificacionesScreen({super.key});

  @override
  State<AdminNotificacionesScreen> createState() => _AdminNotificacionesScreenState();
}

class _AdminNotificacionesScreenState extends State<AdminNotificacionesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _mensajeController = TextEditingController();
  bool _isLoading = false;

  String _destino = "General"; // "General" o "Equipo"
  Equipo? _equipoSeleccionado;

  final FirestoreService _firestoreService = FirestoreService();

  static final Color verdeEsmeralda = const Color(0xFF00C853);
  static final Color negroProfundo = const Color(0xFF000000);
  static final Color cardColor = const Color(0xFF1E272E);

  Future<void> _enviar() async {
    if (_formKey.currentState!.validate()) {
      if (_destino == "Equipo" && _equipoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona un equipo')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        await _firestoreService.enviarNotificacionGeneral(
          titulo: _tituloController.text.trim(),
          mensaje: _mensajeController.text.trim(),
          equipoId: _destino == "Equipo" ? _equipoSeleccionado?.id : null,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notificación enviada con éxito')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
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
        title: const Text('ENVIAR NOTIFICACIÓN',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                    _buildLabel("Destinatarios"),
                    DropdownButtonFormField<String>(
                      dropdownColor: cardColor,
                      value: _destino,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration(""),
                      items: const [
                        DropdownMenuItem(value: "General", child: Text("A Todos (General)")),
                        DropdownMenuItem(value: "Equipo", child: Text("Solo a un Equipo")),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _destino = val!;
                          if (_destino == "General") _equipoSeleccionado = null;
                        });
                      },
                    ),

                    if (_destino == "Equipo") ...[
                      const SizedBox(height: 16),
                      _buildLabel("Seleccionar Equipo"),
                      StreamBuilder<List<Equipo>>(
                        stream: _firestoreService.getEquipos(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return LinearProgressIndicator(color: verdeEsmeralda);
                          return DropdownButtonFormField<Equipo>(
                            dropdownColor: cardColor,
                            value: _equipoSeleccionado,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Elegir equipo"),
                            items: snapshot.data!.map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.nombre),
                            )).toList(),
                            onChanged: (val) => setState(() => _equipoSeleccionado = val),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 25),
                    _buildLabel("Título"),
                    _buildTextField(_tituloController, "Ej: ¡Tenemos Ganador!", (v) => v!.isEmpty ? 'Ingresa un título' : null),

                    const SizedBox(height: 25),
                    _buildLabel("Mensaje"),
                    _buildTextField(
                      _mensajeController,
                      "Ej: Jugador del partido Jona Barrionuevo auspiciado por Fobale",
                      (v) => v!.isEmpty ? 'Ingresa el mensaje' : null,
                      maxLines: 4
                    ),

                    const SizedBox(height: 50),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _enviar,
                        icon: const Icon(Icons.send, color: Colors.black),
                        label: Text(_destino == "General" ? 'ENVIAR A TODOS' : 'ENVIAR AL EQUIPO',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField(TextEditingController ctrl, String hint, String? Function(String?)? validator, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white10)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: verdeEsmeralda)),
    );
  }
}
