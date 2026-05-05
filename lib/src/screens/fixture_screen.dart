import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/partido.dart';
import '../services/firestore_service.dart';
import 'partido_detalle_screen.dart';

class FixtureList extends StatelessWidget {
  const FixtureList({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color verdeMuyOscuro = Color(0xFF051209);
    const Color cardColor = Color(0xFF1E272E);

    return StreamBuilder<List<Partido>>(
      stream: firestoreService.getPartidos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: verdeEsmeralda));
        final todos = snapshot.data!;
        if (todos.isEmpty) return const Center(child: Text('No hay partidos.', style: TextStyle(color: Colors.white70)));

        final categorias = todos.map((p) => p.categoria).toSet().toList()..sort();

        return DefaultTabController(
          length: categorias.length,
          child: Column(
            children: [
              Container(
                color: verdeMuyOscuro,
                child: TabBar(
                  isScrollable: true,
                  labelColor: verdeEsmeralda,
                  indicatorColor: verdeEsmeralda,
                  unselectedLabelColor: Colors.white38,
                  tabs: categorias.map((c) => Tab(text: c.toUpperCase())).toList(),
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: categorias.map((cat) {
                    final filtrados = todos.where((p) => p.categoria == cat).toList()
                      ..sort((a, b) => b.numeroFecha.compareTo(a.numeroFecha));
                    return _buildLista(filtrados, verdeEsmeralda, cardColor);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLista(List<Partido> partidos, Color verde, Color card) {
    final df = DateFormat('dd/MM HH:mm');
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: partidos.length,
      itemBuilder: (context, index) {
        final p = partidos[index];
        final bool enVivo = p.estado == EstadoPartido.jugando;
        final bool mostrarRes = p.estado != EstadoPartido.pendiente;

        return Card(
          color: card,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: enVivo ? verde : Colors.white.withOpacity(0.05), width: enVivo ? 2 : 1),
          ),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidoDetalleScreen(partido: p))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  _equipoCol(p.local.nombre, p.local.escudoUrl, enVivo),
                  Expanded(
                    child: Column(
                      children: [
                        if (enVivo)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: verde, borderRadius: BorderRadius.circular(4)),
                            child: const Text('• EN VIVO', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                          )
                        else
                          Text('FECHA ${p.numeroFecha}', style: TextStyle(color: verde, fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8), border: Border.all(color: mostrarRes ? verde : Colors.white10)),
                          child: Text(mostrarRes ? '${p.golesLocal} - ${p.golesVisitante}' : 'VS',
                              style: TextStyle(color: mostrarRes ? verde : Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                        ),
                        const SizedBox(height: 8),
                        Text(enVivo ? 'TIEMPO REAL' : df.format(p.fecha), style: TextStyle(color: enVivo ? verde : Colors.white38, fontSize: 10)),
                      ],
                    ),
                  ),
                  _equipoCol(p.visitante.nombre, p.visitante.escudoUrl, enVivo),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _equipoCol(String n, String u, bool ev) {
    return Expanded(
      child: Column(
        children: [
          (u.isEmpty || u == 'null')
              ? Icon(Icons.shield, size: 42, color: ev ? Colors.white38 : Colors.white12)
              : Image.network(u, height: 45, width: 45, fit: BoxFit.contain, errorBuilder: (_,__,___) => const Icon(Icons.shield, size: 42, color: Colors.white12)),
          const SizedBox(height: 8),
          Text(n, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
        ],
      ),
    );
  }
}