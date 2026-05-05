import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPublicidadScreen extends StatelessWidget {
  const AdminPublicidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- PALETA DARK ESMERALDA ---
    // Usamos final porque se definen dentro del build
    final Color verdeEsmeralda = const Color(0xFF00C853);
    final Color negroProfundo = const Color(0xFF000000);
    final Color cardColor = const Color(0xFF1E272E);
    final Color verdeMuyOscuro = const Color(0xFF051209);

    return Scaffold(
      backgroundColor: negroProfundo,
      appBar: AppBar(
        title: const Text(
          'GESTIONAR PUBLICIDAD',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.2),
        ),
        backgroundColor: verdeMuyOscuro,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('publicidad').orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: verdeEsmeralda));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar publicidad", style: TextStyle(color: Colors.white)));
          }

          final docs = snapshot.data?.docs ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "BANNERS ACTIVOS (${docs.length})",
                  style: TextStyle(
                      color: verdeEsmeralda, // Sin const aquí
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.1
                  ),
                ),
              ),
              Expanded(
                child: docs.isEmpty
                    ? const Center(child: Text("No hay publicidad cargada", style: TextStyle(color: Colors.white24)))
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;
                    final String imageUrl = data['url'] ?? '';

                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            width: 60, height: 40, fit: BoxFit.cover,
                            errorBuilder: (_,__,___) => const Icon(Icons.image, color: Colors.white24),
                          )
                              : const Icon(Icons.image, color: Colors.white24),
                        ),
                        title: Text(data['nombre'] ?? 'Sponsor',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          data['link'] ?? 'Sin link',
                          // CORREGIDO: Se quitó el 'const' porque usa la variable verdeEsmeralda
                          style: TextStyle(color: verdeEsmeralda, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _confirmarEliminar(context, id),
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoAgregar(context),
                    icon: const Icon(Icons.add_photo_alternate, color: Colors.black),
                    label: const Text(
                      'AGREGAR NUEVA PUBLICIDAD',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: verdeEsmeralda,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- MÉTODOS DE APOYO (Dialogos) ---

  void _mostrarDialogoAgregar(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final linkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: const Text("Nueva Publicidad", style: TextStyle(color: Colors.white, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(nombreCtrl, "Nombre del Sponsor"),
              const SizedBox(height: 15),
              _buildField(urlCtrl, "URL de la Imagen"),
              const SizedBox(height: 15),
              _buildField(linkCtrl, "Link de destino (URL)"),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.white38))
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C853)),
              onPressed: () async {
                if (nombreCtrl.text.isNotEmpty && urlCtrl.text.isNotEmpty) {
                  await FirebaseFirestore.instance.collection('publicidad').add({
                    'nombre': nombreCtrl.text.trim(),
                    'url': urlCtrl.text.trim(),
                    'link': linkCtrl.text.trim(),
                    'fecha': Timestamp.now(),
                  });
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text("Guardar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C853))),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        title: const Text("¿Eliminar publicidad?", style: TextStyle(color: Colors.white, fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('publicidad').doc(id).delete();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text("Sí, eliminar", style: TextStyle(color: Colors.redAccent))
          ),
        ],
      ),
    );
  }
}