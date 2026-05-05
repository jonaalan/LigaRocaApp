import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final Color verdeEsmeralda = const Color(0xFF00C853);

  @override
  void dispose() {
    // REGLA DE ORO: Al salir de la pantalla, marcamos todas como leídas
    _marcarTodasComoVistas();
    super.dispose();
  }

  Future<void> _marcarTodasComoVistas() async {
    var query = await FirebaseFirestore.instance
        .collection('notificaciones')
        .where('visto', isEqualTo: false)
        .get();

    for (var doc in query.docs) {
      await doc.reference.update({'visto': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CENTRO DE NOTIFICACIONES',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
        backgroundColor: const Color(0xFF051209),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white38),
            onPressed: () => _limpiarHistorial(),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Solo mostramos las que NO han sido vistas (visto == false)
        stream: FirebaseFirestore.instance
            .collection('notificaciones')
            .where('visto', isEqualTo: false)
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("NO TIENES NOTIFICACIONES NUEVAS",
                  style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var n = docs[index].data() as Map<String, dynamic>;
              DateTime fecha = (n['fecha'] as Timestamp).toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E272E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: verdeEsmeralda.withOpacity(0.3)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: verdeEsmeralda.withOpacity(0.1),
                    child: Icon(Icons.notifications_active, color: verdeEsmeralda, size: 20),
                  ),
                  title: Text(n['titulo'],
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      Text(n['mensaje'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(DateFormat('HH:mm').format(fecha), style: const TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _limpiarHistorial() async {
    var query = await FirebaseFirestore.instance.collection('notificaciones').get();
    for (var doc in query.docs) {
      await doc.reference.delete();
    }
  }
}