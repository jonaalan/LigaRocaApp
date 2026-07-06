import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // <--- NUEVO
import '../models/beneficio.dart';

class GoogleSheetsService {
  final String _baseUrl = "https://script.google.com/macros/s/AKfycbwOcg2Qm8By802z-HkJw5Oej6T_HtTObBykuTArzGS14s87KxaBA2tb8RS-u_BSDvE3/exec";

  Future<List<Beneficio>> obtenerBeneficios(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hoy = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

      final uri = Uri.parse(_baseUrl).replace(queryParameters: {'email': email});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Beneficio> lista = body.map((item) => Beneficio.fromJson(item)).toList();

        // CAPA DE SEGURIDAD LOCAL:
        // Revisamos si en el teléfono hay registros de canjes de hoy
        for (var b in lista) {
          bool yaCanjeadoLocal = prefs.getBool('canje_${b.id}_$hoy') ?? false;
          if (yaCanjeadoLocal) {
            b.disponible = false;
          }
        }
        return lista;
      }
      return [];
    } catch (e) {
      print("Error Sheets GET: $e");
      return [];
    }
  }

  Future<bool> registrarCanje(String email, String idComercio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hoy = DateTime.now().toString().split(' ')[0];

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "idComercio": idComercio}),
      );

      bool exito = response.statusCode == 200 || response.statusCode == 302;

      if (exito) {
        // GUARDAMOS EN EL TELÉFONO QUE YA SE CANJEÓ
        await prefs.setBool('canje_${idComercio}_$hoy', true);
      }
      return exito;
    } catch (e) {
      if (e.toString().contains('Redirect')) {
        final prefs = await SharedPreferences.getInstance();
        final hoy = DateTime.now().toString().split(' ')[0];
        await prefs.setBool('canje_${idComercio}_$hoy', true);
        return true;
      }
      return false;
    }
  }
}