import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    try {
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
        
        // En Web, subscribeToTopic no está soportado por el SDK cliente.
        // Solo intentamos suscribirnos si NO es web.
        if (!kIsWeb) {
          await _messaging.subscribeToTopic('general');
        } else {
          // Para web, podríamos obtener el token y enviarlo al servidor para que él nos suscriba
          final token = await _messaging.getToken(
            vapidKey: "TU_VAPID_KEY_AQUI", // Necesitas generar esto en la consola de Firebase
          );
          if (kDebugMode) {
            print('FCM Token Web: $token');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando notificaciones: $e');
      }
    }
  }

  // Suscribir al tema del equipo favorito
  Future<void> suscribirAEquipo(String equipoId) async {
    if (kIsWeb) return; // No soportado en cliente web
    
    try {
      await _messaging.subscribeToTopic('equipo_$equipoId');
      if (kDebugMode) {
        print('Suscrito a notificaciones del equipo: $equipoId');
      }
    } catch (e) {
      print('Error suscribiendo a equipo: $e');
    }
  }

  // Desuscribir (útil si cambia de equipo)
  Future<void> desuscribirDeEquipo(String equipoId) async {
    if (kIsWeb) return; // No soportado en cliente web
    
    try {
      await _messaging.unsubscribeFromTopic('equipo_$equipoId');
    } catch (e) {
      print('Error desuscribiendo de equipo: $e');
    }
  }
}
