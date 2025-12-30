import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liga_roca/src/app.dart';
import 'package:liga_roca/src/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar notificaciones
  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}
