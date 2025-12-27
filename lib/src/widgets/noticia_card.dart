import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/noticia.dart';

class NoticiaCard extends StatelessWidget {
  final Noticia noticia;

  const NoticiaCard({super.key, required this.noticia});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etiqueta de tipo de noticia
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: noticia.tipo == TipoNoticia.equipo
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                noticia.tipo == TipoNoticia.equipo ? 'TU EQUIPO' : 'GENERAL',
                style: TextStyle(
                  color: noticia.tipo == TipoNoticia.equipo ? Colors.green : Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              noticia.titulo,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              noticia.contenido,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Text(
              dateFormat.format(noticia.fecha),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
