import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  static const _masterKey = 'master_password';
  
  bool _isAuthenticated = false;
  bool _hasMasterPassword = false;
  bool _isLoading = true;

  bool get isAuthenticated => _isAuthenticated;
  bool get hasMasterPassword => _hasMasterPassword;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final password = await _storage.read(key: _masterKey);
    _hasMasterPassword = password != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> setMasterPassword(String password) async {
    try {
      await _storage.write(key: _masterKey, value: password);
      _hasMasterPassword = true;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> login(String password) async {
    final savedPassword = await _storage.read(key: _masterKey);
    if (savedPassword == password) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }
}
