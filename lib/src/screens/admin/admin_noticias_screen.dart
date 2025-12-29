import 'package:flutter/material.dart';
import '../../models/noticia.dart';
import '../../services/firestore_service.dart';
import 'editar_noticia_screen.dart';

class AdminNoticiasScreen extends StatelessWidget {
  const AdminNoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Noticias')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const EditarNoticiaScreen()),
          );
        },
      ),
      body: StreamBuilder<List<Noticia>>(
        stream: firestoreService.getTodasLasNoticias(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final noticias = snapshot.data!;

          return ListView.builder(
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final noticia = noticias[index];
              return ListTile(
                title: Text(noticia.titulo),
                subtitle: Text(noticia.tipo == TipoNoticia.general ? 'General' : 'Equipo'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditarNoticiaScreen(noticia: noticia),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar Noticia'),
                            content: const Text('¿Estás seguro?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await firestoreService.borrarNoticia(noticia.id);
                        }
                      },
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
}
