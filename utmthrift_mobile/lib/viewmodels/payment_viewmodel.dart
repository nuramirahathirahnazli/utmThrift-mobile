//For payment online banking - toyyibpay purposes

import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PaymentViewModel extends ChangeNotifier {
  bool isLoading = false;

  Future<String?> initiatePayment({
    required double amount,
    required String name,
    required String email,
    required String phone,
    required String description,
    required int orderId,
  }) async {
    isLoading = true;
    notifyListeners();

    final billUrl = await PaymentService.createBill(
      amount: amount,
      name: name,
      email: email,
      phone: phone,
      description: description,
      orderId: orderId,
    );

    isLoading = false;
    notifyListeners();

    return billUrl;
  }
}
