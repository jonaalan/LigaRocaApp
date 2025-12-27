import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/partido.dart';
import '../services/firestore_service.dart';

class FixtureList extends StatelessWidget {
  const FixtureList({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final dateFormat = DateFormat('dd/MM HH:mm');

    return StreamBuilder<List<Partido>>(
      stream: firestoreService.getPartidos(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final partidos = snapshot.data!;
        if (partidos.isEmpty) {
          return const Center(child: Text('No hay partidos programados.'));
        }

        return ListView.builder(
          itemCount: partidos.length,
          itemBuilder: (context, index) {
            final partido = partidos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      dateFormat.format(partido.fecha),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Local
                        Expanded(
                          child: Column(
                            children: [
                              Text(partido.local.nombre, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                        // Resultado o VS
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: partido.finalizado ? Colors.black87 : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            partido.finalizado
                                ? '${partido.golesLocal} - ${partido.golesVisitante}'
                                : 'VS',
                            style: TextStyle(
                              color: partido.finalizado ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        // Visitante
                        Expanded(
                          child: Column(
                            children: [
                              Text(partido.visitante.nombre, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (partido.finalizado)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Finalizado', style: TextStyle(color: Colors.green[700], fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
