// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:utmthrift_mobile/models/user_model.dart';

class UserService {
 static const String baseUrl = "http://127.0.0.1:8000/api"; //localhost
 // static const String baseUrl = "http://10.211.98.11:8000/api"; //real device - kena check ipconfig dkt cmd sbb selalu tukar2 address dia

  /// **Fetch User Profile**
  static Future<UserModel?> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/profile'), //localhost
     // Uri.parse('http://10.211.98.11:8000/api/profile'), //real device

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("Fetching user profile...");
    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('user')) {
        print("User data found: ${data['user']}");
        return UserModel.fromJson(data['user']);
      } else {
        print("Invalid API response: Missing 'user' key.");
        return null;
      }
    } else {
      print("Failed to fetch user profile: ${response.body}");
      return null;
    }
  }

  /// **Update User Profile**
  static Future<bool> updateUserProfile(String token, Map<String, dynamic> updatedData) async {
    try {
      print("[UserService] Updating user profile...");

      final response = await http.put(
        Uri.parse('$baseUrl/profile/update'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 10)); // ⏳ Timeout

      print("[UserService] Update response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("[UserService] Profile updated successfully.");
        return true;
      } else {
        print("[UserService] Failed to update profile: ${response.body}");
        return false;
      }
    } catch (e) {
      print("[UserService] Error updating profile: $e");
      return false;
    }
  }
}
