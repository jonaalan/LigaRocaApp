import 'equipo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoPartido { pendiente, jugando, finalizado }
enum TipoEvento { gol, amarilla, roja, cambio }

class JugadorFormacion {
  final String nombre;
  final int camiseta;
  final bool esTitular;
  JugadorFormacion({required this.nombre, required this.camiseta, this.esTitular = true});
  Map<String, dynamic> toMap() => {'nombre': nombre, 'camiseta': camiseta, 'esTitular': esTitular};
}

class EventoPartido {
  final String id;
  final TipoEvento tipo;
  final int minuto;
  final String jugadorNombre;
  final int camiseta;
  final String equipoId;
  EventoPartido({required this.id, required this.tipo, required this.minuto, required this.jugadorNombre, required this.camiseta, required this.equipoId});
}

class Partido {
  final String id;
  final Equipo local;
  final Equipo visitante;
  final DateTime fecha;
  final int golesLocal;
  final int golesVisitante;
  final EstadoPartido estado;
  final String numeroFecha;
  final String categoria;

  Partido({
    required this.id, required this.local, required this.visitante, required this.fecha,
    this.golesLocal = 0, this.golesVisitante = 0, this.estado = EstadoPartido.pendiente,
    this.numeroFecha = "1",
    this.categoria = 'Primera',
  });

  bool get finalizado => estado == EstadoPartido.finalizado;

  factory Partido.fromFirestore(Map<String, dynamic> data, String id) {
    String estadoStr = (data['estado'] ?? 'pendiente').toString().toLowerCase();
    EstadoPartido estadoFinal = EstadoPartido.pendiente;
    if (estadoStr.contains('jugando')) estadoFinal = EstadoPartido.jugando;
    if (estadoStr.contains('finalizado')) estadoFinal = EstadoPartido.finalizado;

    return Partido(
      id: id,
      local: Equipo(
        id: data['localId'] ?? '',
        nombre: data['localNombre'] ?? data['local']?['nombre'] ?? 'Local',
        escudoUrl: data['localEscudo'] ?? data['local']?['escudoUrl'] ?? '',
      ),
      visitante: Equipo(
        id: data['visitanteId'] ?? '',
        nombre: data['visitanteNombre'] ?? data['visitante']?['nombre'] ?? 'Visitante',
        escudoUrl: data['visitanteEscudo'] ?? data['visitante']?['escudoUrl'] ?? '',
      ),
      fecha: (data['fecha'] as Timestamp).toDate(),
      golesLocal: int.tryParse(data['golesLocal'].toString()) ?? 0,
      golesVisitante: int.tryParse(data['golesVisitante'].toString()) ?? 0,
      estado: estadoFinal,
      numeroFecha: data['numeroFecha']?.toString() ?? '1',
      categoria: data['categoria'] ?? 'Primera',
    );
  }
}