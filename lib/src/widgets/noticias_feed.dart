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

    return RefreshIndicator(
      onRefresh: () async {
        // Como usamos Streams, el refresh es visual, pero útil para forzar repintado si fuera necesario
        await Future.delayed(const Duration(seconds: 1));
      },
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 8)), // Pequeño margen superior

          // Sección 1: Noticias de tu Equipo (Sin título, solo las tarjetas)
          if (equipoId != null)
            StreamBuilder<List<Noticia>>(
              stream: firestoreService.getNoticiasEquipo(equipoId!),
              builder: (context, snapshot) {
                // Si hay error o carga, no mostramos nada para no ensuciar la UI, o un loader discreto
                if (snapshot.hasError || !snapshot.hasData) return const SliverToBoxAdapter(child: SizedBox.shrink());

                final noticias = snapshot.data!;
                if (noticias.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => NoticiaCard(noticia: noticias[index]),
                    childCount: noticias.length,
                  ),
                );
              },
            ),

          // Sección 2: Noticias Generales (A continuación, sin separación brusca)
          StreamBuilder<List<Noticia>>(
            stream: firestoreService.getNoticiasGenerales(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const SliverToBoxAdapter(child: SizedBox.shrink());
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              final noticias = snapshot.data!;

              if (noticias.isEmpty) {
                 return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No hay noticias para mostrar', style: TextStyle(color: Colors.grey))),
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

          const SliverToBoxAdapter(child: SizedBox(height: 80)), // Espacio final para que el FAB no tape nada
        ],
      ),
    );
  }
}
