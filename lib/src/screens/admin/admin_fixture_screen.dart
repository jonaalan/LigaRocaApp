import 'package:flutter/material.dart';
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
    final firestoreService = FirestoreService();
    final dateFormat = DateFormat('dd/MM HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Gestionar Fixture')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _mostrarDialogoCrear(context, firestoreService),
      ),
      body: StreamBuilder<List<Partido>>(
        stream: firestoreService.getPartidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final partidos = snapshot.data!;

          return ListView.builder(
            itemCount: partidos.length,
            itemBuilder: (context, index) {
              final partido = partidos[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text('${partido.local.nombre} vs ${partido.visitante.nombre}'),
                  subtitle: Text(
                    '${dateFormat.format(partido.fecha)} - ${partido.estado.toString().split('.').last.toUpperCase()}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.sports_esports, color: Colors.green),
                        tooltip: 'Controlar Partido',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminPartidoControlScreen(partido: partido),
                            ),
                          );
                        },
                      ),
                      // Menú de opciones extra (Formaciones)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'formacion_local') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFormacionScreen(partido: partido, esLocal: true)));
                          } else if (value == 'formacion_visitante') {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => AdminFormacionScreen(partido: partido, esLocal: false)));
                          } else if (value == 'editar') {
                            _mostrarDialogoResultado(context, firestoreService, partido);
                          } else if (value == 'borrar') {
                            _confirmarBorrar(context, firestoreService, partido.id);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'formacion_local', child: Text('Formación Local')),
                          const PopupMenuItem(value: 'formacion_visitante', child: Text('Formación Visitante')),
                          const PopupMenuItem(value: 'editar', child: Text('Editar Resultado')),
                          const PopupMenuItem(value: 'borrar', child: Text('Eliminar Partido', style: TextStyle(color: Colors.red))),
                        ],
                      ),
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

  void _confirmarBorrar(BuildContext context, FirestoreService service, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Partido'),
        content: const Text('¿Estás seguro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              service.borrarPartido(id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoResultado(BuildContext context, FirestoreService service, Partido partido) {
    final golesLocalCtrl = TextEditingController(text: partido.golesLocal.toString());
    final golesVisitanteCtrl = TextEditingController(text: partido.golesVisitante.toString());
    bool finalizado = partido.finalizado;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Actualizar Resultado'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: golesLocalCtrl,
                        decoration: InputDecoration(labelText: partido.local.nombre),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: golesVisitanteCtrl,
                        decoration: InputDecoration(labelText: partido.visitante.nombre),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Partido Finalizado'),
                  value: finalizado,
                  onChanged: (val) => setState(() => finalizado = val!),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  service.actualizarPartido(
                    partido.id,
                    golesLocal: int.tryParse(golesLocalCtrl.text) ?? 0,
                    golesVisitante: int.tryParse(golesVisitanteCtrl.text) ?? 0,
                    finalizado: finalizado,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _mostrarDialogoCrear(BuildContext context, FirestoreService service) {
    Equipo? local;
    Equipo? visitante;
    DateTime fecha = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nuevo Partido'),
            content: SizedBox(
              width: double.maxFinite,
              child: StreamBuilder<List<Equipo>>(
                stream: service.getEquipos(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const LinearProgressIndicator();
                  final equipos = snapshot.data!;
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Equipo>(
                        decoration: const InputDecoration(labelText: 'Local'),
                        value: local,
                        items: equipos.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                        onChanged: (val) => setState(() => local = val),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Equipo>(
                        decoration: const InputDecoration(labelText: 'Visitante'),
                        value: visitante,
                        items: equipos.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre))).toList(),
                        onChanged: (val) => setState(() => visitante = val),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: Text('Fecha: ${DateFormat('dd/MM HH:mm').format(fecha)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: fecha,
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(fecha),
                            );
                            if (time != null) {
                              setState(() {
                                fecha = DateTime(
                                  date.year, date.month, date.day,
                                  time.hour, time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
              ElevatedButton(
                onPressed: () {
                  if (local != null && visitante != null && local != visitante) {
                    service.crearPartido(local: local!, visitante: visitante!, fecha: fecha);
                    Navigator.pop(context);
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
