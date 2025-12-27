import '../models/equipo.dart';
import '../models/noticia.dart';
import '../models/partido.dart';

class DataService {
  // Simulación de base de datos
  static final List<Equipo> equipos = [
    Equipo(id: '1', nombre: 'Los Leones', escudoUrl: 'assets/leones.png'),
    Equipo(id: '2', nombre: 'Atlético Roca', escudoUrl: 'assets/roca.png'),
    Equipo(id: '3', nombre: 'Deportivo Sur', escudoUrl: 'assets/sur.png'),
    Equipo(id: '4', nombre: 'Huracán FC', escudoUrl: 'assets/huracan.png'),
  ];

  static List<Equipo> getEquipos() {
    return equipos;
  }

  // Aquí agregaremos más métodos para obtener noticias y partidos
}
