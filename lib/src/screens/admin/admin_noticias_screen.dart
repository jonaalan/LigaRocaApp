import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/noticia.dart';
// REGLA DE ORO: Importación directa ya que están en la misma carpeta
import 'admin_crear_noticia_screen.dart';

class AdminNoticiasScreen extends StatelessWidget {
  const AdminNoticiasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color negroProfundo = Color(0xFF000000);
    const Color cardColor = Color(0xFF1E272E);
    const Color verdeMuyOscuro = Color(0xFF051209);

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
        stream: FirebaseFirestore.instance.collection('noticias').orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: verdeEsmeralda));
          }

          final docs = snapshot.data?.docs ?? [];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String titulo = data['titulo'] ?? 'Sin título';
              final String contenido = data['contenido'] ?? 'Sin contenido';
              final String? imageUrl = data['imageUrl'];

              return Card(
                color: cardColor,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
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
          // CORRECCIÓN: Quitamos 'const' porque AdminCrearNoticiaScreen tiene controladores internos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminCrearNoticiaScreen()),
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