// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:utmthrift_mobile/models/user_model.dart';
import 'package:utmthrift_mobile/services/user_service.dart';
import 'package:utmthrift_mobile/services/auth_service.dart';

class ProfileViewModel extends ChangeNotifier {
  UserModel? user;
  bool isLoading = true;

  Future<void> fetchUserProfile() async {
    print("Fetching user profile...");

    String? token = await AuthService.getToken();
    if (token == null) {
      print("No token found. User not logged in.");
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      print("Token retrieved: $token");
      user = await UserService.getUserProfile(token);

      if (user != null) {
        print("User data received: ${user!.name}");
        
          user = user!.copyWith(
          name: user!.name,
          email: user!.email,
          contact: user!.contact,
          matric: user!.matric,
          userType: user!.userType, 
          gender: user!.gender,
          location: user!.location,
          status: user!.status,
          createdAt: user!.createdAt,
          createdAtFormatted: formatDate(user!.createdAt),
        );
      } else {
        print("User data is null.");
      }

    } catch (e) {
      print("Error fetching user profile: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "Unknown";
    return DateFormat('d MMM yyyy').format(date); 
  }

  /// **Update Profile Function**
  Future<bool> updateProfile({
    String? profilePicture,
    required String name,
    required String contact,
    required String email,
    required String gender,
    required String location,
    required String status,
    required String userType,
  }) async {
     final url = Uri.parse("http://127.0.0.1:8000/api/profile/update"); //localhost
    //  final url = Uri.parse("http://10.211.98.11:8000/api/profile/update"); //real device
    
    String? token = await AuthService.getToken(); // 🔹 Fetch auth token
    if (token == null) {
      print("No token found. Cannot update profile.");
      return false;
    }

    print("Sending Profile Update Request:");
    print("Profile Picture URL: $profilePicture");
    print("Name: $name");
    print("Phone: $contact");
    print("Gender: $gender");
    print("Location: $location");
    print("Status: $status");

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // 🔹 Include the token in the headers
        },
        body: jsonEncode({
          "name": name,
          "contact": contact,
          "email": email,
          "gender": gender,
          "location": location,
          "status": status,
          "user_type": userType,
          if (profilePicture != null && profilePicture.isNotEmpty)
          "profile_picture": profilePicture, 
        }),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Profile updated successfully!");
        return true;
      } else {
        print("Profile update failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Error updating profile: $e");
      return false;
    }
  }

}
