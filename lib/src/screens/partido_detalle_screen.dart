import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/partido.dart';

class PartidoDetalleScreen extends StatelessWidget {
  final String? partidoId;
  final Partido? partido;

  const PartidoDetalleScreen({super.key, this.partidoId, this.partido});

  @override
  Widget build(BuildContext context) {
    if (partido != null) {
      return _buildDetalle(context, partido!);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('partidos').doc(partidoId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Scaffold(body: Center(child: Text("Error al cargar")));
        if (!snapshot.hasData) return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final partidoCargado = Partido.fromFirestore(data, snapshot.data!.id);

        return _buildDetalle(context, partidoCargado);
      },
    );
  }

  Widget _buildDetalle(BuildContext context, Partido partido) {
    // CORRECCIÓN AQUÍ: Usamos 'de' con comillas simples adicionales para que no se convierta en número
    final df = DateFormat("EEEE dd 'de' MMMM - HH:mm", 'es');

    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color negroProfundo = Color(0xFF000000);
    const Color verdeMuyOscuro = Color(0xFF051209);
    const Color cardColor = Color(0xFF1E272E);

    return Scaffold(
      backgroundColor: negroProfundo,
      appBar: AppBar(
        backgroundColor: verdeMuyOscuro,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
            'DETALLE DEL ENCUENTRO',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [verdeMuyOscuro, negroProfundo],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _equipoDetalle(partido.local.nombre, partido.local.escudoUrl),
                    Column(
                      children: [
                        Text(
                          partido.finalizado ? 'FINALIZADO' : 'EN CURSO',
                          style: TextStyle(
                              color: partido.finalizado ? verdeEsmeralda : Colors.orangeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          partido.estado == EstadoPartido.pendiente
                              ? 'VS'
                              : '${partido.golesLocal} - ${partido.golesVisitante}',
                          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    _equipoDetalle(partido.visitante.nombre, partido.visitante.escudoUrl),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              _buildInfoCard(
                titulo: 'INFORMACIÓN DE LA JORNADA',
                cardColor: cardColor,
                verdeEsmeralda: verdeEsmeralda,
                items: [
                  _infoItem(Icons.calendar_month, 'Fecha', 'Jornada ${partido.numeroFecha}'),
                  _infoItem(Icons.access_time, 'Horario', df.format(partido.fecha)),
                  _infoItem(Icons.emoji_events, 'Categoría', partido.categoria.toUpperCase()),
                ],
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _equipoDetalle(String nombre, String url) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: (url.isEmpty || url == 'null')
                ? const Icon(Icons.shield, size: 60, color: Colors.white12)
                : Image.network(url, height: 70, width: 70, fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 60, color: Colors.white12)),
          ),
          const SizedBox(height: 15),
          Text(nombre.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String titulo, required Color cardColor, required Color verdeEsmeralda, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: TextStyle(color: verdeEsmeralda, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 20),
        ...items,
      ]),
    );
  }

  Widget _infoItem(IconData icono, String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(children: [
        Icon(icono, size: 20, color: Colors.white38),
        const SizedBox(width: 15),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
          Text(valor, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ]),
      ]),
    );
  }
}