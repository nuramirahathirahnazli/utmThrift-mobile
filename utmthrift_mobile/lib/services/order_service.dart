// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/models/order_model.dart';

const String baseUrl = ApiConfig.baseUrl;

class OrderService {
  
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

  /// Create a new order
  static Future<int?> createOrder({
    required int buyerId,
    required int itemId,
    required int sellerId,
    required int quantity,
    required String paymentMethod,
  }) async {
    final token = await _getToken();
    if (token == null) {
      print('[OrderService] Token is null');
      return null;
    }

    final url = Uri.parse('$baseUrl/orders/create');

    final body = jsonEncode({
      'buyer_id': buyerId,
      'item_id': itemId,
      'seller_id': sellerId,
      'quantity': quantity,
      'payment_method': paymentMethod,
    });

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(token),
        body: body,
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final int orderId = responseData['order']['id']; // <-- Corrected line
        print('[OrderService] Order created successfully with ID $orderId');
        return orderId;
      } else {
        print('[OrderService] Order creation failed: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('[OrderService] Exception: $e');
      return null;
    }
  }



  /// Confirm a Meet Up order (set status to completed and item to sold)
  static Future<bool> confirmOrder(int orderId) async {
    final token = await _getToken();
    if (token == null) {
      print('[OrderService] Token is null');
      return false;
    }

    final url = Uri.parse('$baseUrl/orders/$orderId/confirm');

    try {
      final response = await http.post(
        url,
        headers: _buildHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final success = data['success'] == true;
        if (success) {
          print('[OrderService] Order confirmed successfully');
        } else {
          print('[OrderService] Failed to confirm order: ${data['message']}');
        }
        return success;
      } else {
        print('[OrderService] Confirm order failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('[OrderService] Exception: $e');
      return false;
    }
  }

  /// Confirm payment when user click on back to order
  static Future<void> manualConfirmOrder(int orderId) async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/orders/$orderId/manual-confirm');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('Order manually confirmed');
    } else {
      print('Failed to confirm order: ${response.body}');
      throw Exception('Failed to confirm order');
    }
  }

  static Future<List<Order>> getBuyerOrders() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/orders/buyer');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
