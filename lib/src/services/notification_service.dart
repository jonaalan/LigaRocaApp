import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Pedir permisos (Crítico para iOS y Android 13+)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Permiso de notificaciones concedido');
      }
      
      // Suscribirse a noticias generales por defecto
      await _messaging.subscribeToTopic('general');
    }
  }

  // Suscribir al tema del equipo favorito
  Future<void> suscribirAEquipo(String equipoId) async {
    await _messaging.subscribeToTopic('equipo_$equipoId');
    if (kDebugMode) {
      print('Suscrito a notificaciones del equipo: $equipoId');
    }
  }

  // Desuscribir (útil si cambia de equipo)
  Future<void> desuscribirDeEquipo(String equipoId) async {
    await _messaging.unsubscribeFromTopic('equipo_$equipoId');
  }
}
