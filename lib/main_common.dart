import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liga_roca/src/app.dart';
import 'package:liga_roca/src/config/environment.dart';
import 'package:liga_roca/src/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Inicializar notificaciones
    final notificationService = NotificationService();
    await notificationService.init();
    
  } catch (e) {
    print("Error durante la inicialización de Firebase: $e");
  }

  runApp(
    Provider<AppEnvironment>.value(
      value: environment,
      child: const MyApp(),
    ),
  );
}
