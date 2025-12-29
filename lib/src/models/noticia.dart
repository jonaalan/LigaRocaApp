enum TipoNoticia {
  equipo,
  general,
}

class Noticia {
  final String id;
  final TipoNoticia tipo;
  final String? equipoId;
  final String titulo;
  final String contenido;
  final DateTime fecha;
  final String? imageUrl; // Nuevo campo para la imagen

  Noticia({
    required this.id,
    required this.tipo,
    this.equipoId,
    required this.titulo,
    required this.contenido,
    required this.fecha,
    this.imageUrl,
  });
}
