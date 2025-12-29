import 'equipo.dart';

enum RolUsuario {
  hincha,
  admin,
}

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final RolUsuario rol;
  final String? equipoFavoritoId;
  final String? equipoFavoritoNombre;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.equipoFavoritoId,
    this.equipoFavoritoNombre,
  });

  factory Usuario.fromMap(String id, Map<String, dynamic> map) {
    return Usuario(
      id: id,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      rol: map['rol'] == 'admin' ? RolUsuario.admin : RolUsuario.hincha,
      equipoFavoritoId: map['equipoFavoritoId'],
      equipoFavoritoNombre: map['equipoFavoritoNombre'],
    );
  }
}
