// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class SigninViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;

  Future<String?> loginUser(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final response = await _authService.loginUser(email: email, password: password);

    isLoading = false;
    notifyListeners();

     if (response != null && response.containsKey("token")) {
      final userType = response['user']['user_type']; // Get user_type
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType); // Optional: save for later use

      // Navigate based on user_type
      if (userType == 'Seller') {
        Navigator.pushReplacementNamed(context, '/seller_home');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }

      return "Login successful!";
    } else {
      return response?["error"] ?? "Login failed!";
    }
  }
}
