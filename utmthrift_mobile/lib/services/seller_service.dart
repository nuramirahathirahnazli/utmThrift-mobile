import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/models/sellerprofile_model.dart';

const String baseUrl = ApiConfig.baseUrl;

class SellerService {

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

  static Future<SellerReviewProfileData> getSellerProfile(int sellerId) async {

    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/reviews/seller/$sellerId'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return SellerReviewProfileData.fromJson(jsonBody);
    } else {
      throw Exception('Failed to load seller reviews');
    }
  }
}
