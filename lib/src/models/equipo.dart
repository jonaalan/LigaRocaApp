class Equipo {
  final String id;
  final String nombre;
  final String escudoUrl; // URL de la imagen del escudo

  Equipo({
    required this.id,
    required this.nombre,
    required this.escudoUrl,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
