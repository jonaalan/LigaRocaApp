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
    final env = Provider.of<AppEnvironment>(context);

    return MaterialApp(
      title: env.appName,
      debugShowCheckedModeBanner: false, // Quitamos el banner por defecto de Flutter
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
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
      builder: (context, child) {
        // Si estamos en DEV, agregamos un banner visual
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
