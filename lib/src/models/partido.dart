import 'equipo.dart';

class Partido {
  final String id;
  final Equipo local;
  final Equipo visitante;
  final DateTime fecha;
  final int? golesLocal;
  final int? golesVisitante;
  final bool finalizado;

  Partido({
    required this.id,
    required this.local,
    required this.visitante,
    required this.fecha,
    this.golesLocal,
    this.golesVisitante,
    this.finalizado = false,
  });
}
