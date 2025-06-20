// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
          userRole: user!.userRole,
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
    required String name,
    required String contact,
    required String email,
    required String gender,
    required String location,
    required String userRole,
    required String userType,
    File? imageFile,
  }) async {
    print("🟡 ViewModel: Starting profile update...");

    String? token = await AuthService.getToken();
    if (token == null) {
      print("❌ No token found. Cannot update profile.");
      return false;
    }

    Map<String, dynamic> updatedData = {
      "name": name,
      "contact": contact,
      "email": email,
      "gender": gender,
      "location": location,
      "user_role": userRole,
      "user_type": userType,
    };

    final result = await UserService.updateUserProfile(token, updatedData, imageFile);

    if (result) {
      print("✅ ViewModel: Profile updated successfully!");
      await fetchUserProfile(); // Refresh UI
    } else {
      print("❌ ViewModel: Failed to update profile.");
    }

    return result;
  }


}
