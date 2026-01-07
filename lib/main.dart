import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liga_roca/src/app.dart';
import 'package:liga_roca/src/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Inicializar notificaciones de manera segura
    final notificationService = NotificationService();
    await notificationService.init();
    
  } catch (e) {
    print("Error durante la inicialización de Firebase: $e");
    // Continuamos ejecutando la app aunque falle Firebase (podría mostrar un error en UI luego)
  }

  runApp(const MyApp());
}
