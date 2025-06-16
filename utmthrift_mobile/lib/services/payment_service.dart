//For payment online banking - toyyibpay purposes

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
//  static const String baseUrl = 'http://127.0.0.1:8000/api';
  static const String baseUrl = "http://10.160.32.73:8000/api";

  /// Get token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  /// Build common headers for requests
  static Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  
  /// Create a payment bill using ToyyibPay
  static Future<String?> createBill({
    required double amount,
    required String name,
    required String email,
    required String phone,
    required String description,
    required int orderId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception("No token found");

      final response = await http.post(
        Uri.parse('$baseUrl/create-bill'),
        headers: _buildHeaders(token),
        body: jsonEncode({
          'amount': (amount * 100).toInt(), // Convert RM to cents
          'email': email,
          'name': name,
          'phone': phone,
          'description': description,
          'order_id': orderId,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['bill_url']; // this is the ToyyibPay payment link
      } else {
        print('API Error: ${data['error']}');
        return null;
      }
    } catch (e) {
      print('CreateBill Error: $e');
      return null;
    }
  }
  
}
