import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'src/app.dart';
import 'package:intl/date_symbol_data_local.dart';

// 1. Manejador de segundo plano
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

// 2. Canal de alta importancia
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notificaciones de Goles',
  description: 'Este canal se usa para notificaciones importantes de partidos.',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('es', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  await FirebaseMessaging.instance.subscribeToTopic('general');

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // ===========================================================================
  // 🚀 MANEJO DE CLIC EN LA NOTIFICACIÓN (Para ir al partido)
  // ===========================================================================

  // Caso 1: Cuando la app está en SEGUNDO PLANO y tocás la notificación
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("Ariendo desde notificación: ${message.data}");
    // Aquí el Navigator se maneja dentro de MyApp, pero dejamos el log para debug
  });

  // Caso 2: Cuando la app está CERRADA y la abrís tocando la notificación
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App abierta desde estado cerrada con data: ${initialMessage.data}");
  }

  runApp(const MyApp());
}