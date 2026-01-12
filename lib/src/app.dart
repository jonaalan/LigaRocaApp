import 'package:flutter/material.dart';
import 'package:liga_roca/src/config/environment.dart';
import 'package:liga_roca/src/screens/login_screen.dart';
import 'package:liga_roca/src/services/auth_service.dart';
import 'package:liga_roca/src/screens/home_screen.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    
    AppEnvironment env;
    try {
      env = Provider.of<AppEnvironment>(context);
    } catch (e) {
      env = AppEnvironment(type: EnvironmentType.prod, appName: 'Liga Roca');
    }

    // Definimos la paleta de colores Dark Premium
    const colorFondo = Color(0xFF121212);
    const colorTarjetas = Color(0xFF1E293B);
    const colorPrimario = Color(0xFF4ade80); // Verde Neón
    const colorTexto = Color(0xFFFDFDF5);

    return MaterialApp(
      title: env.appName,
      debugShowCheckedModeBanner: false,
      
      // TEMA OSCURO GLOBAL
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: colorFondo,
        primaryColor: colorPrimario,
        colorScheme: const ColorScheme.dark(
          primary: colorPrimario,
          secondary: colorPrimario,
          surface: colorTarjetas,
          background: colorFondo,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF052e16), // Verde muy oscuro
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0f172a),
          selectedItemColor: colorPrimario,
          unselectedItemColor: Colors.grey,
        ),
        // ELIMINADO cardTheme para evitar conflictos de tipos
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: colorTexto),
          bodyMedium: TextStyle(color: colorTexto),
          titleLarge: TextStyle(color: colorTexto, fontWeight: FontWeight.bold),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),

      builder: (context, child) {
        if (env.isDev) {
          return Banner(
            message: env.bannerMessage ?? 'DEV',
            location: BannerLocation.topStart,
            color: Colors.red,
            child: child!,
          );
        }
        return child!;
      },
      home: FutureBuilder(
        future: Future.value(authService.currentUser),
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
