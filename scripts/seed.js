const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedData() {
  try {
    console.log('Iniciando carga de datos...');

    // 1. Cargar Equipos
    const equipos = [
      { id: 'equipo1', nombre: 'Los Leones', escudoUrl: 'https://via.placeholder.com/150/00FF00/FFFFFF?text=Leones' },
      { id: 'equipo2', nombre: 'Atlético Roca', escudoUrl: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Roca' },
      { id: 'equipo3', nombre: 'Deportivo Sur', escudoUrl: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Sur' },
      { id: 'equipo4', nombre: 'Huracán FC', escudoUrl: 'https://via.placeholder.com/150/FFFF00/000000?text=Huracan' },
    ];

    for (const equipo of equipos) {
      await db.collection('equipos').doc(equipo.id).set(equipo);
      console.log(`Equipo cargado: ${equipo.nombre}`);
    }

    // 2. Cargar Noticias
    const noticias = [
      {
        tipo: 'general',
        titulo: 'Comienza la nueva temporada de la Liga Roca',
        contenido: 'Todo está listo para el inicio del torneo más esperado del año. Los equipos se han reforzado y prometen dar espectáculo.',
        fecha: new Date(),
        equipoId: null
      },
      {
        tipo: 'equipo',
        equipoId: 'equipo1',
        titulo: 'Los Leones presentan su nueva camiseta',
        contenido: 'Con un diseño innovador, el equipo busca rugir más fuerte que nunca este año.',
        fecha: new Date(),
      },
      {
        tipo: 'equipo',
        equipoId: 'equipo2',
        titulo: 'Atlético Roca confirma su fichaje estrella',
        contenido: 'El delantero goleador llega para reforzar el ataque del equipo rojiblanco.',
        fecha: new Date(),
      },
      {
        tipo: 'general',
        titulo: 'Cambios en el reglamento para este año',
        contenido: 'La federación ha anunciado nuevas normas para agilizar el juego y fomentar el fair play.',
        fecha: new Date(Date.now() - 86400000), // Ayer
        equipoId: null
      }
    ];

    for (const noticia of noticias) {
      await db.collection('noticias').add(noticia);
      console.log(`Noticia cargada: ${noticia.titulo}`);
    }

    // 3. Cargar Fixture (Partidos)
    const partidos = [
      {
        localId: 'equipo1',
        localNombre: 'Los Leones',
        localEscudo: 'https://via.placeholder.com/150/00FF00/FFFFFF?text=Leones',
        visitanteId: 'equipo2',
        visitanteNombre: 'Atlético Roca',
        visitanteEscudo: 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Roca',
        fecha: new Date(Date.now() + 86400000), // Mañana
        finalizado: false,
        golesLocal: 0,
        golesVisitante: 0
      },
      {
        localId: 'equipo3',
        localNombre: 'Deportivo Sur',
        localEscudo: 'https://via.placeholder.com/150/0000FF/FFFFFF?text=Sur',
        visitanteId: 'equipo4',
        visitanteNombre: 'Huracán FC',
        visitanteEscudo: 'https://via.placeholder.com/150/FFFF00/000000?text=Huracan',
        fecha: new Date(Date.now() - 172800000), // Hace 2 días
        finalizado: true,
        golesLocal: 2,
        golesVisitante: 1
      }
    ];

    for (const partido of partidos) {
      await db.collection('partidos').add(partido);
      console.log(`Partido cargado: ${partido.localNombre} vs ${partido.visitanteNombre}`);
    }

    console.log('¡Carga de datos completada con éxito!');
    process.exit(0);
  } catch (error) {
    console.error('Error cargando datos:', error);
    process.exit(1);
  }
}

seedData();
