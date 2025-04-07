// ignore_for_file: use_build_context_synchronously, file_names, empty_catches

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/views/auth/otp_verification.dart';  

class SignupViewModel extends ChangeNotifier {
  bool isLoading = false;
   static const String baseUrl = 'http://127.0.0.1:8000/api'; //localhost
  // static const String baseUrl = 'http://10.211.98.11:8000/api'; //real device

  Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
    required String contact,
    required String matric,
    required String userType,
    required BuildContext context, // Added for navigation
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        body: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'contact': contact,
          'matric': matric,
          'user_type': userType,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Registration successful, navigate to OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(email: email),
          ),
        );
        return true;
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? "Registration failed")),
        );
        return false;
      }
    } catch (e) {
      // Handle any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Please try again.")),
      );
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}


