import 'equipo.dart';

enum EstadoPartido {
  pendiente,
  jugando,
  finalizado,
}

enum TipoEvento {
  gol,
  amarilla,
  roja,
  cambio,
}

class JugadorFormacion {
  final String nombre;
  final int camiseta;
  final bool esTitular;

  JugadorFormacion({
    required this.nombre,
    required this.camiseta,
    this.esTitular = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'camiseta': camiseta,
      'esTitular': esTitular,
    };
  }

  factory JugadorFormacion.fromMap(Map<String, dynamic> map) {
    return JugadorFormacion(
      nombre: map['nombre'] ?? '',
      camiseta: map['camiseta'] ?? 0,
      esTitular: map['esTitular'] ?? true,
    );
  }
}

class EventoPartido {
  final String id;
  final TipoEvento tipo;
  final int minuto;
  final String jugadorNombre;
  final int camiseta;
  final String equipoId;
  final String? jugadorSale;
  final int? camisetaSale;

  EventoPartido({
    required this.id,
    required this.tipo,
    required this.minuto,
    required this.jugadorNombre,
    required this.camiseta,
    required this.equipoId,
    this.jugadorSale,
    this.camisetaSale,
  });
}

class Partido {
  final String id;
  final Equipo local;
  final Equipo visitante;
  final DateTime fecha;
  final int golesLocal;
  final int golesVisitante;
  final EstadoPartido estado;
  final DateTime? tiempoInicio;
  final List<EventoPartido> eventos;
  
  // Nuevos campos para formaciones
  final List<JugadorFormacion> formacionLocal;
  final List<JugadorFormacion> formacionVisitante;

  Partido({
    required this.id,
    required this.local,
    required this.visitante,
    required this.fecha,
    this.golesLocal = 0,
    this.golesVisitante = 0,
    this.estado = EstadoPartido.pendiente,
    this.tiempoInicio,
    this.eventos = const [],
    this.formacionLocal = const [],
    this.formacionVisitante = const [],
  });
  
  bool get finalizado => estado == EstadoPartido.finalizado;
}
