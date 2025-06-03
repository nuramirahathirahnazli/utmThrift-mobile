import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';

class UserViewModel extends ChangeNotifier {
  int? _userId;
  String? _userType;

  int? get userId => _userId;
  String? get userType => _userType;

  // Load user data from SharedPreferences (AuthService)
  Future<void> loadUser() async {
    _userId = await AuthService.getCurrentUserId();
    _userType = await _getUserType();
    notifyListeners();
  }

  Future<String?> _getUserType() async {
    // Similar to getCurrentUserId, add this in AuthService if not exist:
    // static Future<String?> getUserType() async {
    //   final prefs = await SharedPreferences.getInstance();
    //   return prefs.getString('user_type');
    // }
    return await AuthService.getUserType();
  }

  void clearUser() {
    _userId = null;
    _userType = null;
    notifyListeners();
  }
}
