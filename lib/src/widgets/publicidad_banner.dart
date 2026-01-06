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
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Iniciar el timer para rotar automáticamente
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return StreamBuilder<List<Publicidad>>(
      stream: firestoreService.getPublicidades(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink(); // Si no hay publicidad, no mostramos nada
        }

        final publicidades = snapshot.data!;

        return Container(
          height: 80, // Altura del banner
          color: Colors.grey[200],
          child: PageView.builder(
            controller: _pageController,
            itemBuilder: (context, index) {
              // Usamos módulo para ciclo infinito visual
              final publicidad = publicidades[index % publicidades.length];
              
              return InkWell(
                onTap: () {
                  if (publicidad.linkUrl != null && publicidad.linkUrl!.isNotEmpty) {
                    _launchURL(publicidad.linkUrl!);
                  }
                },
                child: Image.network(
                  publicidad.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
