import 'package:flutter/material.dart';
import '../../models/equipo.dart';
import '../../models/noticia.dart';
import '../../services/firestore_service.dart';

class AdminCrearNoticiaScreen extends StatefulWidget {
  final Noticia? noticia;
  final String? rol;
  final String? equipoId;
  final String? equipoNombre;

  const AdminCrearNoticiaScreen({super.key, this.noticia, this.rol, this.equipoId, this.equipoNombre});

  @override
  State<AdminCrearNoticiaScreen> createState() => _AdminCrearNoticiaScreenState();
}

class _AdminCrearNoticiaScreenState extends State<AdminCrearNoticiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _imageUrlController = TextEditingController();

  TipoNoticia _tipoSeleccionado = TipoNoticia.general;
  Equipo? _equipoSeleccionado;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  static final Color verdeEsmeralda = const Color(0xFF00C853);
  static final Color negroProfundo = const Color(0xFF000000);
  static final Color cardColor = const Color(0xFF1E272E);

  @override
  void initState() {
    super.initState();

    if (widget.noticia != null) {
      _tituloController.text = widget.noticia!.titulo;
      _contenidoController.text = widget.noticia!.contenido;
      _imageUrlController.text = widget.noticia!.imageUrl ?? '';
      _tipoSeleccionado = widget.noticia!.tipo;
    }

    if (widget.rol == 'prensa') {
      _tipoSeleccionado = TipoNoticia.equipo;
      // ASIGNACIÓN INSTANTÁNEA: Evita el "Cargando equipo..."
      _equipoSeleccionado = Equipo(
        id: widget.equipoId ?? '',
        nombre: widget.equipoNombre ?? 'Mi Equipo',
        escudoUrl: '',
      );
    } else if (widget.noticia != null && widget.noticia!.equipoId != null) {
      _cargarEquipoEdicion(widget.noticia!.equipoId!);
    }
  }

  Future<void> _cargarEquipoEdicion(String id) async {
    final equipos = await _firestoreService.getEquipos().first;
    try {
      setState(() {
        _equipoSeleccionado = equipos.firstWhere((e) => e.id == id);
      });
    } catch (e) {
      print("Error cargando equipo para edición: $e");
    }
  }

  Future<void> _guardarNoticia() async {
    if (_formKey.currentState!.validate()) {
      if (_tipoSeleccionado == TipoNoticia.equipo && _equipoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un equipo para la noticia')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        if (widget.noticia == null) {
          await _firestoreService.crearNoticia(
            titulo: _tituloController.text.trim(),
            contenido: _contenidoController.text.trim(),
            tipo: _tipoSeleccionado,
            equipoId: _equipoSeleccionado?.id,
            imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          );
        } else {
          await _firestoreService.actualizarNoticia(
            widget.noticia!.id,
            titulo: _tituloController.text.trim(),
            contenido: _contenidoController.text.trim(),
            tipo: _tipoSeleccionado,
            equipoId: _equipoSeleccionado?.id,
            imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.noticia == null ? 'Noticia publicada' : 'Noticia actualizada')),
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
    bool esPrensa = widget.rol == 'prensa';

    return Scaffold(
      backgroundColor: negroProfundo,
      appBar: AppBar(
        title: Text(widget.noticia == null ? 'REDACTAR NOTICIA' : 'EDITAR NOTICIA',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF051209),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: verdeEsmeralda))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLabel("Título de la Noticia"),
              _buildTextField(_tituloController, "Ej: Gran victoria del local", (v) => v!.isEmpty ? 'Ingresa un título' : null),

              const SizedBox(height: 16),
              _buildLabel("Contenido / Cuerpo"),
              _buildTextField(_contenidoController, "Escribe aquí la noticia...", (v) => v!.isEmpty ? 'Ingresa el contenido' : null, maxLines: 5),

              const SizedBox(height: 16),
              _buildLabel("URL de la Imagen (Opcional)"),
              _buildTextField(_imageUrlController, "https://link-de-la-imagen.jpg", null),

              if (!esPrensa) ...[
                const SizedBox(height: 16),
                _buildLabel("Tipo de Noticia"),
                DropdownButtonFormField<TipoNoticia>(
                  dropdownColor: cardColor,
                  value: _tipoSeleccionado,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(""),
                  items: const [
                    DropdownMenuItem(value: TipoNoticia.general, child: Text('General')),
                    DropdownMenuItem(value: TipoNoticia.equipo, child: Text('De un Equipo')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _tipoSeleccionado = val!;
                      if (_tipoSeleccionado == TipoNoticia.general) {
                        _equipoSeleccionado = null;
                      }
                    });
                  },
                ),
              ],

              if (_tipoSeleccionado == TipoNoticia.equipo) ...[
                const SizedBox(height: 16),
                _buildLabel("Equipo Asociado"),
                esPrensa
                  ? InputDecorator(
                      decoration: _inputDecoration(""),
                      child: Text(_equipoSeleccionado?.nombre ?? "Cargando equipo...", style: const TextStyle(color: Colors.white70)),
                    )
                  : StreamBuilder<List<Equipo>>(
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

              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _guardarNoticia,
                icon: const Icon(Icons.send, color: Colors.black),
                label: Text(widget.noticia == null ? 'PUBLICAR NOTICIA' : 'ACTUALIZAR NOTICIA',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: verdeEsmeralda,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
