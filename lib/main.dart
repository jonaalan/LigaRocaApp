import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'src/screens/home_screen.dart';
import 'src/services/notification_service.dart'; // <--- NUEVO IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeDateFormatting('es', null);

  // REGLA DE ORO: Inicializamos las notificaciones sin romper el diseño
  await NotificationService.inicializar();

  runApp(const LigaRocaApp());
}

class LigaRocaApp extends StatelessWidget {
  const LigaRocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: NotificationService.messengerKey,
      title: 'Liga Roca',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}