import 'package:flutter/material.dart';
import '../models/equipo.dart';
import '../models/partido.dart';
import '../services/firestore_service.dart';

class TablaPosicionesScreen extends StatefulWidget {
  const TablaPosicionesScreen({super.key});

  @override
  State<TablaPosicionesScreen> createState() => _TablaPosicionesScreenState();
}

class _TablaPosicionesScreenState extends State<TablaPosicionesScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  // --- PALETA DARK ESMERALDA (Cambiado de const a final) ---
  final Color verdeEsmeralda = const Color(0xFF00C853);
  final Color negroProfundo = const Color(0xFF000000);
  final Color verdeMuyOscuro = const Color(0xFF051209);
  final Color cardColor = const Color(0xFF1E272E);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Partido>>(
      stream: _firestoreService.getPartidos(),
      builder: (context, snapshotPartidos) {
        return StreamBuilder<List<Equipo>>(
          stream: _firestoreService.getEquipos(),
          builder: (context, snapshotEquipos) {
            if (!snapshotPartidos.hasData || !snapshotEquipos.hasData) {
              // QUITADO 'const' porque usa una variable final
              return Center(child: CircularProgressIndicator(color: verdeEsmeralda));
            }

            final partidos = snapshotPartidos.data!;
            final equipos = snapshotEquipos.data!;

            final categorias = partidos.map((p) => p.categoria).toSet().toList()..sort();

            if (categorias.isEmpty) {
              return const Center(child: Text("No hay partidos para calcular posiciones", style: TextStyle(color: Colors.white54)));
            }

            return DefaultTabController(
              length: categorias.length,
              child: Column(
                children: [
                  Container(
                    color: verdeMuyOscuro,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: verdeEsmeralda,
                      unselectedLabelColor: Colors.white38,
                      indicatorColor: verdeEsmeralda,
                      tabs: categorias.map((c) => Tab(text: c.toUpperCase())).toList(),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: categorias.map((cat) {
                        final tabla = _calcularTablaPorCategoria(equipos, partidos, cat);

                        return RefreshIndicator(
                          onRefresh: () async => setState(() {}),
                          color: verdeEsmeralda,
                          child: _buildTabla(tabla),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabla(List<Map<String, dynamic>> tabla) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 15,
            columns: [
              _col('#', numeric: false),
              _col('EQUIPO', numeric: false),
              _col('PJ'),
              _col('DG'),
              _col('PTS', isEsmeralda: true),
            ],
            rows: tabla.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}', style: const TextStyle(color: Colors.white38, fontSize: 12))),
                  DataCell(
                    Row(
                      children: [
                        if (item['escudoUrl'] != null && item['escudoUrl'].isNotEmpty)
                          Image.network(item['escudoUrl'], width: 24, height: 24,
                              errorBuilder: (_,__,___)=> const Icon(Icons.shield, size: 24, color: Colors.white10))
                        else
                          const Icon(Icons.shield, size: 24, color: Colors.white10),
                        const SizedBox(width: 10),
                        Text(item['nombre'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  DataCell(Text('${item['pj']}', style: const TextStyle(color: Colors.white70))),
                  DataCell(Text('${item['dg']}', style: TextStyle(
                      color: item['dg'] > 0 ? Colors.blueAccent : (item['dg'] < 0 ? Colors.redAccent : Colors.white38)
                  ))),
                  // QUITADO 'const' del TextStyle
                  DataCell(Text('${item['pts']}', style: TextStyle(color: verdeEsmeralda, fontWeight: FontWeight.bold, fontSize: 16))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataColumn _col(String label, {bool numeric = true, bool isEsmeralda = false}) {
    return DataColumn(
      numeric: numeric,
      label: Text(label, style: TextStyle(
        color: isEsmeralda ? verdeEsmeralda : Colors.white54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      )),
    );
  }

  List<Map<String, dynamic>> _calcularTablaPorCategoria(List<Equipo> equipos, List<Partido> partidos, String categoria) {
    List<Map<String, dynamic>> lista = [];

    for (var e in equipos) {
      int pj = 0, pts = 0, gf = 0, gc = 0;
      bool jugoEnCategoria = false;

      for (var p in partidos) {
        if (!p.finalizado || p.categoria != categoria) continue;

        if (p.local.nombre == e.nombre) {
          jugoEnCategoria = true;
          pj++;
          gf += p.golesLocal;
          gc += p.golesVisitante;
          if (p.golesLocal > p.golesVisitante) pts += 3;
          else if (p.golesLocal == p.golesVisitante) pts += 1;
        } else if (p.visitante.nombre == e.nombre) {
          jugoEnCategoria = true;
          pj++;
          gf += p.golesVisitante;
          gc += p.golesLocal;
          if (p.golesVisitante > p.golesLocal) pts += 3;
          else if (p.golesLocal == p.golesVisitante) pts += 1;
        }
      }

      if (jugoEnCategoria) {
        lista.add({
          'nombre': e.nombre,
          'escudoUrl': e.escudoUrl,
          'pj': pj,
          'dg': gf - gc,
          'pts': pts,
        });
      }
    }

    lista.sort((a, b) {
      int cmp = b['pts'].compareTo(a['pts']);
      if (cmp == 0) return b['dg'].compareTo(a['dg']);
      return cmp;
    });
    return lista;
  }
}