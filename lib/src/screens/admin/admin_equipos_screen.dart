import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/equipo.dart';
import 'admin_crear_equipo_screen.dart';

class AdminEquiposScreen extends StatelessWidget {
  const AdminEquiposScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();
    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color cardColor = Color(0xFF1E272E);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('GESTIONAR EQUIPOS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2)),
        backgroundColor: const Color(0xFF051209),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Equipo>>(
        stream: service.getEquipos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: verdeEsmeralda));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay equipos creados", style: TextStyle(color: Colors.white54)));
          }

          final equipos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(top: 10, bottom: 80),
            itemCount: equipos.length,
            itemBuilder: (context, index) {
              final equipo = equipos[index];
              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: equipo.escudoUrl.isNotEmpty
                        ? Image.network(equipo.escudoUrl, width: 35, height: 35, fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(Icons.shield, color: Colors.white10))
                        : const Icon(Icons.shield, color: Colors.white10),
                  ),
                  title: Text(equipo.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    onPressed: () => _confirmarEliminar(context, equipo.id, equipo.nombre),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: verdeEsmeralda,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminCrearEquipoScreen()),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: Text("¿Eliminar $nombre?", style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("Esta acción no se puede deshacer.", style: TextStyle(color: Colors.white54)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('equipos').doc(id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("ELIMINAR", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}