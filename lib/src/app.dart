import 'package:flutter/material.dart';
import 'package:liga_roca/src/screens/login_screen.dart';
import 'package:liga_roca/src/services/auth_service.dart';
import 'package:liga_roca/src/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return MaterialApp(
      title: 'Liga Roca',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        // Optimizaciones de rendimiento visual
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
      // Usamos un FutureBuilder para evitar bloqueos en el hilo principal al verificar el usuario
      home: FutureBuilder(
        future: Future.value(authService.currentUser), // Verificación rápida
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data != null ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
