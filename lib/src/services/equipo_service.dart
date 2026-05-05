import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipo.dart';

class EquipoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los equipos de la colección 'equipos'
  Future<List<Equipo>> getEquipos() async {
    try {
      QuerySnapshot snapshot = await _db.collection('equipos').get();
      return snapshot.docs.map((doc) {
        return Equipo.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print("Error al cargar equipos: $e");
      return [];
    }
  }
}