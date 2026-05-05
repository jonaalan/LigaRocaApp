import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/noticia.dart';
import '../screens/noticia_detalle_screen.dart';

class NoticiaCard extends StatefulWidget {
  final Noticia noticia;

  const NoticiaCard({super.key, required this.noticia});

  @override
  State<NoticiaCard> createState() => _NoticiaCardState();
}

class _NoticiaCardState extends State<NoticiaCard> {
  bool _isLiked = false;
  final Color _cardColor = const Color(0xFF1E272E);
  final Color _verdeEsmeralda = const Color(0xFF00C853);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NoticiaDetalleScreen(noticia: widget.noticia)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.noticia.imageUrl != null && widget.noticia.imageUrl!.isNotEmpty)
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      widget.noticia.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.black26),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _verdeEsmeralda.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.noticia.tipo == TipoNoticia.equipo ? 'TU EQUIPO' : 'GENERAL',
                          style: TextStyle(color: _verdeEsmeralda, fontWeight: FontWeight.bold, fontSize: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.noticia.titulo,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.noticia.contenido,
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() => _isLiked = !_isLiked);
                    FirebaseFirestore.instance
                        .collection('noticias')
                        .doc(widget.noticia.id)
                        .update({'likes': _isLiked ? FieldValue.increment(1) : FieldValue.increment(-1)});
                  },
                  icon: Icon(_isLiked ? Icons.favorite : Icons.favorite_border, color: _isLiked ? Colors.redAccent : Colors.white60),
                  label: Text('Me gusta', style: TextStyle(color: _isLiked ? Colors.redAccent : Colors.white60)),
                ),
                TextButton.icon(
                  onPressed: () {
                    Share.share('¡Mira esta noticia en la App Chito!\n\n${widget.noticia.titulo}');
                  },
                  icon: const Icon(Icons.share_outlined, color: Colors.white60),
                  label: const Text('Compartir', style: TextStyle(color: Colors.white60)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}