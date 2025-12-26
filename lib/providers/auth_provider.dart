import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:library_app/services/firebase/auth.dart';

class AuthProvider with ChangeNotifier {
  final Auth _authService = Auth();
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.loginWithEmailAndPassword(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.createUserWithEmailAndPassword(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authService.logout();
  }
  
  Future<void> changePassword(String newPassword) async {
    _setLoading(true);
    try {
      await _authService.changePassword(newPassword);
    } finally {
      _setLoading(false);
    }
  }
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}