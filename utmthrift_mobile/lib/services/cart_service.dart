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

  Future<List<CartItem>> fetchCartItems() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/cart/items'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Note: API returns 'cart_items', not 'items'
      return (data['cart_items'] as List)
          .map((json) => CartItem.fromJson(json))
          .toList();
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

  // You may remove these if your backend doesn't support updates or removes yet

  Future<bool> updateCartItem(int itemId, int quantity) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.put(
      Uri.parse('$baseUrl/cart/update/$itemId'),
      headers: _buildHeaders(token),
      body: jsonEncode({'quantity': quantity}),
    );

    return response.statusCode == 200;
  }

  Future<bool> removeCartItem(int itemId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.delete(
      Uri.parse('$baseUrl/cart/remove/$itemId'),
      headers: _buildHeaders(token),
    );

    return response.statusCode == 200;
  }

  Future<bool> checkout() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$baseUrl/cart/checkout'),
      headers: _buildHeaders(token),
    );

    return response.statusCode == 200;
  }
}
