import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SigninViewModel extends ChangeNotifier {
  bool isLoading = false;

  Future<String?> loginUser(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/login"),
      body: {
        'email': email,
        'password': password,
      },
    );

    isLoading = false;
    notifyListeners();

    if (response.statusCode == 200) {
      json.decode(response.body);
      return "Login successful!";
    } else {
      final error = json.decode(response.body);
      return error['error'] ?? "Login failed!";
    }
  }
}
