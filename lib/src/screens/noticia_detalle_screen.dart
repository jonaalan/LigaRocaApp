import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/noticia.dart';
import '../models/usuario.dart';
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
    final usuario = await _authService.getUsuarioActual();
    if (mounted && usuario != null && usuario.rol == RolUsuario.admin) {
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
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    // Forzamos colores claros para el texto porque el fondo será oscuro
    const colorTexto = Color(0xFFFDFDF5);

    return Scaffold(
      // Fondo degradado Dark Premium
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF052e16), // Verde muy oscuro
              Color(0xFF0f172a), // Azul grisáceo oscuro
              Color(0xFF000000), // Negro
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent, // Transparente para ver el degradado al contraerse
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45, // Un poco más oscuro para contraste
                  shape: BoxShape.circle,
                ),
                child: const BackButton(color: Colors.white),
              ),
              actions: _isAdmin
                  ? [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          tooltip: 'Editar',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditarNoticiaScreen(noticia: widget.noticia),
                              ),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white),
                          tooltip: 'Eliminar',
                          onPressed: _borrarNoticia,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ]
                  : null,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.noticia.imageUrl != null && widget.noticia.imageUrl!.isNotEmpty
                        ? Image.network(
                            widget.noticia.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
                          )
                        : Container(
                            color: Colors.green[900],
                            child: const Center(child: Icon(Icons.newspaper, size: 80, color: Colors.white24)),
                          ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent],
                          stops: [0.0, 0.4],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.noticia.tipo == TipoNoticia.equipo ? Colors.green[700] : Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.noticia.tipo == TipoNoticia.equipo ? 'TU EQUIPO' : 'GENERAL',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.noticia.titulo,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorTexto,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
                        const SizedBox(width: 4),
                        Text(
                          dateFormat.format(widget.noticia.fecha),
                          style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 32),
                    Text(
                      widget.noticia.contenido,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontSize: 18,
                        color: Colors.white70, // Texto un poco más suave para lectura
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
