import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/partido.dart';
import 'admin/admin_partido_control_screen.dart';

class NotificacionesScreen extends StatelessWidget {
  final String? equipoId;
  final String? rol;

  const NotificacionesScreen({super.key, this.equipoId, this.rol});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('notificaciones');
    if (rol != 'admin' && equipoId != null) {
      query = query.where('equipoId', isEqualTo: equipoId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Avisos'),
        backgroundColor: const Color(0xFF1A4D2E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.orderBy('fecha', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text('Sin novedades por ahora.'));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final String? partidoId = data['partidoId'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.sports_soccer, color: Colors.green),
                  title: Text(data['titulo'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${data['mensaje']}\n${DateFormat('dd/MM HH:mm').format((data['fecha'] as Timestamp).toDate())}'),
                  trailing: partidoId != null ? const Icon(Icons.chevron_right) : null,
                  onTap: () async {
                    if (partidoId != null) {
                      // Buscamos los datos reales del partido para poder abrir la pantalla
                      final pDoc = await FirebaseFirestore.instance.collection('partidos').doc(partidoId).get();
                      if (pDoc.exists && context.mounted) {
                        final partido = Partido.fromFirestore(pDoc.data()!, pDoc.id);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminPartidoControlScreen(partido: partido),
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}