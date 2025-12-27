import 'equipo.dart';

enum TipoUsuario {
  hincha,
  admin,
}

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final TipoUsuario tipo;
  final Equipo? equipoFavorito;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.tipo,
    this.equipoFavorito,
  });
}
