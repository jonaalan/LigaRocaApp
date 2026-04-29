import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../screens/notificaciones_screen.dart'; // Importamos la pantalla de historial

class CampanitaNotificaciones extends StatelessWidget {
  final String? equipoIdSeguido;
  final String? rol; // Agregamos el rol para saber si es admin o hincha

  const CampanitaNotificaciones({
    super.key,
    this.equipoIdSeguido,
    this.rol
  });

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return StreamBuilder<int>(
      // Escucha en tiempo real cuántas notificaciones no leyó el usuario
      stream: service.countNotificacionesSinLeer(equipoIdSeguido),
      builder: (context, snapshot) {
        int cantidad = snapshot.data ?? 0;
        bool tieneNovedades = cantidad > 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, size: 28, color: Colors.white),
              onPressed: () async {
                // 1. Marcamos como leídas en Firestore para que el punto rojo desaparezca
                await service.marcarNotificacionesComoLeidas(equipoIdSeguido);

                // 2. Navegamos a la pantalla de historial de notificaciones
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificacionesScreen(
                        equipoId: equipoIdSeguido,
                        rol: rol, // Le pasamos el rol a la pantalla de destino
                      ),
                    ),
                  );
                }
              },
            ),
            // EL PUNTO ROJO: Solo se dibuja si hay notificaciones nuevas (cantidad > 0)
            if (tieneNovedades)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$cantidad',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}