import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Agregamos esto para el SnackBar

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Agregamos una llave para poder mostrar avisos visuales sin contexto
  static final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  static Future<void> inicializar() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        if (kDebugMode) print('Permiso de notificaciones concedido');
        if (!kIsWeb) {
          await _messaging.subscribeToTopic('general');
        }
      }

      // ESTO ES LO NUEVO: Qué hacer cuando llega el mensaje
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notificación recibida: ${message.notification?.title}');
        }

        // Mostramos un aviso visual dentro de la app
        if (message.notification != null) {
          _mostrarAvisoVisual(
            message.notification!.title ?? '¡Aviso!',
            message.notification!.body ?? '',
          );
        }
      });

    } catch (e) {
      if (kDebugMode) print('Error inicializando notificaciones: $e');
    }
  }

  static void _mostrarAvisoVisual(String titulo, String cuerpo) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(cuerpo, style: const TextStyle(fontSize: 12)),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static Future<void> suscribirAEquipo(String equipoId) async {
    if (kIsWeb) return;
    try {
      await _messaging.subscribeToTopic('equipo_$equipoId');
    } catch (e) {
      print('Error suscribiendo: $e');
    }
  }

  static Future<void> desuscribirDeEquipo(String equipoId) async {
    if (kIsWeb) return;
    try {
      await _messaging.unsubscribeFromTopic('equipo_$equipoId');
    } catch (e) {
      print('Error desuscribiendo: $e');
    }
  }
}