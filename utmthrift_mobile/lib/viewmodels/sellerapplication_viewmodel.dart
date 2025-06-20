import 'dart:io';
import 'package:flutter/material.dart';

import '../services/sellerapplication_service.dart';

class SellerApplicationViewModel extends ChangeNotifier {
  bool isSubmitting = false;
  String? errorMessage;

  Future<bool> applySeller(String storeName, File matricCardFile) async {
    isSubmitting = true;
    notifyListeners();

    try {
      final success = await SellerApplicationService.applySeller(
        storeName: storeName,
        matricCardFile: matricCardFile,
      );

      if (!success) {
        errorMessage = "Failed to apply. Try again.";
      }

      return success;
    } catch (e) {
      errorMessage = "Something went wrong.";
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
