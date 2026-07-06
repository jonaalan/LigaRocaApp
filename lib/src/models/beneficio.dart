class Beneficio {
  final String id;
  final String nombre;
  final String rubro;
  final String descuento;
  final String condiciones;
  final String logoUrl;
  bool disponible; // true si puede canjear, false si ya canjeó hoy

  Beneficio({
    required this.id,
    required this.nombre,
    required this.rubro,
    required this.descuento,
    required this.condiciones,
    required this.logoUrl,
    required this.disponible,
  });

  factory Beneficio.fromJson(Map<String, dynamic> json) {
    return Beneficio(
      id: json['id'].toString(),
      nombre: json['nombre'],
      rubro: json['rubro'],
      descuento: json['descuento'],
      condiciones: json['condiciones'],
      logoUrl: json['logoUrl'],
      disponible: json['disponible'],
    );
  }
}