import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
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
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("No se pudo abrir el link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // Filtramos para mostrar solo las que NO son de pantalla completa en el banner inferior
      stream: FirebaseFirestore.instance
          .collection('publicidad')
          .where('esIntersticial', isNotEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final publicidades = snapshot.data!.docs;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Container(
            height: 80, // Un poco más alto para que se luzca
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  final data = publicidades[index % publicidades.length].data() as Map<String, dynamic>;
                  final String imageUrl = data['url'] ?? '';
                  final String linkUrl = data['link'] ?? '';

                  return InkWell(
                    onTap: () {
                      if (linkUrl.isNotEmpty) {
                        _launchURL(linkUrl);
                      }
                    },
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.image, color: Colors.white10)),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}