import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/noticia.dart';
import '../models/equipo.dart';
import '../models/partido.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Inicializar datos de prueba si la base de datos está vacía
  Future<void> inicializarDatosPrueba() async {
    final equiposSnapshot = await _db.collection('equipos').get();
    if (equiposSnapshot.docs.isEmpty) {
      // Crear equipos
      final equipos = [
        {'nombre': 'Deportivo Roca', 'escudoUrl': 'https://via.placeholder.com/150/0000FF/FFFFFF?text=DR'},
        {'nombre': 'Atlético Huinca', 'escudoUrl': 'https://via.placeholder.com/150/FF0000/FFFFFF?text=AH'},
        {'nombre': 'Juventud Unida', 'escudoUrl': 'https://via.placeholder.com/150/00FF00/FFFFFF?text=JU'},
        {'nombre': 'Talleres', 'escudoUrl': 'https://via.placeholder.com/150/000000/FFFFFF?text=T'},
      ];

      for (var equipo in equipos) {
        await _db.collection('equipos').add(equipo);
      }

      // Crear noticias generales
      await _db.collection('noticias').add({
        'tipo': 'general',
        'titulo': 'Comienza la nueva temporada',
        'contenido': 'La Liga Roca da inicio a una nueva temporada llena de emociones.',
        'fecha': FieldValue.serverTimestamp(),
      });

      // Crear noticias de equipo (ejemplo para el primero que se cree)
      // Nota: Esto es solo para inicializar, en un caso real necesitaríamos los IDs reales
    }
  }

  // Obtener todos los equipos (para el selector de registro)
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

  // Obtener noticias (Generales + Equipo Favorito)
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
      );
    }).toList();
  }

  // Obtener Fixture (Partidos)
  Stream<List<Partido>> getPartidos() {
    return _db.collection('partidos').orderBy('fecha').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
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
          golesLocal: data['golesLocal'],
          golesVisitante: data['golesVisitante'],
          finalizado: data['finalizado'] ?? false,
        );
      }).toList();
    });
  }
}
