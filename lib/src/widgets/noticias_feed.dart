import 'package:flutter/material.dart';
import '../models/noticia.dart';
import '../services/firestore_service.dart';
import 'noticia_card.dart'; // <--- Esto importa la clase del archivo anterior

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
    final Color verdeEsmeralda = const Color(0xFF00C853);

    return CustomScrollView(
      slivers: [
        if (equipoId != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'NOVEDADES DE $nombreEquipo'.toUpperCase(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: verdeEsmeralda, letterSpacing: 2),
              ),
            ),
          ),
          StreamBuilder<List<Noticia>>(
            stream: firestoreService.getNoticiasEquipo(equipoId!),
            builder: (context, snapshot) {
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
        ],
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: const Text(
              'NOTICIAS DE LA LIGA',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 2),
            ),
          ),
        ),
        StreamBuilder<List<Noticia>>(
          stream: firestoreService.getNoticiasGenerales(),
          builder: (context, snapshot) {
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
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}