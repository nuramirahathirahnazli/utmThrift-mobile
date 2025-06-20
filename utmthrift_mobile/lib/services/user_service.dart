// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:utmthrift_mobile/config/api_config.dart';
import 'package:utmthrift_mobile/models/user_model.dart';

const String baseUrl = ApiConfig.baseUrl;

class UserService {
  
  /// **Fetch User Profile**
  static Future<UserModel?> getUserProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      
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
 static Future<bool> updateUserProfile(String token, Map<String, dynamic> updatedData, File? imageFile) async {
  try {
    print("============ UPDATE USER PROFILE ============");
    print("[UserService] Preparing request...");

    final uri = Uri.parse('$baseUrl/profile/update');
    final request = http.MultipartRequest('POST', uri); // Laravel sees _method = PUT

    request.headers['Authorization'] = 'Bearer $token';
    print("[UserService] Token: $token");

    // Required: Tell Laravel this is a PUT request
    request.fields['_method'] = 'PUT';
    print("[UserService] _method: PUT");

    // Add text fields
    updatedData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
        print("[UserService] Field: $key = ${value.toString()}");
      }
    });

    // Add image file if exists
    if (imageFile != null) {
      print("[UserService] Adding image file: ${imageFile.path}");
      final fileBytes = await imageFile.readAsBytes();
      print("[UserService] File size (bytes): ${fileBytes.length}");
      
      request.files.add(await http.MultipartFile.fromPath(
        'profile_picture',
        imageFile.path,
      ));
    } else {
      print("[UserService] No image file selected.");
    }

    print("[UserService] Sending request to: $uri");
    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(streamedResponse);

    print("[UserService] Status: ${response.statusCode}");
    print("[UserService] Response body:\n${response.body}");

    print("============ END PROFILE UPDATE ============");

    return response.statusCode == 200;
  } catch (e) {
    print("[UserService] Error occurred: $e");
    return false;
  }
}





}
