// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:utmthrift_mobile/models/sellersale_model.dart';
import 'package:utmthrift_mobile/services/sellersale_service.dart';

class SellerSaleViewModel extends ChangeNotifier {
  List<SellerSale> _sales = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  List<SellerSale> get sales => _sales;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get summary => _summary;

  /// ✅ Allow optional month and year filtering
  Future<void> fetchSales(int sellerId, {int? month, int? year}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await SellerSaleService.getSellerSales(
        sellerId,
        month: month,
        year: year,
      );

      _sales = List<SellerSale>.from(data['sales']);
      _summary = data['summary'];

      print("Sales fetched: ${_sales.length}");
      print("Summary: $_summary");
    } catch (e) {
      print("Error fetching sales in ViewModel: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
