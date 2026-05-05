import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // <--- 1. AGREGAR ESTO
import 'src/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. ESTA LÍNEA ES LA QUE QUITA LA PANTALLA ROJA
  // Le dice a la app que cargue los nombres de días y meses en español
  await initializeDateFormatting('es', null);

  runApp(const LigaRocaApp());
}

class LigaRocaApp extends StatelessWidget {
  const LigaRocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liga Roca',
      debugShowCheckedModeBanner: false,
      // Esto ayuda a que otros componentes de Flutter también hablen en español
      locale: const Locale('es', 'AR'),
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00C853),
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomeScreen(),
    );
  }
}