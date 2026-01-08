import 'package:flutter/material.dart';
import '../../models/partido.dart';
import '../../services/firestore_service.dart';

class AdminFormacionScreen extends StatefulWidget {
  final Partido partido;
  final bool esLocal; // true para Local, false para Visitante

  const AdminFormacionScreen({super.key, required this.partido, required this.esLocal});

  @override
  State<AdminFormacionScreen> createState() => _AdminFormacionScreenState();
}

class _AdminFormacionScreenState extends State<AdminFormacionScreen> {
  final FirestoreService _service = FirestoreService();
  late List<JugadorFormacion> _jugadores;
  final _nombreCtrl = TextEditingController();
  final _camisetaCtrl = TextEditingController();
  bool _esTitular = true;

  @override
  void initState() {
    super.initState();
    _jugadores = List.from(widget.esLocal ? widget.partido.formacionLocal : widget.partido.formacionVisitante);
  }

  void _agregarJugador() {
    if (_nombreCtrl.text.isNotEmpty && _camisetaCtrl.text.isNotEmpty) {
      setState(() {
        _jugadores.add(JugadorFormacion(
          nombre: _nombreCtrl.text,
          camiseta: int.tryParse(_camisetaCtrl.text) ?? 0,
          esTitular: _esTitular,
        ));
        _nombreCtrl.clear();
        _camisetaCtrl.clear();
        _esTitular = true;
      });
    }
  }

  Future<void> _guardar() async {
    await _service.guardarFormacion(widget.partido.id, widget.esLocal, _jugadores);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final equipoNombre = widget.esLocal ? widget.partido.local.nombre : widget.partido.visitante.nombre;

    return Scaffold(
      appBar: AppBar(title: Text('Formación $equipoNombre')),
      body: Column(
        children: [
          // Formulario de carga rápida
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _camisetaCtrl,
                    decoration: const InputDecoration(labelText: 'N°'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Checkbox(value: _esTitular, onChanged: (v) => setState(() => _esTitular = v!)),
                const Text('Titular'),
                IconButton(icon: const Icon(Icons.add_circle, color: Colors.green), onPressed: _agregarJugador),
              ],
            ),
          ),
          const Divider(),
          
          // Lista de jugadores cargados
          Expanded(
            child: ListView.builder(
              itemCount: _jugadores.length,
              itemBuilder: (context, index) {
                final jugador = _jugadores[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: jugador.esTitular ? Colors.blue : Colors.grey,
                    child: Text(jugador.camiseta.toString(), style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(jugador.nombre),
                  subtitle: Text(jugador.esTitular ? 'Titular' : 'Suplente'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _jugadores.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: _guardar,
              child: const Text('GUARDAR FORMACIÓN'),
            ),
          ),
        ],
      ),
    );
  }
}
