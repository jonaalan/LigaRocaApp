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
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.white24),
                SizedBox(height: 16),
                Text('No hay partidos programados.', style: TextStyle(color: Colors.white54)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          itemCount: partidos.length,
          itemBuilder: (context, index) {
            return _PartidoCard(partido: partidos[index]);
          },
        );
      },
    );
  }
}

class _PartidoCard extends StatelessWidget {
  final Partido partido;

  const _PartidoCard({required this.partido});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM HH:mm');
    final esEnVivo = partido.estado == EstadoPartido.jugando;
    final esFinalizado = partido.estado == EstadoPartido.finalizado;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 4,
      shadowColor: Colors.black26,
      // El color y forma vienen del Theme global
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PartidoDetalleScreen(partido: partido),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              // 1. LOCAL
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        partido.local.nombre,
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _EscudoEquipo(url: partido.local.escudoUrl, size: 30),
                  ],
                ),
              ),

              // 2. CENTRO
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (esEnVivo)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                        child: const Text('VIVO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10, // Fondo translúcido oscuro
                        borderRadius: BorderRadius.circular(8),
                        border: esEnVivo ? Border.all(color: Colors.red.withOpacity(0.5)) : null,
                      ),
                      child: Text(
                        esFinalizado || esEnVivo
                            ? '${partido.golesLocal} - ${partido.golesVisitante}'
                            : 'VS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: esEnVivo ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      esFinalizado ? 'FIN' : dateFormat.format(partido.fecha),
                      style: const TextStyle(fontSize: 10, color: Colors.white54, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              // 3. VISITANTE
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    _EscudoEquipo(url: partido.visitante.escudoUrl, size: 30),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        partido.visitante.nombre,
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EscudoEquipo extends StatelessWidget {
  final String url;
  final double size;

  const _EscudoEquipo({required this.url, this.size = 40});

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.shield, color: Colors.white24, size: size * 0.6),
      );
    }
    return Image.network(
      url,
      height: size,
      width: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Colors.white10,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.broken_image, color: Colors.white24, size: size * 0.6),
        );
      },
    );
  }
}
