// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/models/user_model.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/viewmodels/user_viewmodel.dart';
import '../services/auth_service.dart';

class SigninViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool isLoading = false;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser; // Add getter
  
  Future<String?> loginUser(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();

    final response = await _authService.loginUser(email: email, password: password);

    isLoading = false;
    notifyListeners();

     if (response != null && response.containsKey("token")) {
      _currentUser = UserModel.fromJson(response['user']); // Store the current user
      Provider.of<CartViewModel>(context, listen: false).clearCart();
      
      final userType = response['user']['user_type']; // Get user_type
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', userType); // Optional: save for later use

      notifyListeners(); // Notify after setting user
final userViewModel = Provider.of<UserViewModel>(context, listen: false);
await userViewModel.loadUser();
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

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
