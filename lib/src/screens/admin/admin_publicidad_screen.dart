import 'package:flutter/material.dart';
import '../../models/publicidad.dart';
import '../../services/firestore_service.dart';

class AdminPublicidadScreen extends StatelessWidget {
  const AdminPublicidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Publicidad')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoCrear(context, firestoreService),
      ),
      body: StreamBuilder<List<Publicidad>>(
        stream: firestoreService.getPublicidades(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final publicidades = snapshot.data!;

          if (publicidades.isEmpty) {
            return const Center(child: Text('No hay publicidades activas.'));
          }

          return ListView.builder(
            itemCount: publicidades.length,
            itemBuilder: (context, index) {
              final publicidad = publicidades[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: double.infinity,
                      child: Image.network(
                        publicidad.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                    ListTile(
                      title: Text(publicidad.linkUrl ?? 'Sin enlace'),
                      subtitle: const Text('Activa'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmarBorrar(context, firestoreService, publicidad.id),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context, FirestoreService service) {
    final imagenCtrl = TextEditingController();
    final linkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Publicidad'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: imagenCtrl,
              decoration: const InputDecoration(
                labelText: 'URL de la Imagen',
                hintText: 'https://...',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: linkCtrl,
              decoration: const InputDecoration(
                labelText: 'Enlace (Opcional)',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (imagenCtrl.text.isNotEmpty) {
                service.crearPublicidad(
                  imagenCtrl.text,
                  linkCtrl.text.isEmpty ? null : linkCtrl.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _confirmarBorrar(BuildContext context, FirestoreService service, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Publicidad'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              service.borrarPublicidad(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
