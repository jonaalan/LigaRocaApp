import 'package:flutter/material.dart';
import '../../models/equipo.dart';
import '../../services/firestore_service.dart';

class AdminEquiposScreen extends StatelessWidget {
  const AdminEquiposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Equipos')),
      body: StreamBuilder<List<Equipo>>(
        stream: firestoreService.getEquipos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final equipos = snapshot.data!;

          return ListView.builder(
            itemCount: equipos.length,
            itemBuilder: (context, index) {
              final equipo = equipos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: equipo.escudoUrl.isNotEmpty ? NetworkImage(equipo.escudoUrl) : null,
                    child: equipo.escudoUrl.isEmpty ? const Icon(Icons.shield) : null,
                  ),
                  title: Text(equipo.nombre),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _mostrarDialogoEditar(context, firestoreService, equipo),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _mostrarDialogoEditar(BuildContext context, FirestoreService service, Equipo equipo) {
    final nombreCtrl = TextEditingController(text: equipo.nombre);
    final escudoCtrl = TextEditingController(text: equipo.escudoUrl);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Equipo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre del Equipo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: escudoCtrl,
              decoration: const InputDecoration(labelText: 'URL del Escudo'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty) {
                service.actualizarEquipo(equipo.id, nombreCtrl.text, escudoCtrl.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
