import 'dart:async';
import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../models/partido.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/noticias_feed.dart';
import '../widgets/publicidad_banner.dart';
import 'fixture_screen.dart';
import 'login_screen.dart';
import 'tabla_posiciones_screen.dart';
import 'admin/admin_noticias_screen.dart';
import 'admin/admin_fixture_screen.dart';
import 'admin/admin_equipos_screen.dart';
import 'admin/admin_publicidad_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Usuario? _usuario;
  bool _isLoadingUser = true;
  int _selectedIndex = 0;
  StreamSubscription? _golesSubscription;
  late PageController _pageController; // Controlador para el PageView

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _loadUserData();
  }

  @override
  void dispose() {
    _golesSubscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final usuario = await _authService.getUsuarioActual();
      if (mounted) {
        setState(() {
          _usuario = usuario;
          _isLoadingUser = false;
          _initScreens();
        });
        _escucharGoles();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _initScreens();
        });
      }
    }
  }

  void _escucharGoles() {
    _golesSubscription = _firestoreService.getPartidos().listen((partidos) {
      // Lógica real iría aquí
    });
  }

  void _simularNotificacionGol() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.sports_soccer, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡GOL DE TU EQUIPO!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                  Text('${_usuario?.equipoFavoritoNombre ?? "Equipo"} acaba de marcar.', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _initScreens() {
    final String? equipoId = _usuario?.equipoFavoritoId;
    final String nombreEquipo = _usuario?.equipoFavoritoNombre ?? 'Tu Equipo';

    _screens = [
      RepaintBoundary(child: NoticiasFeed(equipoId: equipoId, nombreEquipo: nombreEquipo)),
      const RepaintBoundary(child: FixtureList()),
      const RepaintBoundary(child: TablaPosicionesScreen()),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String titulo = 'Liga Roca';
    if (_selectedIndex == 1) titulo = 'Fixture';
    if (_selectedIndex == 2) titulo = 'Posiciones';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(titulo),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined),
            tooltip: 'Simular Gol',
            onPressed: _simularNotificacionGol,
          ),

          if (_usuario?.rol == RolUsuario.admin)
            PopupMenuButton<String>(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Panel de Administración',
              onSelected: (value) {
                if (value == 'noticias') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNoticiasScreen()));
                } else if (value == 'fixture') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFixtureScreen()));
                } else if (value == 'equipos') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEquiposScreen()));
                } else if (value == 'publicidad') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPublicidadScreen()));
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'noticias',
                  child: Row(children: [Icon(Icons.newspaper, color: Colors.black54), SizedBox(width: 8), Text('Gestionar Noticias')]),
                ),
                const PopupMenuItem<String>(
                  value: 'fixture',
                  child: Row(children: [Icon(Icons.sports_soccer, color: Colors.black54), SizedBox(width: 8), Text('Gestionar Fixture')]),
                ),
                const PopupMenuItem<String>(
                  value: 'equipos',
                  child: Row(children: [Icon(Icons.shield, color: Colors.black54), SizedBox(width: 8), Text('Gestionar Equipos')]),
                ),
                const PopupMenuItem<String>(
                  value: 'publicidad',
                  child: Row(children: [Icon(Icons.campaign, color: Colors.black54), SizedBox(width: 8), Text('Gestionar Publicidad')]),
                ),
              ],
            ),
          
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF052e16),
              Color(0xFF0f172a),
              Color(0xFF000000),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: _screens,
                ),
              ),
              const PublicidadBanner(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Fixture',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_numbered),
            label: 'Posiciones',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[400],
        backgroundColor: const Color(0xFF000000),
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
