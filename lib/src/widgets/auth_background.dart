import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  
  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF052e16), // Verde muy oscuro
              Color(0xFF0f172a), // Azul grisáceo oscuro
              Color(0xFF000000), // Negro
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  
                  // LA PELOTA
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4ade80).withOpacity(0.2),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Transform.scale(
                        scale: 1.35,
                        alignment: Alignment.center, 
                        child: Image.asset(
                          'assets/icon/Pelota.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.sports_soccer, size: 80, color: Colors.white);
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // TÍTULO "CHITO"
                  const Text(
                    'CHITO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFFDFDF5),
                      letterSpacing: 6.0,
                      height: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // FORMULARIO
                  child,
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    '© 2024 Liga Roca App',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
