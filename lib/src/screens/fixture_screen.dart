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
    const Color verdeChito = Color(0xFF1A4D2E);

    return StreamBuilder<List<Partido>>(
      stream: firestoreService.getPartidos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final todos = snapshot.data!;

        // Obtenemos todas las categorías únicas
        final categorias = todos.map((p) => p.categoria).toSet().toList()..sort();

        if (todos.isEmpty) return const Center(child: Text('No hay partidos cargados.'));

        return DefaultTabController(
          key: ValueKey(categorias.length),
          length: categorias.length,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                labelColor: verdeChito,
                indicatorColor: verdeChito,
                unselectedLabelColor: Colors.grey,
                tabs: categorias.map((c) => Tab(text: c.toUpperCase())).toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: categorias.map((cat) {
                    final filtrados = todos.where((p) => p.categoria == cat).toList()
                      ..sort((a, b) => b.numeroFecha.compareTo(a.numeroFecha));
                    return _buildLista(filtrados, verdeChito);
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLista(List<Partido> partidos, Color verdeChito) {
    final df = DateFormat('dd/MM HH:mm');
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: partidos.length,
      itemBuilder: (context, index) {
        final p = partidos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartidoDetalleScreen(partido: p))),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children: [
                  _equipoCol(p.local.nombre, p.local.escudoUrl),
                  Expanded(
                    child: Column(
                      children: [
                        // AQUÍ SE QUITÓ EL 'const' QUE DABA ERROR
                        Text(
                            'JORNADA ${p.numeroFecha}',
                            style: TextStyle(color: verdeChito, fontSize: 11, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: p.finalizado ? verdeChito : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8)
                          ),
                          child: Text(
                            p.estado == EstadoPartido.pendiente ? 'VS' : '${p.golesLocal} - ${p.golesVisitante}',
                            style: TextStyle(
                                color: p.finalizado ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(df.format(p.fecha), style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                      ],
                    ),
                  ),
                  _equipoCol(p.visitante.nombre, p.visitante.escudoUrl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _equipoCol(String nombre, String url) {
    return Expanded(
      child: Column(
        children: [
          (url.isEmpty || url == 'null')
              ? const Icon(Icons.shield, size: 45, color: Colors.grey)
              : Image.network(
            url,
            height: 45, width: 45,
            fit: BoxFit.contain,
            errorBuilder: (_,__,___) => const Icon(Icons.shield, size: 45, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
              nombre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
          ),
        ],
      ),
    );
  }
}