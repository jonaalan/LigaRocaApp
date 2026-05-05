import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/noticia.dart';
import '../models/equipo.dart';
import '../models/partido.dart';
import '../models/publicidad.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // EQUIPOS
  // ===========================================================================
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
  }

  // ===========================================================================
  // NOTICIAS
  // ===========================================================================
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

  // ===========================================================================
  // PARTIDOS
  // ===========================================================================
  Stream<List<Partido>> getPartidos() {
    return _db.collection('partidos').orderBy('fecha').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Partido.fromFirestore(data, doc.id);
      }).toList();
    });
  }

  Future<void> guardarFormacion(String partidoId, bool esLocal, List<JugadorFormacion> jugadores) async {
    final campo = esLocal ? 'formacionLocal' : 'formacionVisitante';
    await _db.collection('partidos').doc(partidoId).update({
      campo: jugadores.map((j) => j.toMap()).toList()
    });
  }

  Future<void> agregarEvento(String partidoId, EventoPartido evento, bool esGolLocal, bool esGolVisitante) async {
    // Esta función actualiza los goles en el documento del partido
    final docRef = _db.collection('partidos').doc(partidoId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;

      final updates = <String, dynamic>{};
      if (esGolLocal) updates['golesLocal'] = (data['golesLocal'] ?? 0) + 1;
      if (esGolVisitante) updates['golesVisitante'] = (data['golesVisitante'] ?? 0) + 1;

      if (updates.isNotEmpty) transaction.update(docRef, updates);
    });
  }

  // ===========================================================================
  // PUBLICIDADES
  // ===========================================================================
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

  // ===========================================================================
  // NOTIFICACIONES
  // ===========================================================================
  Stream<int> countNotificacionesSinLeer(String? equipoId) {
    var query = _db.collection('notificaciones').where('leida', isEqualTo: false);
    if (equipoId != null) query = query.where('equipoId', isEqualTo: equipoId);
    return query.snapshots().map((snap) => snap.docs.length);
  }

  Future<void> marcarNotificacionesComoLeidas(String? equipoId) async {
    var query = _db.collection('notificaciones').where('leida', isEqualTo: false);
    if (equipoId != null) query = query.where('equipoId', isEqualTo: equipoId);
    final docs = await query.get();
    for (var doc in docs.docs) {
      await doc.reference.update({'leida': true});
    }
  }
}