const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const messaging = admin.messaging();

console.log('🤖 Bot Notificador de Liga Roca INICIADO');
console.log('Escuchando goles y eventos en tiempo real...');

// Escuchar cambios en la colección 'partidos'
db.collection('partidos').where('estado', '==', 'EstadoPartido.jugando')
  .onSnapshot(snapshot => {
    snapshot.docChanges().forEach(change => {
      if (change.type === 'modified') {
        const partido = change.doc.data();
        const partidoId = change.doc.id;
        const eventos = partido.eventos || [];

        // Verificar si hay un evento nuevo (comparando con la versión anterior sería ideal,
        // pero para simplificar, asumiremos que el último evento es el nuevo si ocurrió hace menos de 5 segundos)
        // En un entorno real, usaríamos Cloud Functions triggers.

        if (eventos.length > 0) {
          const ultimoEvento = eventos[eventos.length - 1];
          // Aquí deberíamos tener lógica para no repetir notificaciones.
          // Por ahora, enviaremos notificación manual desde el admin o simulada.

          // NOTA: Detectar "nuevo" evento en un snapshot listener de cliente es complejo sin estado previo.
          // Estrategia mejorada: El Admin App escribirá en una colección 'cola_notificaciones' y este script la leerá.
        }
      }
    });
  });

// ESTRATEGIA ROBUSTA: Escuchar una colección auxiliar 'notificaciones_pendientes'
// El Admin App escribirá aquí cuando agregues un gol.
db.collection('notificaciones_pendientes').onSnapshot(snapshot => {
  snapshot.docChanges().forEach(async change => {
    if (change.type === 'added') {
      const noti = change.doc.data();
      console.log(`📢 Nuevo evento detectado: ${noti.titulo}`);

      // Construir mensaje
      const message = {
        notification: {
          title: noti.titulo,
          body: noti.cuerpo,
        },
        topic: noti.topic, // ej: 'equipo_123'
      };

      try {
        await messaging.send(message);
        console.log('✅ Notificación enviada con éxito');
        // Borrar de la cola para no repetir
        await db.collection('notificaciones_pendientes').doc(change.doc.id).delete();
      } catch (error) {
        console.error('❌ Error enviando notificación:', error);
      }
    }
  });
});
