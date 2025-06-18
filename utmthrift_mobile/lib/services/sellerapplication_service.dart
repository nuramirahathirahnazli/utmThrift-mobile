// ignore_for_file: avoid_print

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utmthrift_mobile/config/api_config.dart';

const String baseUrl = ApiConfig.baseUrl;

class SellerApplicationService {

  /// Get token from shared preferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  
  static Future<bool> applySeller({
    required String storeName,
    required File matricCardFile,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    final uri = Uri.parse('$baseUrl/apply-seller'); // <-- Define uri correctly

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      })
      ..fields['store_name'] = storeName
      ..files.add(await http.MultipartFile.fromPath('matric_card_image', matricCardFile.path));

    var response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      final res = await http.Response.fromStream(response);
      print('Failed to apply as seller: ${res.body}');
      return false;
    }
  }

}
