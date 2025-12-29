import 'package:flutter/material.dart';
import '../../models/noticia.dart';
import '../../models/equipo.dart';
import '../../services/firestore_service.dart';

class EditarNoticiaScreen extends StatefulWidget {
  final Noticia? noticia;

  const EditarNoticiaScreen({super.key, this.noticia});

  @override
  State<EditarNoticiaScreen> createState() => _EditarNoticiaScreenState();
}

class _EditarNoticiaScreenState extends State<EditarNoticiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  final _imageUrlController = TextEditingController(); // Nuevo campo

  TipoNoticia _tipoSeleccionado = TipoNoticia.general;
  String? _equipoIdSeleccionado;
  
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.noticia != null) {
      _tituloController.text = widget.noticia!.titulo;
      _contenidoController.text = widget.noticia!.contenido;
      _imageUrlController.text = widget.noticia!.imageUrl ?? '';
      _tipoSeleccionado = widget.noticia!.tipo;
      _equipoIdSeleccionado = widget.noticia!.equipoId;
    }
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      if (_tipoSeleccionado == TipoNoticia.equipo && _equipoIdSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seleccione un equipo')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        if (widget.noticia == null) {
          await _firestoreService.crearNoticia(
            titulo: _tituloController.text,
            contenido: _contenidoController.text,
            tipo: _tipoSeleccionado,
            equipoId: _equipoIdSeleccionado,
            imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          );
        } else {
          await _firestoreService.actualizarNoticia(
            widget.noticia!.id,
            titulo: _tituloController.text,
            contenido: _contenidoController.text,
            tipo: _tipoSeleccionado,
            equipoId: _equipoIdSeleccionado,
            imageUrl: _imageUrlController.text.isNotEmpty ? _imageUrlController.text : null,
          );
        }
        if (mounted) Navigator.pop(context);
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
      appBar: AppBar(
        title: Text(widget.noticia == null ? 'Nueva Noticia' : 'Editar Noticia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de Imagen (Opcional)',
                  hintText: 'https://ejemplo.com/imagen.jpg',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contenidoController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                maxLines: 10,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TipoNoticia>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo de Noticia'),
                items: const [
                  DropdownMenuItem(value: TipoNoticia.general, child: Text('General')),
                  DropdownMenuItem(value: TipoNoticia.equipo, child: Text('De Equipo')),
                ],
                onChanged: (val) {
                  setState(() {
                    _tipoSeleccionado = val!;
                    if (_tipoSeleccionado == TipoNoticia.general) {
                      _equipoIdSeleccionado = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_tipoSeleccionado == TipoNoticia.equipo)
                StreamBuilder<List<Equipo>>(
                  stream: _firestoreService.getEquipos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    
                    return DropdownButtonFormField<String>(
                      value: _equipoIdSeleccionado,
                      decoration: const InputDecoration(labelText: 'Equipo Asociado'),
                      items: snapshot.data!.map((e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.nombre),
                      )).toList(),
                      onChanged: (val) => setState(() => _equipoIdSeleccionado = val),
                    );
                  },
                ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _guardar,
                      child: const Text('Guardar Noticia'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
