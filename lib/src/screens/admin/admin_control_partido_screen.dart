import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/partido.dart';

class AdminControlPartidoScreen extends StatelessWidget {
  final String partidoId;
  final String equipoLocal;
  final String equipoVisitante;

  final FirestoreService _firestoreService = FirestoreService();

  AdminControlPartidoScreen({
    super.key,
    required this.partidoId,
    required this.equipoLocal,
    required this.equipoVisitante,
  });

  @override
  Widget build(BuildContext context) {
    const Color verdeEsmeralda = Color(0xFF00C853);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('CONTROL DE PARTIDO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF051209),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('partidos').doc(partidoId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: verdeEsmeralda));

          var data = snapshot.data!.data() as Map<String, dynamic>;
          int gL = int.tryParse(data['golesLocal'].toString()) ?? 0;
          int gV = int.tryParse(data['golesVisitante'].toString()) ?? 0;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                color: const Color(0xFF0A0F12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCol(equipoLocal, gL, verdeEsmeralda),
                    const Text("VS", style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold)),
                    _buildCol(equipoVisitante, gV, verdeEsmeralda),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildBtn(context, "GOL $equipoLocal", () {
                      _firestoreService.agregarEvento(
                          partidoId,
                          EventoPartido(id: '', tipo: TipoEvento.gol, minuto: 0, jugadorNombre: '', camiseta: 0, equipoId: ''),
                          true,
                          false
                      );
                    }, verdeEsmeralda),

                    const SizedBox(height: 10),

                    _buildBtn(context, "GOL $equipoVisitante", () {
                      _firestoreService.agregarEvento(
                          partidoId,
                          EventoPartido(id: '', tipo: TipoEvento.gol, minuto: 0, jugadorNombre: '', camiseta: 0, equipoId: ''),
                          false,
                          true
                      );
                    }, verdeEsmeralda),

                    const Divider(height: 40, color: Colors.white10),

                    Row(
                      children: [
                        Expanded(child: _buildBtnMin("Quitar Local", () => _updateSimple(partidoId, 'golesLocal', gL > 0 ? gL - 1 : 0))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildBtnMin("Quitar Vis.", () => _updateSimple(partidoId, 'golesVisitante', gV > 0 ? gV - 1 : 0))),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _updateSimple(String id, String campo, int val) async {
    await FirebaseFirestore.instance.collection('partidos').doc(id).update({campo: val});
  }

  Widget _buildCol(String n, int g, Color v) {
    return Column(children: [
      Text(n.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      Text('$g', style: TextStyle(color: v, fontSize: 45, fontWeight: FontWeight.w900)),
    ]);
  }

  Widget _buildBtn(BuildContext c, String t, VoidCallback o, Color v) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: v,
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 55)
        ),
        onPressed: o,
        child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold))
    );
  }

  Widget _buildBtnMin(String t, VoidCallback o) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white38,
            side: const BorderSide(color: Colors.white10)
        ),
        onPressed: o,
        child: Text(t, style: const TextStyle(fontSize: 10))
    );
  }
}