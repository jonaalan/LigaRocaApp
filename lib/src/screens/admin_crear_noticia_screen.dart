import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/noticia.dart';
import '../services/firestore_service.dart';

class AdminCrearNoticiaScreen extends StatefulWidget {
  const AdminCrearNoticiaScreen({super.key});

  @override
  State<AdminCrearNoticiaScreen> createState() => _AdminCrearNoticiaScreenState();
}

class _AdminCrearNoticiaScreenState extends State<AdminCrearNoticiaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _contenidoController = TextEditingController();
  
  TipoNoticia _tipoSeleccionado = TipoNoticia.general;
  Equipo? _equipoSeleccionado;
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _publicarNoticia() async {
    if (_formKey.currentState!.validate()) {
      if (_tipoSeleccionado == TipoNoticia.equipo && _equipoSeleccionado == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecciona un equipo para la noticia')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _firestoreService.crearNoticia(
          titulo: _tituloController.text.trim(),
          contenido: _contenidoController.text.trim(),
          tipo: _tipoSeleccionado,
          equipoId: _equipoSeleccionado?.id,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Noticia publicada con éxito')),
          );
          Navigator.pop(context); // Volver atrás
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al publicar: $e')),
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
      appBar: AppBar(title: const Text('Redactar Noticia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Ingresa un título' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _contenidoController,
                decoration: const InputDecoration(
                  labelText: 'Contenido',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (v) => v!.isEmpty ? 'Ingresa el contenido' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<TipoNoticia>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo de Noticia'),
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
              const SizedBox(height: 16),

              if (_tipoSeleccionado == TipoNoticia.equipo)
                StreamBuilder<List<Equipo>>(
                  stream: _firestoreService.getEquipos(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const LinearProgressIndicator();
                    
                    return DropdownButtonFormField<Equipo>(
                      value: _equipoSeleccionado,
                      decoration: const InputDecoration(labelText: 'Seleccionar Equipo'),
                      items: snapshot.data!.map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.nombre),
                      )).toList(),
                      onChanged: (val) => setState(() => _equipoSeleccionado = val),
                    );
                  },
                ),

              const SizedBox(height: 24),

              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _publicarNoticia,
                      icon: const Icon(Icons.send),
                      label: const Text('Publicar Noticia'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
