import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EventosProvider with ChangeNotifier {
  List<dynamic> _eventos = [];
  List<dynamic> _historial = [];
  Map<String, dynamic>? _prediccionActual;
  bool _loading = false;

  List<dynamic> get eventos => _eventos;
  List<dynamic> get historial => _historial;
  Map<String, dynamic>? get prediccionActual => _prediccionActual;
  bool get loading => _loading;

  Future<void> cargarEventos({String? deporte}) async {
    _loading = true;
    notifyListeners();
    try {
      _eventos = await ApiService.getEventos(deporte: deporte);
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> predecir(int eventoId) async {
    _loading = true;
    notifyListeners();
    try {
      _prediccionActual = await ApiService.generarPrediccion(eventoId);
    } catch (_) {}
    _loading = false;
    notifyListeners();
    return _prediccionActual;
  }

  Future<void> cargarHistorial() async {
    _loading = true;
    notifyListeners();
    try {
      _historial = await ApiService.getHistorial();
    } catch (_) {}
    _loading = false;
    notifyListeners();
  }
}
