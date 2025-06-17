// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/models/review_model.dart';

const String baseUrl = ApiConfig.baseUrl;

class ReviewService {

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
  
  Future<List<Review>> fetchReviewsForSeller(int sellerId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/reviews/seller/$sellerId'),
      headers: _buildHeaders(token),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Review.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reviews');
    }
  }

  Future<double> fetchAverageRating(int sellerId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$baseUrl/rating/sellers/$sellerId'),
      headers: _buildHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['average_rating'] ?? 0.0).toDouble();
    } else {
      throw Exception('Failed to load average rating');
    }
  }

  Future<bool> submitReview({
  required int orderId,
  required int itemId,
  required int buyerId,
  required int sellerId,
  required int rating,
  String? comment,
}) async {
  try {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    // 🔍 Debug log: print the payload
    print('Submitting review with data:');
    print('order_id: $orderId');
    print('item_id: $itemId');
    print('buyer_id: $buyerId');
    print('seller_id: $sellerId'); // 👈 This is what you asked
    print('rating: $rating');
    print('comment: ${comment ?? ""}');

    final response = await http.post(
      Uri.parse('$baseUrl/reviews'),
      headers: _buildHeaders(token),
      body: jsonEncode({
        'order_id': orderId,
        'item_id': itemId,
        'buyer_id': buyerId,
        'seller_id': sellerId,
        'rating': rating,
        'comment': comment ?? '',
      }),
    );

    if (response.statusCode == 201) {
      print('✅ Review submitted successfully.');
      return true;
    } else {
      print('❌ Review submission failed with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  } catch (e) {
    print('❗ Error in submitReview: $e');
    return false;
  }
}



}
