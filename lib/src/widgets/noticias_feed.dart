import 'package:flutter/material.dart';
import '../models/noticia.dart';
import '../services/firestore_service.dart';
import 'noticia_card.dart';

class NoticiasFeed extends StatelessWidget {
  final String? equipoId;
  final String nombreEquipo;

  const NoticiasFeed({
    super.key,
    required this.equipoId,
    required this.nombreEquipo,
  });

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return CustomScrollView(
      slivers: [
        // Sección 1: Noticias de tu Equipo (Prioritarias)
        if (equipoId != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Novedades de $nombreEquipo',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
            ),
          ),
          StreamBuilder<List<Noticia>>(
            stream: firestoreService.getNoticiasEquipo(equipoId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) return SliverToBoxAdapter(child: Text('Error: ${snapshot.error}'));
              if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));

              final noticias = snapshot.data!;
              if (noticias.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay noticias recientes de tu equipo.'),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => NoticiaCard(noticia: noticias[index]),
                  childCount: noticias.length,
                ),
              );
            },
          ),
        ],

        // Sección 2: Noticias Generales
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'Noticias de la Liga',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        StreamBuilder<List<Noticia>>(
          stream: firestoreService.getNoticiasGenerales(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return SliverToBoxAdapter(child: Text('Error: ${snapshot.error}'));
            if (!snapshot.hasData) return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));

            final noticias = snapshot.data!;

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => NoticiaCard(noticia: noticias[index]),
                childCount: noticias.length,
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}
