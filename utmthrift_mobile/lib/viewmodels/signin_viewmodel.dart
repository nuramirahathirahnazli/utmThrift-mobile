import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SigninViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<String?> loginUser(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final response = await _authService.loginUser(email: email, password: password);

    isLoading = false;
    notifyListeners();

     if (response != null && response.containsKey("token")) {
      // Save token if needed
      return "Login successful!";
    } else {
      return response?["error"] ?? "Login failed!";
    }
  }
}
