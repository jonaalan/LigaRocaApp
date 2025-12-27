import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipo.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Registro con email, password y equipo favorito
  Future<void> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required Equipo equipoFavorito,
  }) async {
    try {
      // 1. Crear usuario en Auth
      UserCredential credencial = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Guardar datos adicionales en Firestore
      if (credencial.user != null) {
        await _db.collection('usuarios').doc(credencial.user!.uid).set({
          'nombre': nombre,
          'email': email,
          'equipoFavoritoId': equipoFavorito.id,
          'equipoFavoritoNombre': equipoFavorito.nombre,
          'rol': 'hincha', // Por defecto
          'fechaRegistro': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      rethrow; // Propagar error para manejarlo en la UI
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Obtener datos del usuario desde Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc = await _db.collection('usuarios').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }
}
