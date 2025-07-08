// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/viewmodels/itemcart_viewmodel.dart';
import 'package:utmthrift_mobile/views/auth/sign_in.dart';

const String baseUrl = ApiConfig.baseUrl;

class AuthService {

  // Register User
  Future<String?> registerUser({
    required String name,
    required String email,
    required String password,
    required String contactNumber,
    required String matricNumber,
    required String userType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "contact_number": contactNumber,
        "matric_number": matricNumber,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data['email'];
    } else {
      return null;
    }
  }

  // Login User
  Future<Map<String, dynamic>?> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    print("Response Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('user_id', data['user']['id']); 
        await prefs.setString('user_type', data['user']['user_type']);
        return data;
      } else {
        return {"error": data["message"] ?? "Login failed!"};
      }
    } catch (e) {
      print("JSON Decode Error: $e");
      return {"error": "Invalid server response (not JSON)"};
    }
  }

  // Logout Function
  static Future<void> logout(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), 
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      await _performLogout(context);
    }
  }

  // Perform Logout Actions
    static Future<void> _performLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    print("Stored Token Before Logout: $token");

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Logout Response: ${response.statusCode}");
    print("Logout Response Body: ${response.body}");

    await prefs.remove('token');
    await prefs.remove('user_id');
    await prefs.remove('user_type'); 

    Provider.of<CartViewModel>(context, listen: false).clearCart();
    
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }

   // Get current logged-in user ID from SharedPreferences
  static Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // get current user token (make it static for convenience)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_type');
  }
}
