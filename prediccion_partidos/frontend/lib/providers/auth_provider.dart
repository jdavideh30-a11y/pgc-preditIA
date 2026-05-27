import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _username;
  String? _error;
  bool _loading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;
  String? get error => _error;
  bool get loading => _loading;

  Future<bool> login(String username, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await ApiService.login(username, password);
      if (data['access'] != null) {
        _isAuthenticated = true;
        _username = username;
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Credenciales incorrectas';
      }
    } catch (e) {
      _error = 'Error de conexion';
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  Future<bool> registrar(String username, String email, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await ApiService.registrar(username, email, password);
      if (data['username'] != null) {
        _loading = false;
        notifyListeners();
        return true;
      }
      _error = data.toString();
    } catch (e) {
      _error = 'Error al registrar';
    }
    _loading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    ApiService.clearToken();
    _isAuthenticated = false;
    _username = null;
    notifyListeners();
  }
}
