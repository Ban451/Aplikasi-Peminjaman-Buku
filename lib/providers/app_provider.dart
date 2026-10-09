import 'package:flutter/material.dart';
import '../models/anggota.dart';
import '../services/database_service.dart';

class AppProvider extends ChangeNotifier {
  Anggota? _currentUser;
  final DatabaseService _db = DatabaseService();

  Anggota? get currentUser => _currentUser;
  DatabaseService get db => _db;
  bool get isPetugas => _currentUser?.role == 'petugas';

  Future<bool> login(String username, String password) async {
    final user = await _db.login(username, password);
    if (user != null) {
      _currentUser = user;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}