enum TipoNoticia {
  equipo,
  general,
}

class Noticia {
  final String id;
  final TipoNoticia tipo;
  final String? equipoId; // Nullable si es general
  final String titulo;
  final String contenido;
  final DateTime fecha;

  Noticia({
    required this.id,
    required this.tipo,
    this.equipoId,
    required this.titulo,
    required this.contenido,
    required this.fecha,
  });
}
