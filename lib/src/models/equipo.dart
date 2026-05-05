class Equipo {
  final String id;
  final String nombre;
  final String escudoUrl; // URL de la imagen del escudo

  Equipo({
    required this.id,
    required this.nombre,
    required this.escudoUrl,
  });

  // ESTA ES LA FUNCIÓN QUE FALTABA PARA LEER DE FIREBASE
  factory Equipo.fromMap(String id, Map<String, dynamic> data) {
    return Equipo(
      id: id,
      nombre: data['nombre'] ?? 'Sin nombre',
      escudoUrl: data['escudoUrl'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equipo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}