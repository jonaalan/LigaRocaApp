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

class EventoPartido {
  final String id;
  final TipoEvento tipo;
  final int minuto;
  final String jugadorNombre; // Jugador principal (o el que entra en un cambio)
  final int camiseta;
  final String equipoId;
  
  // Campos extra para cambios
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
  });
  
  bool get finalizado => estado == EstadoPartido.finalizado;
}
