import 'dart:io';
import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/services/order_service.dart';

class QRPaymentViewModel extends ChangeNotifier {
  String? qrCodeImageUrl;
  bool isLoading = false;
  bool isUploading = false;

  Future<void> fetchQrCode(int sellerId) async {
    isLoading = true;
    notifyListeners();

    qrCodeImageUrl = await OrderService.getSellerQrCode(sellerId);

    isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadReceipt(int orderId, File receiptFile) async {
    isUploading = true;
    notifyListeners();

    final success = await OrderService.uploadReceipt(orderId: orderId, receiptFile: receiptFile);

    isUploading = false;
    notifyListeners();

    return success;
  }
}
