import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/publicidad.dart';
import '../services/firestore_service.dart';

class PublicidadBanner extends StatefulWidget {
  const PublicidadBanner({super.key});

  @override
  State<PublicidadBanner> createState() => _PublicidadBannerState();
}

class _PublicidadBannerState extends State<PublicidadBanner> {
  int _currentIndex = 0;
  Timer? _timer;
  List<Publicidad> _publicidades = [];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _iniciarRotacion() {
    _timer?.cancel();
    if (_publicidades.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % _publicidades.length;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Publicidad>>(
      stream: firestoreService.getPublicidades(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        // Filtramos solo las activas
        final nuevasPublicidades = snapshot.data!.where((p) => p.activa).toList();
        
        if (nuevasPublicidades.isEmpty) return const SizedBox.shrink();

        // Si la lista cambió, reiniciamos o actualizamos
        if (nuevasPublicidades.length != _publicidades.length) {
          _publicidades = nuevasPublicidades;
          _currentIndex = 0;
          _iniciarRotacion();
        }

        final publicidad = _publicidades[_currentIndex];

        return Container(
          height: 70,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (publicidad.linkUrl != null && await canLaunchUrl(Uri.parse(publicidad.linkUrl!))) {
                    await launchUrl(Uri.parse(publicidad.linkUrl!));
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Row(
                    key: ValueKey<String>(publicidad.id), // Clave para la animación
                    children: [
                      Expanded(
                        child: Image.network(
                          publicidad.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity, // Asegura que ocupe todo el ancho
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        color: Colors.black12,
                        child: const Text(
                          'ANUNCIO',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
