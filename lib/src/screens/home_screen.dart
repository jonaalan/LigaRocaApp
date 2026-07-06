import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

// --- IMPORTACIONES DE TUS PANTALLAS ---
import '../widgets/noticias_feed.dart';
import 'fixture_screen.dart';
import 'tabla_posiciones_screen.dart';
import 'notificaciones_screen.dart';
import 'beneficios_screen.dart'; // <--- NUEVA IMPORTACIÓN
import '../widgets/publicidad_banner.dart';
import '../widgets/publicidad_intersticial.dart';

// --- IMPORTACIONES DE ADMIN ---
import 'admin/admin_noticias_screen.dart';
import 'admin/admin_fixture_screen.dart';
import 'admin/admin_equipos_screen.dart';
import 'admin/admin_publicidad_screen.dart';
import 'admin/admin_notificaciones_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _currentIndex = 0;

  String? _equipoId;
  String _nombreEquipo = "Mi Equipo";
  bool _loadingUser = true;
  bool _isAnyAdmin = false;
  String _rolUsuario = "user";

  final Color _verdeEsmeralda = const Color(0xFF00C853);
  final Color _negroProfundo = const Color(0xFF000000);
  final Color _verdeMuyOscuro = const Color(0xFF051209);

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    try {
      final userData = await _authService.getUserData();
      if (userData != null) {
        setState(() {
          _equipoId = userData['equipoFavoritoId'];
          _nombreEquipo = userData['equipoFavoritoNombre'] ?? "Mi Equipo";
          _rolUsuario = userData['rol'] ?? 'user';
          _isAnyAdmin = (_rolUsuario == 'admin' || _rolUsuario == 'prensa');
          _loadingUser = false;
        });
      } else {
        setState(() => _loadingUser = false);
      }
    } catch (e) {
      setState(() => _loadingUser = false);
    }
  }

  void _mostrarMenuAdmin() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _verdeMuyOscuro,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)
                ),
              ),
              Text(
                  'PANEL DE CONTROL',
                  style: TextStyle(
                      color: _verdeEsmeralda,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2
                  )
              ),
              const SizedBox(height: 20),

              _itemAdmin(Icons.newspaper, 'Gestionar Noticias', () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminNoticiasScreen(rol: _rolUsuario, equipoId: _equipoId, equipoNombre: _nombreEquipo)))),

              if (_rolUsuario == 'admin') ...[
                _itemAdmin(Icons.calendar_today, 'Gestionar Fixture', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminFixtureScreen()))),
                _itemAdmin(Icons.shield, 'Gestionar Equipos', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminEquiposScreen()))),
                _itemAdmin(Icons.ads_click, 'Gestionar Publicidad', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminPublicidadScreen()))),
                _itemAdmin(Icons.notifications_active, 'Enviar Notificación', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminNotificacionesScreen()))),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _itemAdmin(IconData icono, String titulo, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icono, color: Colors.white70),
      title: Text(titulo, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingUser) {
      return Scaffold(
        backgroundColor: _negroProfundo,
        body: Center(child: CircularProgressIndicator(color: _verdeEsmeralda)),
      );
    }

    final List<Widget> _paginas = [
      NoticiasFeed(equipoId: _equipoId, nombreEquipo: _nombreEquipo),
      const BeneficiosScreen(), // <--- NUEVA PESTAÑA AGREGADA AQUÍ
      const FixtureList(),
      const TablaPosicionesScreen(),
    ];

    return Scaffold(
      backgroundColor: _negroProfundo,
      appBar: AppBar(
        backgroundColor: _verdeMuyOscuro,
        elevation: 0,
        centerTitle: false,
        title: const Text(
            'LIGA ROCA',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18, color: Colors.white)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificacionesScreen())),
          ),
          if (_isAnyAdmin)
            IconButton(
              icon: Icon(Icons.admin_panel_settings, color: _verdeEsmeralda),
              onPressed: _mostrarMenuAdmin,
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Busca esta parte en tu home_screen.dart y reemplázala:
            body: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_verdeMuyOscuro, _negroProfundo],
                ),
              ),
              child: Stack(
                children: [
                  // CAMBIO AQUÍ: Usamos IndexedStack para mantener el estado de las pestañas
                  IndexedStack(
                    index: _currentIndex,
                    children: _paginas,
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: PublicidadBanner(),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(canvasColor: _verdeMuyOscuro),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex != index) {
              setState(() => _currentIndex = index);
              PublicidadIntersticial.intentarMostrar(context);
            }
          },
          backgroundColor: _verdeMuyOscuro,
          selectedItemColor: _verdeEsmeralda,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.article), label: 'NOTICIAS'),
            BottomNavigationBarItem(icon: Icon(Icons.wallet_giftcard), label: 'BENEFICIOS'), // <--- NUEVO ÍCONO
            BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'FIXTURE'),
            BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'TABLA'),
          ],
        ),
      ),
    );
  }
}