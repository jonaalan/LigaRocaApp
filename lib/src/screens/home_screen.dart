import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/noticias_feed.dart';
import '../widgets/web_container.dart';
import 'fixture_screen.dart';
import 'registro_screen.dart';
import 'admin/admin_noticias_screen.dart';
import 'admin/admin_fixture_screen.dart';
import 'admin/admin_equipos_screen.dart'; // Importamos admin equipos

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _authService.getUserData();
    if (mounted) {
      setState(() {
        _userData = data;
        _isLoadingUser = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String? equipoId = _userData?['equipoFavoritoId'];
    final String nombreEquipo = _userData?['equipoFavoritoNombre'] ?? 'Tu Equipo';
    final String rol = _userData?['rol'] ?? 'hincha';

    final List<Widget> screens = [
      NoticiasFeed(equipoId: equipoId, nombreEquipo: nombreEquipo),
      const FixtureList(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Liga Roca' : 'Fixture'),
        actions: [
          // Menú Admin
          if (rol == 'admin')
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
              ],
            ),

          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const RegistroScreen()),
                );
              }
            },
          )
        ],
      ),
      body: WebContainer(child: screens[_selectedIndex]),
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
