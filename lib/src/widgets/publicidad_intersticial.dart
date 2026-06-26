import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicidadIntersticial extends StatefulWidget {
  const PublicidadIntersticial({super.key});

  static int _contadorNavegacion = 0;
  static DateTime? _ultimaVezMostrada;

  /// Método estático para decidir si mostrar la publicidad
  static void intentarMostrar(BuildContext context) {
    _contadorNavegacion++;
    final ahora = DateTime.now();

    bool debeMostrar = false;
    if (_contadorNavegacion >= 5) {
      debeMostrar = true;
      _contadorNavegacion = 0;
    } else if (_ultimaVezMostrada == null || ahora.difference(_ultimaVezMostrada!).inMinutes >= 2) {
      debeMostrar = true;
    }

    if (debeMostrar) {
      // Verificamos si hay anuncios ANTES de abrir el diálogo para que sea 100% fluido
      FirebaseFirestore.instance
          .collection('publicidad')
          .where('esIntersticial', isEqualTo: true)
          .limit(1)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _ultimaVezMostrada = ahora;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const PublicidadIntersticial(),
          );
        }
      });
    }
  }

  @override
  State<PublicidadIntersticial> createState() => _PublicidadIntersticialState();
}

class _PublicidadIntersticialState extends State<PublicidadIntersticial> {
  int _segundosRestantes = 2;
  bool _puedeCerrar = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _iniciarCuentaRegresiva();
  }

  void _iniciarCuentaRegresiva() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_segundosRestantes > 0) {
        setState(() => _segundosRestantes--);
      } else {
        setState(() => _puedeCerrar = true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _puedeCerrar,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: FutureBuilder<QuerySnapshot>(
          // Buscamos una publicidad que sea intersticial
          future: FirebaseFirestore.instance
              .collection('publicidad')
              .where('esIntersticial', isEqualTo: true)
              .get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // Si no hay publicidad intersticial cargada, cerramos el diálogo discretamente
              if (snapshot.connectionState == ConnectionState.done) {
                 Future.delayed(Duration.zero, () => Navigator.pop(context));
              }
              return const SizedBox();
            }

            // Elegimos una al azar de las disponibles
            final docs = snapshot.data!.docs..shuffle();
            final data = docs.first.data() as Map<String, dynamic>;
            final String url = data['url'] ?? '';
            final String? link = data['link'];

            return Stack(
              alignment: Alignment.center,
              children: [
                // Imagen de fondo (Publicidad)
                GestureDetector(
                  onTap: () {
                    if (link != null && link.isNotEmpty) {
                      launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E272E),
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                // Botón de cerrar o contador
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.16,
                  right: MediaQuery.of(context).size.width * 0.08,
                  child: _puedeCerrar
                      ? GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 28),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: Text(
                            "$_segundosRestantes",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                ),

                // Texto informativo
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.17,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10)),
                    child: const Text("Publicidad", style: TextStyle(color: Colors.white70, fontSize: 10)),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
