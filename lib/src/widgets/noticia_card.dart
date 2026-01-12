import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/noticia.dart';
import '../screens/noticia_detalle_screen.dart';

class NoticiaCard extends StatelessWidget {
  final Noticia noticia;

  const NoticiaCard({super.key, required this.noticia});

  String _getFechaFormateada(DateTime fecha) {
    return DateFormat('dd MMM', 'es').format(fecha).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color, // Usa el color del tema (Gris oscuro)
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Sombra más oscura
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _abrirDetalle(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. IMAGEN
                if (noticia.imageUrl != null && noticia.imageUrl!.isNotEmpty)
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      noticia.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.image_not_supported, color: Colors.white24),
                      ),
                    ),
                  ),

                // 2. CONTENIDO
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fecha
                      Text(
                        DateFormat('dd/MM/yyyy').format(noticia.fecha),
                        style: TextStyle(
                          color: theme.colorScheme.primary, // Verde neón
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Título
                      Text(
                        noticia.titulo,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Texto
                      Text(
                        noticia.contenido,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // 3. ACCIONES
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, size: 22),
                        color: Colors.white54,
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 22),
                        color: Colors.white54,
                        onPressed: () {},
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _abrirDetalle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoticiaDetalleScreen(noticia: noticia)),
    );
  }
}
