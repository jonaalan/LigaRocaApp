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

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final userData = await _authService.getUserData();
    if (mounted && userData != null && userData['rol'] == 'admin') {
      setState(() {
        _isAdmin = true;
      });
    }
  }

  Future<void> _borrarNoticia() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Noticia'),
        content: const Text('¿Estás seguro de que quieres eliminar esta noticia?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.borrarNoticia(widget.noticia.id);
      if (mounted) Navigator.pop(context); // Volver al feed
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: _isAdmin
                ? [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Editar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditarNoticiaScreen(noticia: widget.noticia),
                          ),
                        ).then((_) => setState(() {})); // Recargar al volver
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Eliminar',
                      onPressed: _borrarNoticia,
                    ),
                  ]
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: widget.noticia.imageUrl != null && widget.noticia.imageUrl!.isNotEmpty
                  ? Image.network(
                      widget.noticia.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                    )
                  : Container(
                      color: Colors.green[800],
                      child: const Center(child: Icon(Icons.newspaper, size: 80, color: Colors.white54)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.noticia.tipo == TipoNoticia.equipo ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.noticia.tipo == TipoNoticia.equipo ? 'TU EQUIPO' : 'GENERAL',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Título
                  Text(
                    widget.noticia.titulo,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Fecha
                  Text(
                    dateFormat.format(widget.noticia.fecha),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  
                  // Contenido
                  Text(
                    widget.noticia.contenido,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
