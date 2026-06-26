import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/firestore_service.dart';
import '../../models/partido.dart';
import '../../models/equipo.dart';
import 'admin_control_partido_screen.dart';

class AdminFixtureScreen extends StatefulWidget {
  const AdminFixtureScreen({super.key});
  @override
  State<AdminFixtureScreen> createState() => _AdminFixtureScreenState();
}

class _AdminFixtureScreenState extends State<AdminFixtureScreen> {
  final firestoreService = FirestoreService();
  final Color verdeEsmeralda = const Color(0xFF00C853);
  final Color cardColor = const Color(0xFF1E272E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('GESTIÓN DE FIXTURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: const Color(0xFF051209),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Partido>>(
        stream: firestoreService.getPartidos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator(color: verdeEsmeralda));
          final partidos = snapshot.data!..sort((a, b) => b.numeroFecha.compareTo(a.numeroFecha));

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: partidos.length,
            itemBuilder: (context, index) {
              final p = partidos[index];
              final bool enVivo = p.estado == EstadoPartido.jugando;
              return Card(
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: enVivo ? verdeEsmeralda : Colors.white10, width: enVivo ? 2 : 1),
                ),
                child: ListTile(
                  onTap: () => _mostrarOpciones(context, p),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: Text(p.local.nombre, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                        child: Text(p.estado == EstadoPartido.pendiente ? "VS" : "${p.golesLocal} - ${p.golesVisitante}",
                            style: TextStyle(color: (enVivo || p.finalizado) ? verdeEsmeralda : Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Text(p.visitante.nombre, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("${p.categoria.toUpperCase()} - ${p.numeroFecha.toUpperCase()} ${enVivo ? '• EN VIVO' : ''}",
                        textAlign: TextAlign.center, style: TextStyle(color: enVivo ? verdeEsmeralda : Colors.white38, fontSize: 10)),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: verdeEsmeralda,
        onPressed: () => _abrirFormulario(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _mostrarOpciones(BuildContext context, Partido p) {
    showModalBottomSheet(
      backgroundColor: cardColor,
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.estado == EstadoPartido.pendiente)
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: const Text("INICIAR PARTIDO", style: TextStyle(color: Colors.white)),
              onTap: () { FirebaseFirestore.instance.collection('partidos').doc(p.id).update({'estado': 'jugando'}); Navigator.pop(context); },
            ),
          ListTile(
            leading: const Icon(Icons.sports_soccer, color: Colors.white),
            title: const Text("CONTROLAR GOLES", style: TextStyle(color: Colors.white)),
            onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => AdminControlPartidoScreen(partidoId: p.id, equipoLocal: p.local.nombre, equipoVisitante: p.visitante.nombre))); },
          ),
          if (p.estado == EstadoPartido.jugando)
            ListTile(
              leading: const Icon(Icons.stop, color: Colors.orange),
              title: const Text("FINALIZAR PARTIDO", style: TextStyle(color: Colors.white)),
              onTap: () { FirebaseFirestore.instance.collection('partidos').doc(p.id).update({'estado': 'finalizado', 'finalizado': true}); Navigator.pop(context); },
            ),
          ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("EDITAR"), onTap: () { Navigator.pop(context); _abrirFormulario(context, p: p); }),
          ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("ELIMINAR"), onTap: () { FirebaseFirestore.instance.collection('partidos').doc(p.id).delete(); Navigator.pop(context); }),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Partido? p}) async {
    final equipos = await firestoreService.getEquipos().first;
    final todos = await firestoreService.getPartidos().first;
    final cats = todos.map((x) => x.categoria).toSet().toList();
    if (!context.mounted) return;
    showDialog(context: context, builder: (_) => _DialogoPartido(equipos: equipos, categorias: cats, partido: p));
  }
}

class _DialogoPartido extends StatefulWidget {
  final List<Equipo> equipos; final List<String> categorias; final Partido? partido;
  const _DialogoPartido({required this.equipos, required this.categorias, this.partido});
  @override State<_DialogoPartido> createState() => _DialogoPartidoState();
}

class _DialogoPartidoState extends State<_DialogoPartido> {
  Equipo? el, ev; String? cat; DateTime fecha = DateTime.now(); TimeOfDay hora = TimeOfDay.now();
  final nroCtrl = TextEditingController(text: "1"); final otraCat = TextEditingController(); bool nuevaCat = false;

  @override
  void initState() {
    super.initState();
    if (widget.partido != null) {
      final p = widget.partido!; nroCtrl.text = p.numeroFecha;
      cat = p.categoria; fecha = p.fecha; hora = TimeOfDay.fromDateTime(p.fecha);
      try { el = widget.equipos.firstWhere((e) => e.nombre == p.local.nombre); ev = widget.equipos.firstWhere((e) => e.nombre == p.visitante.nombre); } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E272E),
      title: Text(widget.partido == null ? "NUEVO PARTIDO" : "EDITAR", style: const TextStyle(color: Color(0xFF00C853))),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: nroCtrl, decoration: const InputDecoration(labelText: "Nro Fecha (o texto ej: Final)", labelStyle: TextStyle(color: Colors.white70)), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.text),
            DropdownButtonFormField<String>(
              dropdownColor: const Color(0xFF1E272E), value: widget.categorias.contains(cat) ? cat : null,
              items: [...widget.categorias.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(color: Colors.white)))), const DropdownMenuItem(value: "OTRA", child: Text("NUEVA..."))],
              onChanged: (v) => setState(() { cat = v; nuevaCat = v == "OTRA"; }), decoration: const InputDecoration(labelText: "Categoría"),
            ),
            if (nuevaCat) TextField(controller: otraCat, decoration: const InputDecoration(labelText: "Nombre Categoría"), style: const TextStyle(color: Colors.white)),
            DropdownButtonFormField<Equipo>(
              dropdownColor: const Color(0xFF1E272E), value: el,
              items: widget.equipos.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => el = v), decoration: const InputDecoration(labelText: "Local"),
            ),
            DropdownButtonFormField<Equipo>(
              dropdownColor: const Color(0xFF1E272E), value: ev,
              items: widget.equipos.map((e) => DropdownMenuItem(value: e, child: Text(e.nombre, style: const TextStyle(color: Colors.white)))).toList(),
              onChanged: (v) => setState(() => ev = v), decoration: const InputDecoration(labelText: "Visitante"),
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: TextButton(onPressed: () async { final p = await showDatePicker(context: context, initialDate: fecha, firstDate: DateTime(2000), lastDate: DateTime(2100)); if (p != null) setState(() => fecha = p); }, child: Text(DateFormat('dd/MM/yy').format(fecha)))),
              Expanded(child: TextButton(onPressed: () async { final p = await showTimePicker(context: context, initialTime: hora); if (p != null) setState(() => hora = p); }, child: Text(hora.format(context)))),
            ])
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
        ElevatedButton(onPressed: _guardar, child: const Text("GUARDAR")),
      ],
    );
  }

  void _guardar() {
    if (el == null || ev == null) return;
    final fCat = nuevaCat ? otraCat.text : cat;
    final fFecha = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);

    final data = {
      'numeroFecha': nroCtrl.text,
      'categoria': fCat,
      'fecha': Timestamp.fromDate(fFecha),
      'local': {'nombre': el!.nombre, 'escudoUrl': el!.escudoUrl},
      'visitante': {'nombre': ev!.nombre, 'escudoUrl': ev!.escudoUrl},
      'estado': widget.partido?.estado.toString().split('.').last ?? 'pendiente'
    };

    if (widget.partido == null) {
      FirebaseFirestore.instance.collection('partidos').add({
        ...data,
        'golesLocal': 0,
        'golesVisitante': 0,
        'finalizado': false
      });
    }
    else {
      FirebaseFirestore.instance.collection('partidos').doc(widget.partido!.id).update(data);
    }
    Navigator.pop(context);
  }
}