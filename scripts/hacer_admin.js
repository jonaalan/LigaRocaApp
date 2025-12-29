const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

// Inicializar Firebase Admin
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
}

const db = admin.firestore();
const auth = admin.auth();

// Obtener el email desde los argumentos de la consola
const email = process.argv[2];

if (!email) {
  console.error('Por favor, proporciona un email.');
  console.error('Uso: node hacer_admin.js tu@email.com');
  process.exit(1);
}

async function hacerAdmin() {
  try {
    console.log(`Buscando usuario con email: ${email}...`);

    // 1. Buscar el usuario en Authentication para obtener su UID
    const userRecord = await auth.getUserByEmail(email);
    const uid = userRecord.uid;

    console.log(`Usuario encontrado! UID: ${uid}`);

    // 2. Actualizar (o crear) el documento en Firestore con rol 'admin'
    const userRef = db.collection('usuarios').doc(uid);

    // Usamos set con merge: true para no borrar otros datos si existen
    await userRef.set({
      rol: 'admin',
      email: email // Aseguramos que el email esté guardado
    }, { merge: true });

    console.log('✅ ¡ÉXITO! El usuario ahora es ADMINISTRADOR.');
    console.log('Reinicia la app para ver los cambios.');
    process.exit(0);

  } catch (error) {
    if (error.code === 'auth/user-not-found') {
      console.error('❌ Error: No existe ningún usuario registrado con ese email.');
      console.error('Asegúrate de haberte registrado en la app primero.');
    } else {
      console.error('❌ Error inesperado:', error);
    }
    process.exit(1);
  }
}

hacerAdmin();
