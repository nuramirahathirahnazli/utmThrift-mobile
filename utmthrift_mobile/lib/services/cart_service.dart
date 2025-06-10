// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/models/itemcart_model.dart';

class CartService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Map<String, String> _buildHeaders(String? token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  Future<List<CartItem>> fetchCartItems(int userId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/cart/$userId'),
      headers: _buildHeaders(token),
    );

    final data = jsonDecode(response.body);
    print('Cart API response data: $data');

    if (response.statusCode == 200) {
      final itemsList = data['data'] as List<dynamic>;
      return itemsList.map((json) => CartItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cart: ${response.statusCode}');
    }
  }

  // Since backend forces quantity=1, no need to pass quantity
  Future<bool> addItemToCart(int itemId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: _buildHeaders(token),
      body: jsonEncode({
        'item_id': itemId,
        // quantity not sent, backend defaults to 1
      }),
    );

    // Your backend returns 200 (OK), not 201 (Created)
    return response.statusCode == 200;
  }

  // Remove item from cart
  Future<bool> removeCartItem(int itemId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$itemId'),
      headers: _buildHeaders(token),
    );

    return response.statusCode == 200;
  }

  // Checkout cart
  Future<bool> checkout() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/cart/checkout'),
      headers: _buildHeaders(token),
    );

    return response.statusCode == 200;
  }

  /// Remove item from cart by item ID
  Future<bool> removeItemFromCart(int itemId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$itemId'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      // Successfully removed
      return true;
    } else {
      print('Failed to remove item from cart: ${response.statusCode} ${response.body}');
      return false;
    }
  }
}
