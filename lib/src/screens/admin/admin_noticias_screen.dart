import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/noticia.dart';
import 'admin_crear_noticia_screen.dart';

class AdminNoticiasScreen extends StatelessWidget {
  final String? rol;
  final String? equipoId;
  final String? equipoNombre;

  const AdminNoticiasScreen({super.key, this.rol, this.equipoId, this.equipoNombre});

  @override
  Widget build(BuildContext context) {
    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color negroProfundo = Color(0xFF000000);
    const Color cardColor = Color(0xFF1E272E);
    const Color verdeMuyOscuro = Color(0xFF051209);

    Query query = FirebaseFirestore.instance.collection('noticias');

    // Si es prensa, solo ve las noticias de su equipo
    if (rol == 'prensa' && equipoId != null) {
      query = query.where('equipoId', isEqualTo: equipoId);
    }

    query = query.orderBy('fecha', descending: true);

    return Scaffold(
      backgroundColor: negroProfundo,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR NOTICIAS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
        ),
        backgroundColor: verdeMuyOscuro,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: verdeEsmeralda));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No hay noticias para mostrar", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String titulo = data['titulo'] ?? 'Sin título';
              final String contenido = data['contenido'] ?? 'Sin contenido';
              final String? imageUrl = data['imageUrl'];

              final noticia = Noticia(
                id: doc.id,
                titulo: titulo,
                contenido: contenido,
                imageUrl: imageUrl,
                tipo: data['tipo'] == 'general' ? TipoNoticia.general : TipoNoticia.equipo,
                equipoId: data['equipoId'],
                fecha: data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : DateTime.now(),
              );

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminCrearNoticiaScreen(
                          noticia: noticia,
                          rol: rol,
                          equipoId: equipoId,
                          equipoNombre: equipoNombre,
                        ),
                      ),
                    );
                  },
                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.newspaper, color: Colors.white24),
                    ),
                  )
                      : const Icon(Icons.newspaper, color: Colors.white24),
                  title: Text(
                    titulo,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    contenido,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmarEliminar(context, doc.id),
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
            MaterialPageRoute(
              builder: (context) => AdminCrearNoticiaScreen(
                rol: rol,
                equipoId: equipoId,
                equipoNombre: equipoNombre,
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: const Text('¿Eliminar noticia?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('noticias').doc(id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Sí, eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
