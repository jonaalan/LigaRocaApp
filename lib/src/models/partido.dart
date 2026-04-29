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
  factory JugadorFormacion.fromMap(Map<String, dynamic> map) => JugadorFormacion(
      nombre: map['nombre'] ?? '',
      camiseta: map['camiseta'] ?? 0,
      esTitular: map['esTitular'] ?? true
  );
}

class EventoPartido {
  final String id; final TipoEvento tipo; final int minuto; final String jugadorNombre; final int camiseta; final String equipoId; final String? jugadorSale; final int? camisetaSale;
  EventoPartido({required this.id, required this.tipo, required this.minuto, required this.jugadorNombre, required this.camiseta, required this.equipoId, this.jugadorSale, this.camisetaSale});
}

class Partido {
  final String id;
  final Equipo local;
  final Equipo visitante;
  final DateTime fecha;
  final int golesLocal;
  final int golesVisitante;
  final EstadoPartido estado;
  final int numeroFecha;
  final String categoria;
  final DateTime? tiempoInicio;
  final List<EventoPartido> eventos;
  final List<JugadorFormacion> formacionLocal;
  final List<JugadorFormacion> formacionVisitante;

  Partido({
    required this.id, required this.local, required this.visitante, required this.fecha,
    this.golesLocal = 0, this.golesVisitante = 0, this.estado = EstadoPartido.pendiente,
    this.numeroFecha = 0, this.categoria = 'Primera', this.tiempoInicio,
    this.eventos = const [], this.formacionLocal = const [], this.formacionVisitante = const [],
  });

  bool get finalizado => estado == EstadoPartido.finalizado;

  factory Partido.fromFirestore(Map<String, dynamic> data, String id) {
    // REGLA DE ORO: Si no encuentra el nombre nuevo (localNombre), busca el viejo (local -> nombre)

    // --- LÓGICA PARA LOCAL ---
    String nombreL = data['localNombre'] ?? '';
    String escudoL = data['localEscudo'] ?? '';

    if (nombreL.isEmpty && data['local'] != null) {
      nombreL = data['local']['nombre'] ?? 'Local';
      escudoL = data['local']['escudoUrl'] ?? '';
    }

    // --- LÓGICA PARA VISITANTE ---
    String nombreV = data['visitanteNombre'] ?? '';
    String escudoV = data['visitanteEscudo'] ?? '';

    if (nombreV.isEmpty && data['visitante'] != null) {
      nombreV = data['visitante']['nombre'] ?? 'Visitante';
      escudoV = data['visitante']['escudoUrl'] ?? '';
    }

    return Partido(
      id: id,
      local: Equipo(
        id: data['localId'] ?? '',
        nombre: nombreL.isEmpty ? 'Local' : nombreL,
        escudoUrl: escudoL,
      ),
      visitante: Equipo(
        id: data['visitanteId'] ?? '',
        nombre: nombreV.isEmpty ? 'Visitante' : nombreV,
        escudoUrl: escudoV,
      ),
      fecha: (data['fecha'] as Timestamp).toDate(),
      golesLocal: data['golesLocal'] ?? 0,
      golesVisitante: data['golesVisitante'] ?? 0,
      estado: EstadoPartido.values.firstWhere(
              (e) => e.toString() == (data['estado'] ?? 'EstadoPartido.pendiente'),
          orElse: () => EstadoPartido.pendiente
      ),
      numeroFecha: int.tryParse(data['numeroFecha'].toString()) ?? 0,
      categoria: data['categoria'] ?? 'Primera',
      tiempoInicio: data['tiempoInicio'] != null ? (data['tiempoInicio'] as Timestamp).toDate() : null,
      eventos: [], // Se cargan por separado si es necesario
      formacionLocal: [],
      formacionVisitante: [],
    );
  }
}