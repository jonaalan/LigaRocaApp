import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'partido_detalle_screen.dart';

class NotificacionesScreen extends StatefulWidget {
  NotificacionesScreen({super.key});

  @override
  _NotificacionesScreenState createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final FirestoreService _fs = FirestoreService();
  String? miEquipoId;

  @override
  void initState() {
    super.initState();
    _loadMiEquipo();
  }

  _loadMiEquipo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      miEquipoId = prefs.getString('equipoId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("NOTIFICACIONES", style: TextStyle(fontSize: 16)),
        backgroundColor: const Color(0xFF051209),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
            onPressed: () => _fs.borrarTodasLasNotificaciones(),
          )
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fs.getNotificacionesList(miEquipoId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final notifs = snapshot.data!;

          if (notifs.isEmpty) {
            return const Center(child: Text("No tienes notificaciones", style: TextStyle(color: Colors.white54)));
          }

          return ListView.builder(
            itemCount: notifs.length,
            itemBuilder: (context, index) {
              final n = notifs[index];
              bool esMiEquipo = n['equipoId'] == miEquipoId;

              return Card(
                color: esMiEquipo ? Colors.green.withOpacity(0.1) : const Color(0xFF121212),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Icon(
                      Icons.sports_soccer,
                      color: esMiEquipo ? Colors.green : Colors.white24
                  ),
                  title: Text(
                    esMiEquipo ? "¡GOL DE TU EQUIPO! 🏆" : n['titulo'],
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: esMiEquipo ? FontWeight.bold : FontWeight.normal
                    ),
                  ),
                  subtitle: Text(n['mensaje'], style: const TextStyle(color: Colors.white70)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                  onTap: () {
                    if (n['partidoId'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          // Pasamos el partidoId a la pantalla de detalle
                          builder: (context) => PartidoDetalleScreen(partidoId: n['partidoId']),
                        ),
                      );
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