import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:convert'; // PARA EL PUSH
import 'package:http/http.dart' as http; // PARA EL PUSH
import '../models/noticia.dart';
import '../models/equipo.dart';
import '../models/partido.dart';
import '../models/publicidad.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ===========================================================================
  // ENVÍO DE PUSH DIRECTO (EL TRUCO DEL BOLSILLO)
  // ===========================================================================
// ===========================================================================
// ENVÍO DE PUSH DIRECTO (EL TRUCO DEL BOLSILLO)
// ===========================================================================
  Future<void> enviarNotificacionPush({
    required String titulo,
    required String mensaje,
    required String partidoId,
    String tema = 'general',
  }) async {
    // Ya no hace nada aquí porque el servidor lo hace solo.
    print("📢 Notificación registrada internamente para: $tema");
  }
  // ===========================================================================
  // SUSCRIPCIÓN A NOTIFICACIONES
  // ===========================================================================
  Future<void> suscribirAEquipo(String equipoId) async {
    // Limpiamos el ID por si tiene espacios
    String idLimpio = equipoId.replaceAll(' ', '_');
    await _fcm.subscribeToTopic('equipo_$idLimpio');
    await _fcm.subscribeToTopic('general');
    print("✅ Suscrito con éxito a: equipo_$idLimpio y general");
  }
  // ===========================================================================
  // EQUIPOS
  // ===========================================================================
  Stream<List<Equipo>> getEquipos() {
    return _db.collection('equipos').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Equipo(
        id: doc.id,
        nombre: doc.data()['nombre'] ?? 'Sin Nombre',
        escudoUrl: doc.data()['escudoUrl'] ?? '',
      )).toList();
    });
  }

  Future<void> crearEquipo(String nombre, String escudoUrl) async {
    await _db.collection('equipos').add({'nombre': nombre, 'escudoUrl': escudoUrl});
  }

  Future<void> actualizarEquipo(String id, String nombre, String escudoUrl) async {
    await _db.collection('equipos').doc(id).update({'nombre': nombre, 'escudoUrl': escudoUrl});
  }

  // ===========================================================================
  // NOTICIAS
  // ===========================================================================
  Stream<List<Noticia>> getNoticiasGenerales() {
    return _db.collection('noticias')
        .where('tipo', isEqualTo: 'general')
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(_mapQueryToNoticias);
  }

  Stream<List<Noticia>> getNoticiasEquipo(String equipoId) {
    return _db.collection('noticias')
        .where('tipo', isEqualTo: 'equipo')
        .where('equipoId', isEqualTo: equipoId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map(_mapQueryToNoticias);
  }

  Stream<List<Noticia>> getTodasLasNoticias() {
    return _db.collection('noticias').orderBy('fecha', descending: true).snapshots().map(_mapQueryToNoticias);
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
  // PARTIDOS Y EVENTOS
  // ===========================================================================
  Stream<List<Partido>> getPartidos() {
    return _db.collection('partidos').orderBy('fecha').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Partido.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  Future<void> guardarFormacion(String partidoId, bool esLocal, List<JugadorFormacion> jugadores) async {
    final campo = esLocal ? 'formacionLocal' : 'formacionVisitante';
    await _db.collection('partidos').doc(partidoId).update({
      campo: jugadores.map((j) => j.toMap()).toList()
    });
  }
  // ===========================================================================
  //  EVENTOS
  // ===========================================================================
  Future<void> agregarEvento(String partidoId, EventoPartido evento, bool esGolLocal, bool esGolVisitante) async {
    final docRef = _db.collection('partidos').doc(partidoId);

    try {
      final snap = await docRef.get();
      if (!snap.exists) return;
      final data = snap.data() as Map<String, dynamic>;

      // --- TRUCO PARA TU ESTRUCTURA ACTUAL ---
      // Si localId no existe, usamos el nombre como ID temporal o buscamos dentro del mapa
      String idLocal = data['localId']?.toString() ?? data['local']?['nombre'] ?? "local";
      String idVisitante = data['visitanteId']?.toString() ?? data['visitante']?['nombre'] ?? "visitante";

      String nombreLocal = data['localNombre'] ?? data['local']?['nombre'] ?? 'Local';
      String nombreVisitante = data['visitanteNombre'] ?? data['visitante']?['nombre'] ?? 'Visitante';

      int gL = (data['golesLocal'] ?? 0);
      int gV = (data['golesVisitante'] ?? 0);

      if (esGolLocal) gL++;
      if (esGolVisitante) gV++;

      String nombreJugador = "";
      String nombreEquipo = esGolLocal ? nombreLocal : nombreVisitante;
      String tipoEventoTexto = "evento";

      try {
        final ev = evento as dynamic;
        nombreJugador = (ev.jugadorNombre ?? ev.jugador ?? "").toString();
        if (ev.tipo != null) {
          tipoEventoTexto = ev.tipo.toString().split('.').last;
        }
      } catch (e) {
        print("⚠️ Aviso: Error procesando nombres");
      }

      // 1. ACTUALIZAMOS FIRESTORE
      await docRef.update({
        'golesLocal': gL,
        'golesVisitante': gV,
        'eventos': FieldValue.arrayUnion([{
          'minuto': evento.minuto ?? 0,
          'tipo': tipoEventoTexto,
          'jugadorNombre': nombreJugador,
          'equipoNombre': nombreEquipo,
        }])
      });

      String tituloNotif = "¡GOOOOL DE ${nombreEquipo.toUpperCase()}! ⚽";
      String mensajeNotif = "Marcador: $nombreLocal $gL - $gV $nombreVisitante";

      // 2. GUARDAMOS EN NOTIFICACIONES (CAMPANITA)
      await _db.collection('notificaciones').add({
        'titulo': tituloNotif,
        'mensaje': mensajeNotif,
        'fecha': FieldValue.serverTimestamp(),
        'visto': false,
        'equipoId': esGolLocal ? idLocal : idVisitante,
        'partidoId': partidoId,
        'tipo': 'gol'
      });

      // 3. DISPARO AL BOLSILLO (PUSH)
      // Mandamos a dos temas para estar seguros: al del equipo y al general

      print("📱 Enviando PUSH de Gol...");

      // Push al equipo
      // Cambia esto en agregarEvento:
      String temaEquipo = (esGolLocal ? idLocal : idVisitante).replaceAll(' ', '_');

      await enviarNotificacionPush(
        titulo: tituloNotif,
        mensaje: mensajeNotif,
        partidoId: partidoId,
        tema: 'equipo_$temaEquipo',
      );

      // Push al tema general (Para que te llegue SI o SI mientras probamos)
      await enviarNotificacionPush(
        titulo: tituloNotif,
        mensaje: mensajeNotif,
        partidoId: partidoId,
        tema: 'general',
      );

      print("✅ PUSH ENVIADO A EQUIPO Y GENERAL");
      print("🎯 PROCESO FINALIZADO");

    } catch (e) {
      print("❌ ERROR EN AGREGAR EVENTO: $e");
    }
  }
  // ===========================================================================
  // PUBLICIDADES
  // ===========================================================================
  Stream<List<Publicidad>> getPublicidades() {
    return _db.collection('publicidades').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Publicidad(
        id: doc.id,
        imageUrl: doc.data()['imageUrl'] ?? '',
        linkUrl: doc.data()['linkUrl'],
        activa: doc.data()['activa'] ?? true,
      )).toList();
    });
  }

  // ===========================================================================
  // NOTIFICACIONES
  // ===========================================================================
  Stream<int> countNotificacionesSinLeer(String? equipoId) {
    return _db.collection('notificaciones')
        .where('visto', isEqualTo: false)
        .snapshots()
        .map((snap) {
      if (equipoId == null) return snap.docs.length;
      return snap.docs.where((d) => d.data()['equipoId'] == equipoId).length;
    });
  }

  Future<void> marcarNotificacionesComoLeidas(String? equipoId) async {
    Query query = _db.collection('notificaciones').where('visto', isEqualTo: false);
    final docs = await query.get();
    final batch = _db.batch();
    for (var doc in docs.docs) {
      batch.update(doc.reference, {'visto': true});
    }
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getNotificacionesList(String? equipoId) {
    return _db.collection('notificaciones')
        .orderBy('fecha', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) {
      if (equipoId == null) {
        return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
      }
      return snap.docs
          .where((doc) => doc.data()['equipoId'] == equipoId || doc.data()['equipoId'] == null)
          .map((doc) => {...doc.data(), 'id': doc.id})
          .toList();
    });
  }

  Future<void> borrarTodasLasNotificaciones() async {
    final docs = await _db.collection('notificaciones').get();
    final batch = _db.batch();
    for (var doc in docs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}