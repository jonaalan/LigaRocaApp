import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/partido.dart';
import '../../models/equipo.dart';
import '../../services/firestore_service.dart';
import 'admin_partido_control_screen.dart';
import 'admin_formacion_screen.dart';

class AdminFixtureScreen extends StatelessWidget {
  const AdminFixtureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Fixture'),
        backgroundColor: const Color(0xFF1A4D2E),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoCrear(context, service),
      ),
      body: StreamBuilder<List<Partido>>(
        stream: service.getPartidos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final partidos = snapshot.data!;
          // ORDENAR POR JORNADA DESCENDENTE
          partidos.sort((a, b) => b.numeroFecha.compareTo(a.numeroFecha));

          return ListView.builder(
            itemCount: partidos.length,
            itemBuilder: (context, index) {
              final p = partidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: p.local.escudoUrl.isNotEmpty
                      ? Image.network(p.local.escudoUrl, width: 30, errorBuilder: (_,__,___) => const Icon(Icons.shield))
                      : const Icon(Icons.shield),
                  title: Text('${p.local.nombre} vs ${p.visitante.nombre}'),
                  subtitle: Text(
                      'JORNADA: ${p.numeroFecha} (${DateFormat('dd/MM HH:mm').format(p.fecha)})\nCat: ${p.categoria}'
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'control') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminPartidoControlScreen(partido: p)));
                      } else if (val == 'form_l') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFormacionScreen(partido: p, esLocal: true)));
                      } else if (val == 'form_v') {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFormacionScreen(partido: p, esLocal: false)));
                      } else if (val == 'edit') {
                        _mostrarDialogoEditarJornadaYFecha(context, p);
                      } else if (val == 'del') {
                        _confirmarBorrar(context, service, p.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'control', child: Row(children: [Icon(Icons.sports_soccer, size: 20), Text(' Controlar Partido')])),
                      const PopupMenuItem(value: 'form_l', child: Text('Formación Local')),
                      const PopupMenuItem(value: 'form_v', child: Text('Formación Visitante')),
                      const PopupMenuItem(value: 'edit', child: Text('Editar Jornada/Fecha')),
                      const PopupMenuItem(value: 'del', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
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

  void _mostrarDialogoEditarJornadaYFecha(BuildContext context, Partido p) {
    final TextEditingController jornadaCtrl = TextEditingController(text: p.numeroFecha.toString());
    DateTime fechaSeleccionada = p.fecha;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Partido'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: jornadaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de Jornada'),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text("Fecha y Hora:"),
                subtitle: Text(DateFormat('dd/MM/yyyy HH:mm').format(fechaSeleccionada)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  DateTime? d = await showDatePicker(
                    context: context,
                    initialDate: fechaSeleccionada,
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (d != null) {
                    TimeOfDay? t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(fechaSeleccionada),
                    );
                    if (t != null) {
                      setState(() {
                        fechaSeleccionada = DateTime(d.year, d.month, d.day, t.hour, t.minute);
                      });
                    }
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                int? nuevoNumero = int.tryParse(jornadaCtrl.text.trim());
                if (nuevoNumero != null) {
                  await FirebaseFirestore.instance.collection('partidos').doc(p.id).update({
                    'numeroFecha': nuevoNumero,
                    'fecha': Timestamp.fromDate(fechaSeleccionada),
                  });
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarBorrar(BuildContext context, FirestoreService service, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Estás seguro de eliminar este partido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('No')),
          TextButton(onPressed: () { service.borrarPartido(id); Navigator.pop(context); }, child: const Text('Sí')),
        ],
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context, FirestoreService service) {
    Equipo? local;
    Equipo? visitante;
    String cat = 'Primera';
    final TextEditingController jornadaCtrl = TextEditingController(text: "1");

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo Partido'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: cat,
                    items: ['Primera', 'Reserva', 'Sub-20', 'Femenino'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setState(() => cat = v!),
                    decoration: const InputDecoration(labelText: 'Categoría'),
                  ),
                  TextField(
                    controller: jornadaCtrl,
                    decoration: const InputDecoration(labelText: 'Número de Jornada'),
                    keyboardType: TextInputType.number,
                  ),
                  const Divider(),
                  StreamBuilder<List<Equipo>>(
                    stream: service.getEquipos(),
                    builder: (context, snap) {
                      if (!snap.hasData) return const LinearProgressIndicator();
                      return Column(
                        children: [
                          DropdownButtonFormField<Equipo>(
                            decoration: const InputDecoration(labelText: 'Local'),
                            items: snap.data!.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                            onChanged: (v) => setState(() => local = v),
                          ),
                          DropdownButtonFormField<Equipo>(
                            decoration: const InputDecoration(labelText: 'Visitante'),
                            items: snap.data!.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                            onChanged: (v) => setState(() => visitante = v),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
              ElevatedButton(
                onPressed: () async {
                  if (local != null && visitante != null) {
                    int numJornada = int.tryParse(jornadaCtrl.text) ?? 1;

                    // 1. Crear el partido y OBTENER LA REFERENCIA (docRef)
                    DocumentReference docRef = await FirebaseFirestore.instance.collection('partidos').add({
                      'localId': local!.id,
                      'visitanteId': visitante!.id,
                      'localNombre': local!.nombre,
                      'localEscudo': local!.escudoUrl,
                      'visitanteNombre': visitante!.nombre,
                      'visitanteEscudo': visitante!.escudoUrl,
                      'numeroFecha': numJornada,
                      'fecha': Timestamp.now(),
                      'estado': 'EstadoPartido.pendiente',
                      'golesLocal': 0,
                      'golesVisitante': 0,
                      'categoria': cat,
                    });

                    // 2. DISPARAR NOTIFICACIÓN CON EL partidoId CORRECTO
                    // Hincha Local
                    await FirebaseFirestore.instance.collection('notificaciones').add({
                      'partidoId': docRef.id,
                      'equipoId': local!.id,
                      'titulo': '¡Nuevo Partido programado!',
                      'mensaje': 'Vs ${visitante!.nombre} ($cat)',
                      'fecha': FieldValue.serverTimestamp(),
                      'leida': false,
                    });
                    // Hincha Visitante
                    await FirebaseFirestore.instance.collection('notificaciones').add({
                      'partidoId': docRef.id,
                      'equipoId': visitante!.id,
                      'titulo': '¡Nuevo Partido programado!',
                      'mensaje': 'Vs ${local!.nombre} ($cat)',
                      'fecha': FieldValue.serverTimestamp(),
                      'leida': false,
                    });

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Crear'),
              ),
            ],
          );
        },
      ),
    );
  }
}