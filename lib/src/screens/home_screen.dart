import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/noticias_feed.dart';
import 'fixture_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();

  // Cacheamos los datos del usuario para no recargarlos innecesariamente
  Map<String, dynamic>? _userData;
  bool _isLoadingUser = true;
  int _selectedIndex = 0;

  // Mantenemos el estado de las pantallas para evitar reconstrucciones costosas
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Intentamos obtener datos, si falla o es lento, mostramos la UI básica primero
    try {
      final data = await _authService.getUserData();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoadingUser = false;
          _initScreens(); // Inicializamos las pantallas con los datos cargados
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
          _initScreens(); // Inicializamos pantallas por defecto
        });
      }
    }
  }

  void _initScreens() {
    final String? equipoId = _userData?['equipoFavoritoId'];
    final String nombreEquipo = _userData?['equipoFavoritoNombre'] ?? 'Tu Equipo';

    _screens = [
      // Usamos const donde sea posible y RepaintBoundary para aislar repintados
      RepaintBoundary(child: NoticiasFeed(equipoId: equipoId, nombreEquipo: nombreEquipo)),
      const RepaintBoundary(child: FixtureList()),
    ];
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'Liga Roca' : 'Fixture'),
        actions: [
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
      // IndexedStack mantiene el estado de las pantallas ocultas, evitando reconstrucciones al cambiar de tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
