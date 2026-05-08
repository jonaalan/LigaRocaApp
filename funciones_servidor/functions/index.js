const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.enviarNotificacionGol = onDocumentCreated(
  "notificaciones/{notifId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const data = snap.data();
    const titulo = data.titulo || "¡Gol!";
    const mensaje = data.mensaje || "Novedad en el partido";
    const equipoIdRaw = data.equipoId || "general";
    const partidoId = data.partidoId || ""; // Capturamos el ID del partido

    const temaLimpio = equipoIdRaw.toString().replace(/\s+/g, "_");

    const messaging = getMessaging();

    // Construimos el mensaje con DATA para que Flutter sepa a dónde ir
    const construirMensaje = (tema) => ({
      notification: {
        title: titulo,
        body: mensaje,
      },
      data: {
        // Todo lo que vaya en DATA debe ser STRING
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        partidoId: partidoId.toString(),
        tipo: "gol",
      },
      android: {
        notification: {
          channelId: "high_importance_channel",
          sound: "default",
          priority: "high",
        },
      },
      topic: tema,
    });

    try {
      await messaging.send(construirMensaje(`equipo_${temaLimpio}`));
      await messaging.send(construirMensaje("general"));
      console.log(`✅ Push enviado con data a equipo_${temaLimpio} y general`);
    } catch (error) {
      console.error("❌ Error:", error);
    }
  },
);
