class Publicidad {
  final String id;
  final String imageUrl;
  final String? linkUrl; // Opcional: si quieres que al tocar vaya a una web
  final bool activa;

  Publicidad({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.activa = true,
  });
}
