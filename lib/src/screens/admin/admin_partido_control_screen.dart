import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/partido.dart';
import '../../services/firestore_service.dart';

class AdminPartidoControlScreen extends StatefulWidget {
  final Partido partido;

  const AdminPartidoControlScreen({super.key, required this.partido});

  @override
  State<AdminPartidoControlScreen> createState() => _AdminPartidoControlScreenState();
}

class _AdminPartidoControlScreenState extends State<AdminPartidoControlScreen> {
  final FirestoreService _service = FirestoreService();
  late Timer _timer;
  String _tiempoTranscurrido = "00:00";
  int _minutoActual = 0;

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
      _minutoActual = duration.inMinutes;
      final segundos = duration.inSeconds % 60;
      if (mounted) {
        setState(() {
          _tiempoTranscurrido = '${_minutoActual.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';
        });
      }
    } else {
      if (mounted) setState(() => _tiempoTranscurrido = widget.partido.estado == EstadoPartido.pendiente ? "00:00" : "Final");
    }
  }

  Future<void> _agregarEvento(TipoEvento tipo, String equipoId) async {
    final formKey = GlobalKey<FormState>();
    final jugadorCtrl = TextEditingController();
    final camisetaCtrl = TextEditingController();
    final minutoCtrl = TextEditingController();

    // Controladores para el jugador que sale (solo para cambios)
    final jugadorSaleCtrl = TextEditingController();
    final camisetaSaleCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar ${tipo.toString().split('.').last.toUpperCase()}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: minutoCtrl,
                  decoration: const InputDecoration(labelText: 'Minuto del Evento'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // Si es cambio, mostramos "Entra" y "Sale"
                if (tipo == TipoEvento.cambio) ...[
                  const Text('JUGADOR QUE ENTRA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  TextFormField(
                    controller: jugadorCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre Jugador (Entra)'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: camisetaCtrl,
                    decoration: const InputDecoration(labelText: 'N° Camiseta (Entra)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('JUGADOR QUE SALE', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  TextFormField(
                    controller: jugadorSaleCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre Jugador (Sale)'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: camisetaSaleCtrl,
                    decoration: const InputDecoration(labelText: 'N° Camiseta (Sale)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ] else ...[
                  // Si no es cambio, campos normales
                  TextFormField(
                    controller: jugadorCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre Jugador'),
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                  TextFormField(
                    controller: camisetaCtrl,
                    decoration: const InputDecoration(labelText: 'N° Camiseta'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Requerido' : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final evento = EventoPartido(
                  id: '',
                  tipo: tipo,
                  minuto: int.tryParse(minutoCtrl.text) ?? 0,
                  jugadorNombre: jugadorCtrl.text,
                  camiseta: int.tryParse(camisetaCtrl.text) ?? 0,
                  equipoId: equipoId,
                  // Guardamos datos de salida solo si es cambio
                  jugadorSale: tipo == TipoEvento.cambio ? jugadorSaleCtrl.text : null,
                  camisetaSale: tipo == TipoEvento.cambio ? int.tryParse(camisetaSaleCtrl.text) : null,
                );
                
                _service.agregarEvento(
                  widget.partido.id, 
                  evento, 
                  tipo == TipoEvento.gol && equipoId == widget.partido.local.id,
                  tipo == TipoEvento.gol && equipoId == widget.partido.visitante.id
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Control de Partido')),
      body: StreamBuilder<List<Partido>>(
        stream: _service.getPartidos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final partidoActualizado = snapshot.data!.firstWhere((p) => p.id == widget.partido.id, orElse: () => widget.partido);

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black87,
                child: Column(
                  children: [
                    Text(_tiempoTranscurrido, style: const TextStyle(color: Colors.red, fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text('${partidoActualizado.local.nombre}\n${partidoActualizado.golesLocal}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20)),
                        const Text('-', style: TextStyle(color: Colors.white, fontSize: 20)),
                        Text('${partidoActualizado.visitante.nombre}\n${partidoActualizado.golesVisitante}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20)),
                      ],
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (partidoActualizado.estado == EstadoPartido.pendiente)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('INICIAR PARTIDO'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _service.iniciarPartido(partidoActualizado.id),
                      ),
                    if (partidoActualizado.estado == EstadoPartido.jugando)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: const Text('FINALIZAR'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => _service.finalizarPartido(partidoActualizado.id),
                      ),
                  ],
                ),
              ),

              const Divider(),

              if (partidoActualizado.estado == EstadoPartido.jugando)
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(partidoActualizado.local.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _BotonEvento(label: 'GOL', color: Colors.green, onTap: () => _agregarEvento(TipoEvento.gol, partidoActualizado.local.id)),
                            _BotonEvento(label: 'AMARILLA', color: Colors.yellow[700]!, onTap: () => _agregarEvento(TipoEvento.amarilla, partidoActualizado.local.id)),
                            _BotonEvento(label: 'ROJA', color: Colors.red, onTap: () => _agregarEvento(TipoEvento.roja, partidoActualizado.local.id)),
                            _BotonEvento(label: 'CAMBIO', color: Colors.blue, onTap: () => _agregarEvento(TipoEvento.cambio, partidoActualizado.local.id)),
                          ],
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: Column(
                          children: [
                            Text(partidoActualizado.visitante.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            _BotonEvento(label: 'GOL', color: Colors.green, onTap: () => _agregarEvento(TipoEvento.gol, partidoActualizado.visitante.id)),
                            _BotonEvento(label: 'AMARILLA', color: Colors.yellow[700]!, onTap: () => _agregarEvento(TipoEvento.amarilla, partidoActualizado.visitante.id)),
                            _BotonEvento(label: 'ROJA', color: Colors.red, onTap: () => _agregarEvento(TipoEvento.roja, partidoActualizado.visitante.id)),
                            _BotonEvento(label: 'CAMBIO', color: Colors.blue, onTap: () => _agregarEvento(TipoEvento.cambio, partidoActualizado.visitante.id)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _BotonEvento extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _BotonEvento({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 40)),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
