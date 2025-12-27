import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:liga_roca/src/app.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Eliminamos la llamada bloqueante a inicializarDatosPrueba para acelerar el inicio.
  // Si necesitas poblar datos, puedes hacerlo manualmente o en segundo plano.

  runApp(const MyApp());
}
