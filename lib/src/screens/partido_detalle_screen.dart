import 'dart:async';
import 'package:flutter/material.dart';
import '../models/partido.dart';

class PartidoDetalleScreen extends StatefulWidget {
  final Partido partido;

  const PartidoDetalleScreen({super.key, required this.partido});

  @override
  State<PartidoDetalleScreen> createState() => _PartidoDetalleScreenState();
}

class _PartidoDetalleScreenState extends State<PartidoDetalleScreen> {
  late Timer _timer;
  String _tiempoTranscurrido = "00:00";

  @override
  void initState() {
    super.initState();
    _actualizarReloj();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) => _actualizarReloj());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _actualizarReloj() {
    if (widget.partido.estado == EstadoPartido.jugando && widget.partido.tiempoInicio != null) {
      final duration = DateTime.now().difference(widget.partido.tiempoInicio!);
      final minutos = duration.inMinutes;
      final segundos = duration.inSeconds % 60;
      if (mounted) {
        setState(() {
          _tiempoTranscurrido = '${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
        });
      }
    } else if (widget.partido.estado == EstadoPartido.finalizado) {
      if (mounted) setState(() => _tiempoTranscurrido = "Finalizado");
    } else {
      if (mounted) setState(() => _tiempoTranscurrido = "Pendiente");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventosLocal = widget.partido.eventos.where((e) => e.equipoId == widget.partido.local.id).toList();
    final eventosVisitante = widget.partido.eventos.where((e) => e.equipoId == widget.partido.visitante.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Partido'),
      ),
      body: Column(
        children: [
          // Marcador (Siempre visible)
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green[800],
            child: Column(
              children: [
                Text(
                  _tiempoTranscurrido,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _EquipoHeader(equipo: widget.partido.local, goles: widget.partido.golesLocal),
                    const Text("-", style: TextStyle(color: Colors.white, fontSize: 40)),
                    _EquipoHeader(equipo: widget.partido.visitante, goles: widget.partido.golesVisitante),
                  ],
                ),
              ],
            ),
          ),
          
          // Minuto a Minuto
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: eventosLocal.length,
                    itemBuilder: (context, index) => _EventoItem(evento: eventosLocal[index], esLocal: true),
                  ),
                ),
                Container(width: 1, color: Colors.grey[300]),
                Expanded(
                  child: ListView.builder(
                    itemCount: eventosVisitante.length,
                    itemBuilder: (context, index) => _EventoItem(evento: eventosVisitante[index], esLocal: false),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipoHeader extends StatelessWidget {
  final dynamic equipo;
  final int goles;

  const _EquipoHeader({required this.equipo, required this.goles});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(equipo.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(goles.toString(), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _EventoItem extends StatelessWidget {
  final EventoPartido evento;
  final bool esLocal;

  const _EventoItem({required this.evento, required this.esLocal});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    
    switch (evento.tipo) {
      case TipoEvento.gol:
        icon = Icons.sports_soccer;
        color = Colors.black;
        break;
      case TipoEvento.amarilla:
        icon = Icons.style;
        color = Colors.yellow[700]!;
        break;
      case TipoEvento.roja:
        icon = Icons.style;
        color = Colors.red;
        break;
      case TipoEvento.cambio:
        icon = Icons.compare_arrows;
        color = Colors.blue;
        break;
    }

    return Card(
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: esLocal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: esLocal ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (!esLocal) Icon(icon, color: color, size: 20),
                if (!esLocal) const SizedBox(width: 4),
                Text("${evento.minuto}'", style: const TextStyle(fontWeight: FontWeight.bold)),
                if (esLocal) const SizedBox(width: 4),
                if (esLocal) Icon(icon, color: color, size: 20),
              ],
            ),
            
            if (evento.tipo == TipoEvento.cambio) ...[
              Row(
                mainAxisAlignment: esLocal ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                  Text(" ${evento.jugadorNombre} (${evento.camiseta})", style: const TextStyle(fontSize: 12)),
                ],
              ),
              if (evento.jugadorSale != null)
                Row(
                  mainAxisAlignment: esLocal ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.arrow_downward, size: 12, color: Colors.red),
                    Text(" ${evento.jugadorSale} (${evento.camisetaSale})", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
            ] else ...[
              Text(evento.jugadorNombre, style: const TextStyle(fontSize: 12)),
              Text("Camiseta ${evento.camiseta}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ],
        ),
      ),
    );
  }
}
