import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipo.dart';
import '../models/usuario.dart';

class AuthService {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener usuario actual de Firebase Auth
  auth.User? get currentUser => _auth.currentUser;

  // Obtener el modelo completo de Usuario (con rol)
  Future<Usuario?> getUsuarioActual() async {
    if (currentUser == null) return null;
    
    try {
      DocumentSnapshot doc = await _db.collection('usuarios').doc(currentUser!.uid).get();
      if (doc.exists) {
        return Usuario.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error obteniendo usuario: $e');
    }
    return null;
  }

  // Registro con email, password y equipo favorito
  Future<void> registrarUsuario({
    required String email,
    required String password,
    required String nombre,
    required Equipo equipoFavorito,
  }) async {
    try {
      // 1. Crear usuario en Auth
      auth.UserCredential credencial = await _auth.createUserWithEmailAndPassword(
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

  // Método legacy para compatibilidad (opcional, mejor usar getUsuarioActual)
  Future<Map<String, dynamic>?> getUserData() async {
    if (currentUser == null) return null;
    DocumentSnapshot doc = await _db.collection('usuarios').doc(currentUser!.uid).get();
    return doc.data() as Map<String, dynamic>?;
  }
}
