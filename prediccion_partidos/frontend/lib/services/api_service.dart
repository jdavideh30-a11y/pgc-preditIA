import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
 
class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';
  static String? _token;
  static bool _modoDemo = false;
 
  // Demo user storage
  static final List<Map<String, dynamic>> _historialLocal = [];
  static int _prediccionIdCounter = 1000;
 
  static void setToken(String token) => _token = token;
  static void clearToken() {
    _token = null;
    _modoDemo = false;
    _historialLocal.clear();
  }
 
  static Map<String, String> _headers({bool auth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && _token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }
 
  // ── DATOS DEMO ─────────────────────────────────────────────────────────────
 
  static final List<Map<String, dynamic>> _eventosDemo = [
    // Liga BetPlay (Colombia)
    {'id': 1, 'deporte': 'futbol', 'equipo_local': 'Atlético Nacional', 'equipo_visitante': 'Millonarios FC', 'liga': 'Liga BetPlay', 'estado': 'pendiente', 'fecha': '2026-05-28T20:00:00Z', 'resultado_real': null},
    {'id': 2, 'deporte': 'futbol', 'equipo_local': 'Deportivo Cali', 'equipo_visitante': 'América de Cali', 'liga': 'Liga BetPlay', 'estado': 'pendiente', 'fecha': '2026-05-29T19:00:00Z', 'resultado_real': null},
    {'id': 3, 'deporte': 'futbol', 'equipo_local': 'Junior FC', 'equipo_visitante': 'Santa Fe', 'liga': 'Liga BetPlay', 'estado': 'en_vivo', 'fecha': '2026-05-26T16:00:00Z', 'resultado_real': null},
    {'id': 4, 'deporte': 'futbol', 'equipo_local': 'Deportes Tolima', 'equipo_visitante': 'Once Caldas', 'liga': 'Liga BetPlay', 'estado': 'pendiente', 'fecha': '2026-05-30T18:30:00Z', 'resultado_real': null},
    // Champions League
    {'id': 5, 'deporte': 'futbol', 'equipo_local': 'Real Madrid', 'equipo_visitante': 'Manchester City', 'liga': 'Champions League', 'estado': 'pendiente', 'fecha': '2026-05-31T20:00:00Z', 'resultado_real': null},
    {'id': 6, 'deporte': 'futbol', 'equipo_local': 'Bayern München', 'equipo_visitante': 'Paris Saint-Germain', 'liga': 'Champions League', 'estado': 'pendiente', 'fecha': '2026-06-01T20:00:00Z', 'resultado_real': null},
    // Premier League
    {'id': 7, 'deporte': 'futbol', 'equipo_local': 'Arsenal', 'equipo_visitante': 'Chelsea', 'liga': 'Premier League', 'estado': 'pendiente', 'fecha': '2026-05-27T17:30:00Z', 'resultado_real': null},
    {'id': 8, 'deporte': 'futbol', 'equipo_local': 'Liverpool', 'equipo_visitante': 'Manchester United', 'liga': 'Premier League', 'estado': 'finalizado', 'fecha': '2026-05-25T15:00:00Z', 'resultado_real': 'local'},
    // La Liga
    {'id': 9, 'deporte': 'futbol', 'equipo_local': 'FC Barcelona', 'equipo_visitante': 'Atlético de Madrid', 'liga': 'La Liga', 'estado': 'pendiente', 'fecha': '2026-05-28T21:00:00Z', 'resultado_real': null},
    {'id': 10, 'deporte': 'futbol', 'equipo_local': 'Sevilla FC', 'equipo_visitante': 'Valencia CF', 'liga': 'La Liga', 'estado': 'finalizado', 'fecha': '2026-05-24T20:00:00Z', 'resultado_real': 'empate'},
    // Baloncesto NBA
    {'id': 11, 'deporte': 'baloncesto', 'equipo_local': 'Los Angeles Lakers', 'equipo_visitante': 'Golden State Warriors', 'liga': 'NBA', 'estado': 'pendiente', 'fecha': '2026-05-27T02:00:00Z', 'resultado_real': null},
    {'id': 12, 'deporte': 'baloncesto', 'equipo_local': 'Boston Celtics', 'equipo_visitante': 'Miami Heat', 'liga': 'NBA Playoffs', 'estado': 'en_vivo', 'fecha': '2026-05-26T23:30:00Z', 'resultado_real': null},
    // Tenis
    {'id': 13, 'deporte': 'tenis', 'equipo_local': 'Carlos Alcaraz', 'equipo_visitante': 'Jannik Sinner', 'liga': 'Roland Garros', 'estado': 'pendiente', 'fecha': '2026-05-29T13:00:00Z', 'resultado_real': null},
    {'id': 14, 'deporte': 'tenis', 'equipo_local': 'Novak Djokovic', 'equipo_visitante': 'Casper Ruud', 'liga': 'Roland Garros', 'estado': 'pendiente', 'fecha': '2026-05-30T15:00:00Z', 'resultado_real': null},
  ];
 
  static Map<String, dynamic> _generarPrediccionDemo(Map<String, dynamic> evento) {
    final rand = Random(evento['id'] as int);
    final probLocal = 0.30 + rand.nextDouble() * 0.35;
    final probEmpate = evento['deporte'] == 'futbol' ? 0.15 + rand.nextDouble() * 0.20 : 0.0;
    final probVisitante = 1.0 - probLocal - probEmpate;
    String resultado;
    if (probLocal >= probVisitante && probLocal >= probEmpate) {
      resultado = 'local';
    } else if (probVisitante >= probLocal && probVisitante >= probEmpate) {
      resultado = 'visitante';
    } else {
      resultado = 'empate';
    }
    final confianza = [probLocal, probEmpate, probVisitante].reduce(max);
 
    return {
      'id': _prediccionIdCounter++,
      'evento': evento['id'],
      'evento_detalle': evento,
      'resultado_predicho': resultado,
      'probabilidad_local': double.parse(probLocal.toStringAsFixed(3)),
      'probabilidad_empate': double.parse(probEmpate.toStringAsFixed(3)),
      'probabilidad_visitante': double.parse(probVisitante.toStringAsFixed(3)),
      'confianza': double.parse(confianza.toStringAsFixed(3)),
      'acerto': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
 
  // ── API CALLS con fallback demo ────────────────────────────────────────────
 
  // RF-01: Registro
  static Future<Map<String, dynamic>> registrar(
      String username, String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/registro/'),
        headers: _headers(auth: false),
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (_) {
      // Demo: registro local
      _modoDemo = true;
      _token = 'demo_token_${username.hashCode}';
      return {'username': username, 'email': email, 'demo': true};
    }
  }
 
  // RF-02: Login + JWT
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('http://localhost:8000/api/token/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['access'] != null) {
        setToken(data['access'] as String);
        _modoDemo = false;
      }
      return data;
    } catch (_) {
      // Demo mode: cualquier credencial funciona
      _modoDemo = true;
      _token = 'demo_token_${username.hashCode}';
      return {'access': _token, 'refresh': 'demo_refresh', 'demo': true};
    }
  }
 
  // RF-03: Eventos
  static Future<List<dynamic>> getEventos({String? deporte, String? estado}) async {
    try {
      var url = '$baseUrl/eventos/';
      final params = <String, String>{};
      if (deporte != null) params['deporte'] = deporte;
      if (estado != null) params['estado'] = estado;
      if (params.isNotEmpty) url += '?${Uri(queryParameters: params).query}';
      final res = await http.get(Uri.parse(url), headers: _headers())
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (_) {
      _modoDemo = true;
      var lista = List<Map<String, dynamic>>.from(_eventosDemo);
      if (deporte != null) lista = lista.where((e) => e['deporte'] == deporte).toList();
      if (estado != null) lista = lista.where((e) => e['estado'] == estado).toList();
      return lista;
    }
  }
 
  // RF-04: Prediccion IA
  static Future<Map<String, dynamic>> generarPrediccion(int eventoId) async {
    try {
      if (_modoDemo) throw Exception('demo');
      final res = await http.post(
        Uri.parse('$baseUrl/eventos/$eventoId/predecir/'),
        headers: _headers(),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (_) {
      _modoDemo = true;
      final evento = _eventosDemo.firstWhere(
        (e) => e['id'] == eventoId,
        orElse: () => {'id': eventoId, 'equipo_local': 'Local', 'equipo_visitante': 'Visitante', 'deporte': 'futbol'},
      );
      final pred = _generarPrediccionDemo(evento);
      // Guardar en historial local si no existe
      final yaExiste = _historialLocal.any((p) => p['evento'] == eventoId);
      if (!yaExiste) {
        _historialLocal.insert(0, pred);
      }
      return pred;
    }
  }
 
  // RF-06: Historial
  static Future<List<dynamic>> getHistorial() async {
    try {
      if (_modoDemo) throw Exception('demo');
      final res = await http.get(Uri.parse('$baseUrl/historial/'), headers: _headers())
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (_) {
      _modoDemo = true;
      // Poblar historial demo si está vacío (simular predicciones pasadas)
      if (_historialLocal.isEmpty) {
        _historialLocal.addAll([
          {
            'id': 901,
            'evento': 8,
            'evento_detalle': _eventosDemo[7],
            'resultado_predicho': 'local',
            'probabilidad_local': 0.62,
            'probabilidad_empate': 0.21,
            'probabilidad_visitante': 0.17,
            'confianza': 0.62,
            'acerto': true,
            'created_at': '2026-05-25T16:30:00Z',
          },
          {
            'id': 902,
            'evento': 10,
            'evento_detalle': _eventosDemo[9],
            'resultado_predicho': 'local',
            'probabilidad_local': 0.47,
            'probabilidad_empate': 0.30,
            'probabilidad_visitante': 0.23,
            'confianza': 0.47,
            'acerto': false,
            'created_at': '2026-05-24T21:00:00Z',
          },
        ]);
      }
      return _historialLocal;
    }
  }
 
  // RF-07: Simulacion
  static Future<Map<String, dynamic>> simularApuesta(
      int prediccionId, double monto, String resultado) async {
    try {
      if (_modoDemo) throw Exception('demo');
      final res = await http.post(
        Uri.parse('$baseUrl/predicciones/$prediccionId/simular/'),
        headers: _headers(),
        body: jsonEncode({'monto_virtual': monto, 'resultado_seleccionado': resultado}),
      ).timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (_) {
      _modoDemo = true;
      // Calcular cuota localmente
      final pred = _historialLocal.firstWhere(
        (p) => p['id'] == prediccionId,
        orElse: () => {'probabilidad_local': 0.4, 'probabilidad_empate': 0.3, 'probabilidad_visitante': 0.3},
      );
      final probMap = {
        'local': (pred['probabilidad_local'] as num).toDouble(),
        'empate': (pred['probabilidad_empate'] as num).toDouble(),
        'visitante': (pred['probabilidad_visitante'] as num).toDouble(),
      };
      final prob = probMap[resultado] ?? 0.33;
      final cuota = prob > 0 ? (1.0 / prob) * 0.90 : 2.5;
      final ganancia = (monto * cuota).roundToDouble();
      return {
        'id': Random().nextInt(9999),
        'monto_virtual': monto,
        'resultado_seleccionado': resultado,
        'cuota': double.parse(cuota.toStringAsFixed(2)),
        'ganancia_estimada': ganancia,
        'advertencia': 'Esta es una simulacion virtual. No involucra dinero real.',
      };
    }
  }
 
  static bool get esModoDemo => _modoDemo;
}
 