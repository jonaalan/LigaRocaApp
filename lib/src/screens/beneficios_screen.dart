import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_sheets_service.dart';
import '../models/beneficio.dart';

class BeneficiosScreen extends StatefulWidget {
  const BeneficiosScreen({super.key});

  @override
  State<BeneficiosScreen> createState() => _BeneficiosScreenState();
}

class _BeneficiosScreenState extends State<BeneficiosScreen> {
  final GoogleSheetsService _sheetsService = GoogleSheetsService();
  final String _userEmail = FirebaseAuth.instance.currentUser?.email ?? "";

  List<Beneficio>? _beneficios;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarBeneficios();
  }

  Future<void> _cargarBeneficios() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final lista = await _sheetsService.obtenerBeneficios(_userEmail);
    if (mounted) {
      setState(() {
        _beneficios = lista;
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmarCanje(Beneficio beneficio) async {
    bool? confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E272E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Color(0xFF00C853)),
            SizedBox(width: 10),
            Text("CONFIRMAR CANJE",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
          "¿Estás frente al mostrador de ${beneficio.nombre}?\n\nRecordá que este beneficio solo se puede usar UNA vez al día.",
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white24))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16a34a),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SÍ, CANJEAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      // Bloqueo instantáneo
      setState(() {
        beneficio.disponible = false;
      });

      // Registro en Google Sheets
      bool exito = await _sheetsService.registrarCanje(_userEmail, beneficio.id);

      if (exito) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("¡Beneficio aplicado correctamente!"),
              backgroundColor: const Color(0xFF16a34a),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            )
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color verdeEsmeralda = Color(0xFF00C853);
    const Color cardColor = Color(0xFF1E272E);

    return Scaffold(
      backgroundColor: Colors.black,
      body: RefreshIndicator(
        onRefresh: _cargarBeneficios,
        color: verdeEsmeralda,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: verdeEsmeralda))
            : (_beneficios == null || _beneficios!.isEmpty)
                ? const Center(child: Text("No hay beneficios activos hoy", style: TextStyle(color: Colors.white54)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _beneficios!.length,
                    itemBuilder: (context, index) {
                      final b = _beneficios![index];
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        // Opacidad mejorada para que el canjeado sea legible (0.6)
                        opacity: b.disponible ? 1.0 : 0.6,
                        child: Card(
                          color: cardColor,
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: b.disponible ? Colors.white.withOpacity(0.05) : Colors.white10
                            )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 80, height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: b.disponible ? verdeEsmeralda.withOpacity(0.3) : Colors.white10)
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: b.logoUrl.isNotEmpty
                                          ? Image.network(b.logoUrl, fit: BoxFit.cover,
                                              errorBuilder: (_,__,___) => const Icon(Icons.store, size: 40, color: Colors.white12))
                                          : const Icon(Icons.store, size: 40, color: Colors.white12),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(b.nombre.toUpperCase(),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: b.disponible ? verdeEsmeralda.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(6)
                                            ),
                                            child: Text(b.rubro.toUpperCase(),
                                                style: TextStyle(color: b.disponible ? verdeEsmeralda : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 25),
                                Text(b.descuento,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -0.5)),
                                const SizedBox(height: 8),
                                Text(b.condiciones,
                                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, height: 1.4)),
                                const SizedBox(height: 25),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      // Fondo del botón deshabilitado más claro para resaltar el texto
                                      backgroundColor: b.disponible ? const Color(0xFF16a34a) : const Color(0xFF323B45),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: b.disponible ? () => _confirmarCanje(b) : null,
                                    child: Text(
                                      b.disponible ? "🟢 CANJEAR BENEFICIO" : "🔘 YA CANJEADO HOY",
                                      // Texto más claro y visible
                                      style: TextStyle(
                                        color: b.disponible ? Colors.white : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        letterSpacing: 1.1
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}