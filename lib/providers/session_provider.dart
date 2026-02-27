// lib/providers/session_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider extends ChangeNotifier {
  static const _storageKey = 'smartstock_current_user';

  Map<String, dynamic>? _currentUser;
  bool _isLoading = false;

  Map<String, dynamic>? get currentUser => _currentUser;
  // alias cho tiện dùng chỗ khác nếu cần
  Map<String, dynamic>? get user => _currentUser;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  /// Gọi 1 lần lúc khởi động app (trong main) để load user đã lưu
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          _currentUser = decoded;
        }
      }
    } catch (_) {
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set user hiện tại + lưu bền vững
  void setUser(Map<String, dynamic>? user) {
    _currentUser = user;
    _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser == null) {
        await prefs.remove(_storageKey);
      } else {
        await prefs.setString(_storageKey, jsonEncode(_currentUser));
      }
    } catch (_) {
      // ignore lỗi ghi
    }
  }

  void clear() {
    setUser(null);
  }

  void logout() {
    clear();
  }
}
