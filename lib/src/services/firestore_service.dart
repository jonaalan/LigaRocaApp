import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/noticia.dart';
import '../models/equipo.dart';
import '../models/partido.dart';
import '../models/publicidad.dart'; // Importamos el modelo

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- EQUIPOS ---
  Stream<List<Equipo>> getEquipos() {
    return _db.collection('equipos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Equipo(
          id: doc.id,
          nombre: data['nombre'] ?? 'Sin Nombre',
          escudoUrl: data['escudoUrl'] ?? '',
        );
      }).toList();
    });
  }

  Future<void> crearEquipo(String nombre, String escudoUrl) async {
    await _db.collection('equipos').add({
      'nombre': nombre,
      'escudoUrl': escudoUrl,
    });
  }

  Future<void> actualizarEquipo(String id, String nombre, String escudoUrl) async {
    await _db.collection('equipos').doc(id).update({
      'nombre': nombre,
      'escudoUrl': escudoUrl,
    });
    
    final partidosLocal = await _db.collection('partidos').where('localId', isEqualTo: id).get();
    for (var doc in partidosLocal.docs) {
      await doc.reference.update({'localNombre': nombre, 'localEscudo': escudoUrl});
    }
    final partidosVisitante = await _db.collection('partidos').where('visitanteId', isEqualTo: id).get();
    for (var doc in partidosVisitante.docs) {
      await doc.reference.update({'visitanteNombre': nombre, 'visitanteEscudo': escudoUrl});
    }
  }

  // --- PUBLICIDAD ---
  // CORREGIDO: Ahora devuelve Stream<List<Publicidad>> mapeado
  Stream<List<Publicidad>> getPublicidades() {
    return _db.collection('publicidades').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Publicidad(
          id: doc.id,
          imageUrl: data['imageUrl'] ?? '',
          linkUrl: data['linkUrl'],
          activa: data['activa'] ?? true,
        );
      }).toList();
    });
  }

  // CORREGIDO: Acepta String? para linkUrl
  Future<void> crearPublicidad(String imageUrl, String? linkUrl) async {
    await _db.collection('publicidades').add({
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'activa': true,
    });
  }

  Future<void> borrarPublicidad(String id) async {
    await _db.collection('publicidades').doc(id).delete();
  }

  // --- NOTICIAS ---
  Stream<List<Noticia>> getNoticiasGenerales() {
    return _db
        .collection('noticias')
        .where('tipo', isEqualTo: 'general')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(_mapQueryToNoticias);
  }

  Stream<List<Noticia>> getNoticiasEquipo(String equipoId) {
    return _db
        .collection('noticias')
        .where('tipo', isEqualTo: 'equipo')
        .where('equipoId', isEqualTo: equipoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(_mapQueryToNoticias);
  }

  Stream<List<Noticia>> getTodasLasNoticias() {
    return _db
        .collection('noticias')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(_mapQueryToNoticias);
  }

  Future<void> crearNoticia({
    required String titulo,
    required String contenido,
    required TipoNoticia tipo,
    String? equipoId,
    String? imageUrl,
  }) async {
    await _db.collection('noticias').add({
      'titulo': titulo,
      'contenido': contenido,
      'tipo': tipo == TipoNoticia.general ? 'general' : 'equipo',
      'equipoId': equipoId,
      'imageUrl': imageUrl,
      'fecha': FieldValue.serverTimestamp(),
    });
  }

  Future<void> actualizarNoticia(String id, {
    required String titulo,
    required String contenido,
    required TipoNoticia tipo,
    String? equipoId,
    String? imageUrl,
  }) async {
    await _db.collection('noticias').doc(id).update({
      'titulo': titulo,
      'contenido': contenido,
      'tipo': tipo == TipoNoticia.general ? 'general' : 'equipo',
      'equipoId': equipoId,
      'imageUrl': imageUrl,
    });
  }

  Future<void> borrarNoticia(String id) async {
    await _db.collection('noticias').doc(id).delete();
  }

  List<Noticia> _mapQueryToNoticias(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Noticia(
        id: doc.id,
        tipo: data['tipo'] == 'general' ? TipoNoticia.general : TipoNoticia.equipo,
        equipoId: data['equipoId'],
        titulo: data['titulo'] ?? 'Sin Título',
        contenido: data['contenido'] ?? '',
        fecha: data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : DateTime.now(),
        imageUrl: data['imageUrl'],
      );
    }).toList();
  }

  // --- PARTIDOS ---
  Stream<List<Partido>> getPartidos() {
    return _db.collection('partidos').orderBy('fecha').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        
        List<EventoPartido> eventos = [];
        if (data['eventos'] != null) {
          eventos = List.from(data['eventos']).map<EventoPartido>((e) {
            final map = e as Map<String, dynamic>;
            return EventoPartido(
              id: map['id'] ?? '',
              tipo: TipoEvento.values.firstWhere((t) => t.toString() == map['tipo'], orElse: () => TipoEvento.gol),
              minuto: map['minuto'] ?? 0,
              jugadorNombre: map['jugadorNombre'] ?? '',
              camiseta: map['camiseta'] ?? 0,
              equipoId: map['equipoId'] ?? '',
              jugadorSale: map['jugadorSale'],
              camisetaSale: map['camisetaSale'],
            );
          }).toList();
        }

        List<JugadorFormacion> formacionLocal = [];
        if (data['formacionLocal'] != null) {
          formacionLocal = List.from(data['formacionLocal']).map((e) => JugadorFormacion.fromMap(e as Map<String, dynamic>)).toList();
        }

        List<JugadorFormacion> formacionVisitante = [];
        if (data['formacionVisitante'] != null) {
          formacionVisitante = List.from(data['formacionVisitante']).map((e) => JugadorFormacion.fromMap(e as Map<String, dynamic>)).toList();
        }

        EstadoPartido estado = EstadoPartido.pendiente;
        if (data['estado'] != null) {
          estado = EstadoPartido.values.firstWhere((e) => e.toString() == data['estado'], orElse: () => EstadoPartido.pendiente);
        } else if (data['finalizado'] == true) {
          estado = EstadoPartido.finalizado;
        }

        return Partido(
          id: doc.id,
          local: Equipo(
            id: data['localId'] ?? '',
            nombre: data['localNombre'] ?? 'Local',
            escudoUrl: data['localEscudo'] ?? ''
          ),
          visitante: Equipo(
            id: data['visitanteId'] ?? '',
            nombre: data['visitanteNombre'] ?? 'Visitante',
            escudoUrl: data['visitanteEscudo'] ?? ''
          ),
          fecha: data['fecha'] != null ? (data['fecha'] as Timestamp).toDate() : DateTime.now(),
          golesLocal: data['golesLocal'] ?? 0,
          golesVisitante: data['golesVisitante'] ?? 0,
          estado: estado,
          tiempoInicio: data['tiempoInicio'] != null ? (data['tiempoInicio'] as Timestamp).toDate() : null,
          eventos: eventos,
          formacionLocal: formacionLocal,
          formacionVisitante: formacionVisitante,
        );
      }).toList();
    });
  }

  Future<void> crearPartido({
    required Equipo local,
    required Equipo visitante,
    required DateTime fecha,
  }) async {
    await _db.collection('partidos').add({
      'localId': local.id,
      'localNombre': local.nombre,
      'localEscudo': local.escudoUrl,
      'visitanteId': visitante.id,
      'visitanteNombre': visitante.nombre,
      'visitanteEscudo': visitante.escudoUrl,
      'fecha': Timestamp.fromDate(fecha),
      'estado': EstadoPartido.pendiente.toString(),
      'golesLocal': 0,
      'golesVisitante': 0,
      'eventos': [],
      'formacionLocal': [],
      'formacionVisitante': [],
    });
  }

  Future<void> actualizarPartido(String id, {
    required int golesLocal,
    required int golesVisitante,
    required bool finalizado,
    DateTime? fecha,
  }) async {
    final Map<String, dynamic> data = {
      'golesLocal': golesLocal,
      'golesVisitante': golesVisitante,
      'finalizado': finalizado,
      'estado': finalizado ? EstadoPartido.finalizado.toString() : EstadoPartido.pendiente.toString(),
    };
    if (fecha != null) {
      data['fecha'] = Timestamp.fromDate(fecha);
    }
    await _db.collection('partidos').doc(id).update(data);
  }

  Future<void> borrarPartido(String id) async {
    await _db.collection('partidos').doc(id).delete();
  }

  Future<void> iniciarPartido(String id) async {
    await _db.collection('partidos').doc(id).update({
      'estado': EstadoPartido.jugando.toString(),
      'tiempoInicio': FieldValue.serverTimestamp(),
    });
  }

  Future<void> finalizarPartido(String id) async {
    await _db.collection('partidos').doc(id).update({
      'estado': EstadoPartido.finalizado.toString(),
    });
  }

  Future<void> agregarEvento(String partidoId, EventoPartido evento, bool esGolLocal, bool esGolVisitante) async {
    final docRef = _db.collection('partidos').doc(partidoId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      List<dynamic> eventos = data['eventos'] ?? [];
      
      final eventoMap = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'tipo': evento.tipo.toString(),
        'minuto': evento.minuto,
        'jugadorNombre': evento.jugadorNombre,
        'camiseta': evento.camiseta,
        'equipoId': evento.equipoId,
      };

      if (evento.jugadorSale != null) {
        eventoMap['jugadorSale'] = evento.jugadorSale!;
        eventoMap['camisetaSale'] = evento.camisetaSale!;
      }

      eventos.add(eventoMap);

      final updates = <String, dynamic>{
        'eventos': eventos,
      };

      if (esGolLocal) {
        updates['golesLocal'] = (data['golesLocal'] ?? 0) + 1;
      }
      if (esGolVisitante) {
        updates['golesVisitante'] = (data['golesVisitante'] ?? 0) + 1;
      }

      transaction.update(docRef, updates);
      
      String titulo = '';
      String cuerpo = '';
      
      if (evento.tipo == TipoEvento.gol) {
        titulo = '¡GOL de ${evento.jugadorNombre}!';
        cuerpo = 'Minuto ${evento.minuto}';
      } else if (evento.tipo == TipoEvento.roja) {
        titulo = 'Tarjeta ROJA para ${evento.jugadorNombre}';
        cuerpo = 'El equipo se queda con uno menos.';
      }
      
      if (titulo.isNotEmpty) {
        _db.collection('notificaciones_pendientes').add({
          'topic': 'equipo_${evento.equipoId}',
          'titulo': titulo,
          'cuerpo': cuerpo,
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> guardarFormacion(String partidoId, bool esLocal, List<JugadorFormacion> jugadores) async {
    final campo = esLocal ? 'formacionLocal' : 'formacionVisitante';
    final listaMapas = jugadores.map((j) => j.toMap()).toList();
    
    await _db.collection('partidos').doc(partidoId).update({
      campo: listaMapas,
    });
  }
}
