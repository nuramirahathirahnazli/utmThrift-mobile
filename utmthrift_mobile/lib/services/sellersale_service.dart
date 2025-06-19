// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/models/sellersale_model.dart';

const String baseUrl = ApiConfig.baseUrl;

class SellerSaleService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('Retrieved token: $token');
    return token;
  }

  static Map<String, String> _buildHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// Gets the sales summary for a specific seller.
  static Future<Map<String, dynamic>> getSellerSales(int sellerId, {int? month, int? year}) async {
    final token = await _getToken();
    if (token == null) {
      print('No authentication token found');
      throw Exception('No authentication token found');
    }

    String url = '$baseUrl/seller/$sellerId/sales';
    if (month != null && year != null) {
      url += '?month=$month&year=$year';
    }

    print('Sending GET request to: $url');
    final headers = _buildHeaders(token);
    print('Request Headers: $headers');

    final response = await http.get(Uri.parse(url), headers: headers);
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      final summary = jsonBody['summary'];
      final salesList = jsonBody['sales'] as List;

      print('Summary: $summary');
      print('Sales List: $salesList');

      final sales = salesList.map((json) => SellerSale.fromJson(json)).toList();

      return {
        'summary': summary,
        'sales': sales,
      };
    } else {
      print('Failed to load sales, status: ${response.statusCode}');
      throw Exception('Failed to load sales');
    }
  }
}
