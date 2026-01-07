import 'package:flutter/material.dart';
import '../models/partido.dart';
import '../models/equipo.dart';
import '../services/firestore_service.dart';

class TablaPosicionesScreen extends StatelessWidget {
  const TablaPosicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Tabla de Posiciones')),
      body: StreamBuilder<List<Partido>>(
        stream: firestoreService.getPartidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final partidos = snapshot.data!;
          final tabla = _calcularTabla(partidos);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Equipo')),
                DataColumn(label: Text('Pts', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('PJ')),
                DataColumn(label: Text('PG')),
                DataColumn(label: Text('PE')),
                DataColumn(label: Text('PP')),
                DataColumn(label: Text('GF')),
                DataColumn(label: Text('GC')),
                DataColumn(label: Text('DG')),
              ],
              rows: tabla.map((fila) {
                return DataRow(cells: [
                  DataCell(Row(
                    children: [
                      if (fila.equipo.escudoUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.network(fila.equipo.escudoUrl, width: 20, height: 20),
                        ),
                      Text(fila.equipo.nombre),
                    ],
                  )),
                  DataCell(Text(fila.puntos.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(fila.pj.toString())),
                  DataCell(Text(fila.pg.toString())),
                  DataCell(Text(fila.pe.toString())),
                  DataCell(Text(fila.pp.toString())),
                  DataCell(Text(fila.gf.toString())),
                  DataCell(Text(fila.gc.toString())),
                  DataCell(Text(fila.dg.toString())),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  List<_FilaTabla> _calcularTabla(List<Partido> partidos) {
    final Map<String, _FilaTabla> tabla = {};

    for (var partido in partidos) {
      if (partido.estado != EstadoPartido.finalizado) continue;

      // Asegurar que existan las entradas en la tabla
      tabla.putIfAbsent(partido.local.id, () => _FilaTabla(partido.local));
      tabla.putIfAbsent(partido.visitante.id, () => _FilaTabla(partido.visitante));

      final local = tabla[partido.local.id]!;
      final visitante = tabla[partido.visitante.id]!;

      local.pj++;
      visitante.pj++;
      local.gf += partido.golesLocal;
      local.gc += partido.golesVisitante;
      visitante.gf += partido.golesVisitante;
      visitante.gc += partido.golesLocal;

      if (partido.golesLocal > partido.golesVisitante) {
        local.pg++;
        local.puntos += 3;
        visitante.pp++;
      } else if (partido.golesLocal < partido.golesVisitante) {
        visitante.pg++;
        visitante.puntos += 3;
        local.pp++;
      } else {
        local.pe++;
        local.puntos += 1;
        visitante.pe++;
        visitante.puntos += 1;
      }
    }

    final lista = tabla.values.toList();
    // Ordenar: Puntos DESC, Diferencia de Gol DESC, Goles a Favor DESC
    lista.sort((a, b) {
      if (b.puntos != a.puntos) return b.puntos.compareTo(a.puntos);
      if (b.dg != a.dg) return b.dg.compareTo(a.dg);
      return b.gf.compareTo(a.gf);
    });

    return lista;
  }
}

class _FilaTabla {
  final Equipo equipo;
  int puntos = 0;
  int pj = 0;
  int pg = 0;
  int pe = 0;
  int pp = 0;
  int gf = 0;
  int gc = 0;

  _FilaTabla(this.equipo);

  int get dg => gf - gc;
}
