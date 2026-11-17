import 'package:flutter/material.dart';
import 'core/models/app_user.dart';
import 'core/repositories/auth_repository.dart';

enum AppLanguage { english, hindi, marathi }

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  UserRole get currentRole => _currentUser?.role ?? UserRole.patient;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  int _pendingSyncCount = 0;
  int get pendingSyncCount => _pendingSyncCount;

  void setLanguage(AppLanguage lang) {
    _language = lang;
    notifyListeners();
  }

  void setUser(AppUser? user) {
    _currentUser = user;
    if (user != null) {
      if (user.language == 'hi') {
        _language = AppLanguage.hindi;
      } else if (user.language == 'mr') {
        _language = AppLanguage.marathi;
      } else {
        _language = AppLanguage.english;
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthRepository.instance.logout();
    _currentUser = null;
    notifyListeners();
  }

  void setOnlineStatus(bool online) {
    _isOnline = online;
    notifyListeners();
  }

  void setPendingSyncCount(int count) {
    _pendingSyncCount = count;
    notifyListeners();
  }

  // Helper to get text based on language
  String translate(String en, String hi, String mr) {
    switch (_language) {
      case AppLanguage.hindi:
        return hi;
      case AppLanguage.marathi:
        return mr;
      case AppLanguage.english:
        return en;
    }
  }
}
