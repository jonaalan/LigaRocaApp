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
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartidoDetalleScreen(partido: partido),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Fecha y Estado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dateFormat.format(partido.fecha),
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                          if (partido.estado == EstadoPartido.jugando)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                child: const Text('EN VIVO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Equipos y Resultado
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Local
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _EscudoEquipo(url: partido.local.escudoUrl),
                                const SizedBox(height: 4),
                                Text(
                                  partido.local.nombre, 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          
                          // Marcador Central
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: partido.estado == EstadoPartido.jugando 
                                    ? Colors.red.withOpacity(0.1) 
                                    : (partido.finalizado ? Colors.black87 : Colors.grey[200]),
                                borderRadius: BorderRadius.circular(8),
                                border: partido.estado == EstadoPartido.jugando ? Border.all(color: Colors.red) : null,
                              ),
                              child: Center(
                                child: Text(
                                  partido.estado == EstadoPartido.pendiente
                                      ? 'VS'
                                      : '${partido.golesLocal} - ${partido.golesVisitante}',
                                  style: TextStyle(
                                    color: partido.finalizado ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Visitante
                          Expanded(
                            flex: 3,
                            child: Column(
                              children: [
                                _EscudoEquipo(url: partido.visitante.escudoUrl),
                                const SizedBox(height: 4),
                                Text(
                                  partido.visitante.nombre, 
                                  textAlign: TextAlign.center, 
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
              ),
            );
          },
        );
      },
    );
  }
}

class _EscudoEquipo extends StatelessWidget {
  final String url;

  const _EscudoEquipo({required this.url});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return const CircleAvatar(
        radius: 20, // Reduje un poco el tamaño para evitar overflow vertical
        backgroundColor: Colors.grey,
        child: Icon(Icons.shield, color: Colors.white, size: 20),
      );
    }
    return Image.network(
      url,
      height: 40, // Tamaño fijo controlado
      width: 40,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return const CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey,
          child: Icon(Icons.error, color: Colors.white, size: 20),
        );
      },
    );
  }
}
