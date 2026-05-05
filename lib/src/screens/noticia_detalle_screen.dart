import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/noticia.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'admin/editar_noticia_screen.dart';

class NoticiaDetalleScreen extends StatefulWidget {
  final Noticia noticia;

  const NoticiaDetalleScreen({super.key, required this.noticia});

  @override
  State<NoticiaDetalleScreen> createState() => _NoticiaDetalleScreenState();
}

class _NoticiaDetalleScreenState extends State<NoticiaDetalleScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isAdmin = false;

  // --- PALETA DARK ESMERALDA ---
  final Color _verdeEsmeralda = const Color(0xFF00C853);
  final Color _negroProfundo = const Color(0xFF000000);
  final Color _verdeMuyOscuro = const Color(0xFF051209);
  final Color _cardColor = const Color(0xFF1E272E);

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final userData = await _authService.getUserData();
    if (mounted && userData != null && userData['rol'] == 'admin') {
      setState(() => _isAdmin = true);
    }
  }

  Future<void> _borrarNoticia() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: const Text('Eliminar Noticia', style: TextStyle(color: Colors.white)),
        content: const Text('¿Estás seguro de que quieres eliminar esta noticia?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCELAR')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('ELIMINAR', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.borrarNoticia(widget.noticia.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: _negroProfundo,
      body: CustomScrollView(
        slivers: [
          // BARRA SUPERIOR CON IMAGEN
          SliverAppBar(
            expandedHeight: 350.0,
            floating: false,
            pinned: true,
            backgroundColor: _verdeMuyOscuro,
            leading: CircleAvatar(
              backgroundColor: Colors.black38,
              child: const BackButton(color: Colors.white),
            ),
            actions: _isAdmin ? [
              CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditarNoticiaScreen(noticia: widget.noticia)),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                  onPressed: _borrarNoticia,
                ),
              ),
              const SizedBox(width: 16),
            ] : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.noticia.imageUrl != null && widget.noticia.imageUrl!.isNotEmpty
                      ? Image.network(widget.noticia.imageUrl!, fit: BoxFit.cover)
                      : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_verdeEsmeralda, _verdeMuyOscuro],
                      ),
                    ),
                    child: const Icon(Icons.newspaper, size: 100, color: Colors.white24),
                  ),
                  // Degradado inferior para que el texto se funda con el fondo
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                        stops: [0.6, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // CUERPO DE LA NOTICIA
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: _negroProfundo,
                // Un ligero degradado para suavizar la transición
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_negroProfundo, _verdeMuyOscuro.withOpacity(0.2)],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta de Tipo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _verdeEsmeralda.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _verdeEsmeralda.withOpacity(0.5)),
                    ),
                    child: Text(
                      widget.noticia.tipo == TipoNoticia.equipo ? 'TU EQUIPO' : 'LIGA ROCA',
                      style: TextStyle(color: _verdeEsmeralda, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    widget.noticia.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Fecha y Hora
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: _verdeEsmeralda),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(widget.noticia.fecha),
                        style: const TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 30),

                  // Contenido de la Noticia
                  Text(
                    widget.noticia.contenido,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      height: 1.8,
                      fontSize: 17,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 100), // Espacio extra al final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}